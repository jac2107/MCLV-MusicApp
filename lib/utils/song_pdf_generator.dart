// lib/utils/song_pdf_generator.dart
//
// Genera un PDF presentable a partir de una o varias canciones.
// - 1 canción: cabecera simple con título/tonalidad/tiempo + letra.
// - 2+ canciones: portada tipo "Repertorio" con el listado (en el MISMO
//   orden en que el usuario las seleccionó), luego cada canción en su
//   propia página.
//
// Reutiliza la MISMA lógica de reconocimiento de acordes que Vcanciones.dart
// (regex de acordes + palabras clave como CORO/VERSO/etc.) para que el PDF
// se vea consistente con lo que el usuario ve en la app.
//
// IMPORTANTE: la letra y los acordes se renderizan con una fuente
// monoespaciada (Roboto Mono) embebida, la MISMA que usa Vcanciones.dart en
// la app. Esto es lo que garantiza que el espaciado manual que el usuario
// calibra (contando espacios entre acordes y sílabas) se vea IGUAL en la
// app y en el PDF compartido. Si se usara la fuente por defecto del PDF
// (Helvetica, no monoespaciada) o pesos de fuente distintos (bold vs
// normal) para acordes vs letra, el alineado se rompería aunque el string
// guardado en Firebase fuera perfecto.
//
// CAMBIOS DE ESTA REFACTORIZACIÓN
// --------------------------------
// 1. Las canciones largas ya NO rompen el PDF: cada línea es ahora un
//    widget independiente dentro de un `pw.MultiPage`, así el motor de
//    layout puede partir el contenido entre páginas sin necesidad de que
//    quepa entero en una sola (antes se armaba un único `pw.RichText`
//    gigante, que es lo que disparaba la excepción de "Widget won't fit").
// 2. Layout en dos columnas automático: si la canción supera
//    `_maxLineasUnaColumna` líneas, la letra se reparte en dos columnas.
//    Para evitar que un bloque de 2 columnas "salte" entero a la página
//    siguiente cuando no cabe completo (lo que se veía como una hoja con
//    mucho espacio en blanco), la letra se corta en BLOQUES que sí caben
//    en una página (calculado según el alto real de página menos
//    márgenes), y cada bloque es un widget de 2 columnas independiente que
//    `MultiPage` acomoda de a uno — igual que hace con líneas sueltas en
//    el layout de una columna. Ver `_buildLyricsEnDosColumnas` para el
//    detalle del cálculo.
// 3. Márgenes reducidos para ganar ancho útil.
// 4. `generate()` ahora recibe una única lista ordenada de canciones
//    (`List<Song> canciones`) en vez de `adoracion`/`alabanza` por
//    separado, para respetar EXACTAMENTE el orden elegido por el usuario.
//    Cada canción conserva su categoría a través de `Song.categoria`
//    (o el parámetro `categoriaDe`, ver más abajo) únicamente para
//    mostrar una etiqueta en el índice, sin alterar el orden.

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/Mcanciones.dart';

class SongPdfGenerator {
  SongPdfGenerator._();

  // ---------------------------------------------------------------------
  // Reconocimiento de acordes / palabras clave
  // Mismos patrones que en Vcanciones.dart — si cambias uno, cambia el otro.
  // ---------------------------------------------------------------------
  static final String _suffix =
      r'(?:maj7|maj|min|dim7|dim|aug|sus\d*|add\d*|m7|m9|m6|m|[°+])?';
  static final String _bassPart = r'(?:\/[A-G][#b]?' + _suffix + r'\d*)*';
  static final String _chordUnit =
      r'[A-G][#b]?' + _suffix + r'\d*' + _bassPart;

  static final RegExp _chordRegex = RegExp(
    r'(?:(?<=^)|(?<=\s))' +
        '(?:$_chordUnit)' +
        '(?:-(?:$_chordUnit))*' +
        r'(?:(?=$)|(?=[\s/]))',
  );

  static final RegExp _keywordRegex = RegExp(
    r'\b(?:CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?: \d+)?|PRE-CORO|CORO 1 Y 2|CORO(?: \d+)?|INSTRUMENTAL|FINAL|ESTROFA|SOLO|PUENTE(?: \d+)?|BAJO|SALIDA(?: \d+)?)\b',
  );

  // ---------------------------------------------------------------------
  // Colores del PDF (independientes del theme dinámico de la app, para que
  // el documento compartido se vea igual sin importar de qué canción salió)
  // ---------------------------------------------------------------------
  static final PdfColor _chordColor = PdfColor.fromInt(0xFF7EA0B0); // steelBlue
  static final PdfColor _keywordColor = PdfColor.fromInt(0xFFC9A24B); // gold
  static final PdfColor _textColor = PdfColors.black;
  static final PdfColor _titleColor = PdfColor.fromInt(0xFF1B1E23); // charcoal

  // Tamaño de fuente para letra/acordes. Debe ser el mismo en todos los
  // spans (texto, acordes, keywords) para no romper el alineado calibrado.
  static const double _lyricsFontSize = 10.5;

  // A partir de cuántas líneas de letra se activa el layout en 2 columnas.
  static const int _maxLineasUnaColumna = 40;

  // Márgenes de página reducidos para ganar ancho útil.
  static const pw.EdgeInsets _pageMargin = pw.EdgeInsets.only(
    left: 14,
    right: 14,
    top: 24,
    bottom: 24,
  );

  // Fuente monoespaciada cacheada tras la primera carga, para no releer el
  // asset en cada canción cuando se genera un repertorio con varias.
  static pw.Font? _monoFont;

  static Future<pw.Font> _loadMonoFont() async {
    if (_monoFont != null) return _monoFont!;
    final data = await rootBundle.load('assets/fonts/RobotoMono-Regular.ttf');
    _monoFont = pw.Font.ttf(data);
    return _monoFont!;
  }

  // =======================================================================
  // API PÚBLICA
  // =======================================================================

  /// Genera el PDF a partir de una lista de canciones YA ORDENADA tal como
  /// el usuario las seleccionó. El orden de [canciones] se respeta de
  /// principio a fin, tanto en el índice de la portada como en las páginas.
  ///
  /// [categoriaDe] es opcional: si se provee, se usa para mostrar una
  /// pequeña etiqueta de categoría junto a cada canción en el índice de la
  /// portada (por ejemplo "Adoración" / "Alabanza"), sin que esto afecte
  /// el orden de las canciones.
  ///
  /// [tituloRepertorio] es el nombre del evento/repertorio, si aplica.
  static Future<Uint8List> generate({
    required List<Song> canciones,
    String? Function(Song song)? categoriaDe,
    String? tituloRepertorio,
  }) async {
    final monoFont = await _loadMonoFont();

    final doc = pw.Document();
    final tieneTitulo =
        tituloRepertorio != null && tituloRepertorio.trim().isNotEmpty;
    final mostrarPortada = canciones.length > 1 || tieneTitulo;

    if (mostrarPortada) {
      doc.addPage(
        _buildPortada(canciones, categoriaDe, tituloRepertorio),
      );
    }

    for (final cancion in canciones) {
      doc.addPage(_buildSongDocument(cancion, monoFont));
    }

    return doc.save();
  }

  // =======================================================================
  // PORTADA
  // =======================================================================

  static pw.Page _buildPortada(
    List<Song> canciones,
    String? Function(Song song)? categoriaDe,
    String? titulo,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 60),
            pw.Text(
              titulo?.isNotEmpty == true ? titulo! : 'Repertorio',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: _titleColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'MCLV MusicApp',
              style: pw.TextStyle(fontSize: 12, color: _chordColor),
            ),
            pw.SizedBox(height: 30),
            pw.Divider(color: _keywordColor, thickness: 2),
            pw.SizedBox(height: 20),
            ..._buildIndice(canciones, categoriaDe),
          ],
        );
      },
    );
  }

  /// Construye el índice de la portada respetando EXACTAMENTE el orden de
  /// [canciones]. Si [categoriaDe] devuelve un valor no nulo para una
  /// canción, se muestra como etiqueta a la derecha del título.
  static List<pw.Widget> _buildIndice(
    List<Song> canciones,
    String? Function(Song song)? categoriaDe,
  ) {
    final widgets = <pw.Widget>[];

    for (var i = 0; i < canciones.length; i++) {
      final song = canciones[i];
      final categoria = categoriaDe?.call(song);

      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Row(
            children: [
              pw.Container(
                width: 24,
                child: pw.Text(
                  '${i + 1}.',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: _chordColor,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  song.title,
                  style: pw.TextStyle(fontSize: 13, color: _textColor),
                ),
              ),
              if (categoria != null && categoria.isNotEmpty)
                pw.Container(
                  margin: const pw.EdgeInsets.only(right: 8),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF5F1E8), // cream
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(
                    categoria,
                    style: pw.TextStyle(fontSize: 9, color: _chordColor),
                  ),
                ),
              pw.Text(
                song.tonalidad,
                style: pw.TextStyle(
                  fontSize: 11,
                  color: _chordColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  // =======================================================================
  // PÁGINA(S) DE CANCIÓN
  // =======================================================================

  /// Construye el `MultiPage` de una canción. Se usa `MultiPage` (en vez de
  /// `Page`) precisamente para que, si la letra no cabe en una sola página,
  /// el motor de layout continúe automáticamente en las siguientes sin
  /// lanzar la excepción de "Widget won't fit into the page".
  static pw.MultiPage _buildSongDocument(Song cancion, pw.Font monoFont) {
    final lineas = cancion.text.split('\n');
    final usarDosColumnas = lineas.length > _maxLineasUnaColumna;

    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: _pageMargin,
      header: (context) => context.pageNumber == 1
          ? _buildEncabezado(cancion)
          : pw.SizedBox(),
      // El contenido se entrega como una lista de widgets pequeños: uno por
      // línea (una columna), o un widget de 2 columnas POR BLOQUE de
      // líneas que sí cabe en una página (dos columnas). Ningún widget
      // individual es tan grande como para no caber en una página, así
      // `MultiPage` puede seguir fluyendo de una página a la siguiente sin
      // saltos abruptos ni límite de longitud.
      build: (context) => usarDosColumnas
          ? _buildLyricsEnDosColumnas(lineas, monoFont)
          : _buildLyricsUnaColumna(lineas, monoFont),
    );
  }

  /// Encabezado con título, tonalidad y tiempo. Ocupa el ancho completo de
  /// la página, incluso cuando la letra se reparte en dos columnas.
  static pw.Widget _buildEncabezado(Song cancion) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          cancion.title,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: _titleColor,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            _buildTag('Tonalidad: ${cancion.tonalidad}'),
            pw.SizedBox(width: 10),
            if (cancion.tiempo > 0) _buildTag('${cancion.tiempo} bpm'),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildTag(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F1E8), // cream
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, color: _chordColor),
      ),
    );
  }

  // =======================================================================
  // RENDERIZADO DE LETRA + ACORDES
  // =======================================================================

  /// Layout de una sola columna: una lista plana de widgets, uno por línea.
  /// `MultiPage` los va acomodando y partiendo entre páginas según haga
  /// falta.
  static List<pw.Widget> _buildLyricsUnaColumna(
    List<String> lineas,
    pw.Font monoFont,
  ) {
    return lineas
        .map((linea) => _buildLineaWidget(linea, monoFont))
        .toList(growable: false);
  }

  /// Altura aproximada, en puntos PDF, de una línea de letra/acordes.
  /// `_lyricsFontSize` es el tamaño de fuente; 1.15 es un interlineado
  /// razonable para texto monoespaciado. Se usa solo para ESTIMAR cuántas
  /// líneas caben en una página en 2 columnas — no necesita ser exacta,
  /// solo lo bastante conservadora para no pasarse.
  static const double _alturaLineaAprox = _lyricsFontSize * 1.15;

  /// Alto disponible de página en 2 columnas, restando márgenes y el
  /// espacio típico del encabezado (que solo aparece en la página 1, pero
  /// usamos su alto como margen de seguridad en todas para simplificar el
  /// cálculo y quedarnos cortos antes que pasarnos).
  static const double _altoEncabezadoAprox = 110;

  /// Layout de dos columnas, empaquetado por SECCIONES completas (CORO,
  /// VERSO, PUENTE, etc.) para que ninguna palabra clave quede cortada a
  /// mitad de camino entre una columna y la siguiente, ni entre una página
  /// y la siguiente.
  ///
  /// Cómo funciona:
  /// 1. La letra se agrupa en "secciones": cada sección empieza en una
  ///    línea que contiene una palabra clave (CORO/VERSO/PUENTE/etc.) — o
  ///    al principio del texto si antes de la primera palabra clave ya hay
  ///    líneas — y termina justo antes de la siguiente palabra clave. Cada
  ///    sección se trata como una unidad indivisible: o entra completa en
  ///    la columna actual, o pasa entera a la siguiente.
  /// 2. Se empaqueta con un algoritmo simple tipo "greedy": se van
  ///    metiendo secciones en la columna izquierda mientras quepan: si una
  ///    sección no entra, se prueba la columna derecha del mismo bloque;
  ///    si tampoco entra ahí, el bloque (la "página" de 2 columnas) se
  ///    cierra ahí mismo — usando solo el espacio que realmente se llenó,
  ///    sin desperdiciar el resto — y se abre un bloque nuevo empezando
  ///    por esa sección.
  ///
  /// Esto evita los dos problemas que resolvía el enfoque anterior de
  /// "líneas fijas por bloque": cortar una sección a mitad de camino, y
  /// dejar espacio en blanco de sobra cuando en realidad cabía más letra.
  static List<pw.Widget> _buildLyricsEnDosColumnas(
  List<String> lineas,
  pw.Font monoFont,
) {
  final double altoUtil =
      PdfPageFormat.a4.height - _pageMargin.vertical - _altoEncabezadoAprox;
  final int lineasPorColumna =
      (altoUtil / _alturaLineaAprox).floor().clamp(10, 300);

  final secciones = _agruparEnSecciones(lineas);

  final widgets = <pw.Widget>[];
  List<List<String>> izquierda = [];
  List<List<String>> derecha = [];
  int lineasIzq = 0;
  int lineasDer = 0;

  void cerrarBloque() {
    if (izquierda.isEmpty && derecha.isEmpty) return;

    pw.Widget buildCol(List<List<String>> secs) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: secs
              .expand((s) => s)
              .map((l) => _buildLineaWidget(l, monoFont))
              .toList(),
        );

    widgets.add(pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: buildCol(izquierda)),
        pw.SizedBox(width: 18),
        pw.Expanded(child: buildCol(derecha)),
      ],
    ));

    izquierda = [];
    derecha = [];
    lineasIzq = 0;
    lineasDer = 0;
  }

  for (final seccion in secciones) {
    // Si la sección es gigante (excede una columna), la partimos línea a línea
    if (seccion.length > lineasPorColumna) {
      cerrarBloque(); // cierra lo que haya acumulado antes
      // Entregar línea por línea directamente a MultiPage (no en Row de 2 col)
      for (final linea in seccion) {
        widgets.add(_buildLineaWidget(linea, monoFont));
      }
      continue;
    }

    // Sección normal: intentar meterla en izquierda, luego derecha
    if (lineasIzq + seccion.length <= lineasPorColumna) {
      izquierda.add(seccion);
      lineasIzq += seccion.length;
    } else if (lineasDer + seccion.length <= lineasPorColumna) {
      derecha.add(seccion);
      lineasDer += seccion.length;
    } else {
      // Ambas columnas llenas — cerrar bloque y empezar nuevo
      cerrarBloque();
      izquierda.add(seccion);
      lineasIzq += seccion.length;
    }
  }

  cerrarBloque();
  return widgets;
}

  /// Agrupa las líneas de una canción en secciones indivisibles: cada
  /// sección empieza en una línea que contiene una palabra clave
  /// (CORO/VERSO/PUENTE/etc., usando el mismo `_keywordRegex` que colorea
  /// el texto) y se extiende hasta justo antes de la siguiente palabra
  /// clave, o hasta el final del texto. Si hay líneas antes de la primera
  /// palabra clave (ej. una intro sin encabezado), forman su propia
  /// sección inicial.
  static List<List<String>> _agruparEnSecciones(List<String> lineas) {
    final secciones = <List<String>>[];
    List<String> actual = [];

    for (final linea in lineas) {
      final esInicioDeSeccion = _keywordRegex.hasMatch(linea);
      if (esInicioDeSeccion && actual.isNotEmpty) {
        secciones.add(actual);
        actual = [linea];
      } else {
        actual.add(linea);
      }
    }

    if (actual.isNotEmpty) {
      secciones.add(actual);
    }

    return secciones;
  }

  /// Construye el widget de una única línea de letra/acordes, coloreando
  /// acordes y palabras clave, y reutilizando la MISMA fuente monoespaciada
  /// y el MISMO tamaño para todos los spans (texto, acordes, keywords), de
  /// forma que el ancho de cada carácter sea idéntico sin importar su rol.
  /// Esto es lo que mantiene el alineado que el usuario calibra a mano.
  static pw.Widget _buildLineaWidget(String linea, pw.Font monoFont) {
    if (linea.isEmpty) {
      // Preserva líneas en blanco (separación entre estrofas).
      return pw.SizedBox(height: _lyricsFontSize * 1.15);
    }

    final spans = <pw.TextSpan>[];

    final matches = <RegExpMatch>[
      ..._keywordRegex.allMatches(linea),
      ..._chordRegex.allMatches(linea),
    ]..sort((a, b) => a.start.compareTo(b.start));

    int current = 0;

    for (final match in matches) {
      if (match.start > current) {
        spans.add(
          pw.TextSpan(
            text: linea.substring(current, match.start),
            style: pw.TextStyle(font: monoFont, fontSize: _lyricsFontSize),
          ),
        );
      }

      final token = match.group(0)!;

      spans.add(
        pw.TextSpan(
          text: token,
          style: pw.TextStyle(
            font: monoFont,
            fontSize: _lyricsFontSize,
            color: _chordRegex.hasMatch(token) ? _chordColor : _keywordColor,
          ),
        ),
      );

      current = match.end;
    }

    if (current < linea.length) {
      spans.add(
        pw.TextSpan(
          text: linea.substring(current),
          style: pw.TextStyle(font: monoFont, fontSize: _lyricsFontSize),
        ),
      );
    }

    return pw.RichText(text: pw.TextSpan(children: spans));
  }
}