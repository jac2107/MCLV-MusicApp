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
// la app. Esto garantiza que el espaciado manual calibrado con barra
// espaciadora se vea IGUAL en la app y en el PDF compartido.
//
// LÓGICA DE COLUMNAS
// ------------------
// - Si la canción tiene acordes alineados (líneas de "solo acordes" con
//   espacios para posicionarlos sobre la letra), se renderiza en 1 columna
//   siempre — porque reducir el ancho a la mitad rompería el alineado.
// - Si NO tiene acordes alineados (solo letra, o acordes simples al inicio
//   de línea) Y supera _maxLineasUnaColumna líneas, se usa 2 columnas,
//   partiendo por secciones (CORO/VERSO/PUENTE/etc.) para no cortar a
//   mitad de una estrofa.
// - En ambos casos, MultiPage recibe widgets individuales por línea (nunca
//   un widget gigante), así puede paginar sin lanzar "Widget won't fit".

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/Mcanciones.dart';

class SongPdfGenerator {
  SongPdfGenerator._();

  // -----------------------------------------------------------------------
  // Reconocimiento de acordes / palabras clave
  // Mismos patrones que en Vcanciones.dart — si cambias uno, cambia el otro.
  // -----------------------------------------------------------------------
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
    r'\b(?:CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?: \d+)?|PRE-CORO|CORO 1 Y 2|'
    r'CORO AUMENTADO|CORO(?: \d+)?|ESTRIBILLO|INSTRUMENTAL|FINAL|ESTROFA|'
    r'SOLO|PUENTE(?: \d+)?|BAJO|SALIDA(?: \d+)?)\b',
  );

  // -----------------------------------------------------------------------
  // Colores del PDF
  // -----------------------------------------------------------------------
  static final PdfColor _chordColor   = PdfColor.fromInt(0xFF7EA0B0);
  static final PdfColor _keywordColor = PdfColor.fromInt(0xFFC9A24B);
  static final PdfColor _textColor    = PdfColors.black;
  static final PdfColor _titleColor   = PdfColor.fromInt(0xFF1B1E23);

  static const double _lyricsFontSize      = 10.5;
  static const int    _maxLineasUnaColumna = 40;

  static const pw.EdgeInsets _pageMargin = pw.EdgeInsets.only(
    left: 14, right: 14, top: 24, bottom: 24,
  );

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
      doc.addPage(_buildPortada(canciones, categoriaDe, tituloRepertorio));
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
                    horizontal: 6, vertical: 2,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF5F1E8),
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

  static pw.MultiPage _buildSongDocument(Song cancion, pw.Font monoFont) {
    final lineas = cancion.text.split('\n');

    // Si tiene acordes alineados con espacios → siempre 1 columna para
    // no romper el posicionado manual sobre la letra.
    // Si no tiene acordes alineados y es larga → 2 columnas.
    final usarDosColumnas =
        lineas.length > _maxLineasUnaColumna &&
        !_tieneAcordesAlineados(lineas);

    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: _pageMargin,
      header: (context) => context.pageNumber == 1
          ? _buildEncabezado(cancion)
          : pw.SizedBox(),
      build: (context) => usarDosColumnas
          ? _buildLyricsEnDosColumnas(lineas, monoFont)
          : _buildLyricsUnaColumna(lineas, monoFont),
    );
  }

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
        color: PdfColor.fromInt(0xFFF5F1E8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, color: _chordColor),
      ),
    );
  }

  // =======================================================================
  // DETECCIÓN DE ACORDES ALINEADOS
  // =======================================================================

  /// Devuelve true si la canción tiene 3 o más líneas de "solo acordes"
  /// (tokens no-espacio que son todos acordes válidos). Esas líneas usan
  /// espacios para posicionarse sobre la letra — reducir el ancho a la
  /// mitad rompería ese alineado, así que la canción va a 1 columna.
  static bool _tieneAcordesAlineados(List<String> lineas) {
    int contador = 0;
    for (final linea in lineas) {
      final trimmed = linea.trim();
      if (trimmed.isEmpty) continue;
      if (_keywordRegex.hasMatch(trimmed)) continue;
      final tokens = trimmed.split(RegExp(r'\s+'));
      final todosAcordes = tokens.every(
        (t) => t.isEmpty || _chordRegex.hasMatch(t) || t == '-',
      );
      if (todosAcordes && tokens.isNotEmpty) {
        contador++;
        if (contador >= 3) return true;
      }
    }
    return false;
  }

  // =======================================================================
  // RENDERIZADO DE LETRA — 1 COLUMNA
  // =======================================================================

  /// Una lista plana de widgets, uno por línea. MultiPage los pagina solo.
  static List<pw.Widget> _buildLyricsUnaColumna(
    List<String> lineas,
    pw.Font monoFont,
  ) {
    return lineas
        .map((linea) => _buildLineaWidget(linea, monoFont))
        .toList(growable: false);
  }

  // =======================================================================
  // RENDERIZADO DE LETRA — 2 COLUMNAS
  // =======================================================================

  static const double _alturaLineaAprox   = _lyricsFontSize * 1.15;
  static const double _altoEncabezadoAprox = 110;

  /// Construye la letra en 2 columnas respetando cortes por sección
  /// (CORO/VERSO/PUENTE/etc.). Entrega a MultiPage una lista de Rows
  /// individuales de una línea — nunca un Row gigante que no cabe en página.
  ///
  /// Algoritmo:
  /// 1. Agrupa líneas en secciones por palabra clave.
  /// 2. Llena colIzq con secciones completas hasta el límite; el resto
  ///    va a colDer. Si una sección no cabe en ninguna (es gigante), se
  ///    parte línea a línea como fallback.
  /// 3. Empareja colIzq[i] con colDer[i] en Rows individuales → MultiPage
  ///    puede paginar entre cualquier par de filas sin problema.
  static List<pw.Widget> _buildLyricsEnDosColumnas(
    List<String> lineas,
    pw.Font monoFont,
  ) {
    final double altoUtil =
        PdfPageFormat.a4.height - _pageMargin.vertical - _altoEncabezadoAprox;
    final int lineasPorColumna =
        (altoUtil / _alturaLineaAprox).floor().clamp(10, 300);

    final secciones = _agruparEnSecciones(lineas);

    final List<String> colIzq = [];
    final List<String> colDer = [];

    for (final seccion in secciones) {
      if (colIzq.length + seccion.length <= lineasPorColumna) {
        // Cabe en la izquierda
        colIzq.addAll(seccion);
      } else if (colDer.length + seccion.length <= lineasPorColumna) {
        // No cabe en izquierda pero sí en derecha
        colDer.addAll(seccion);
      } else {
        // Sección gigante o ambas llenas: partir línea a línea como fallback
        for (final linea in seccion) {
          if (colIzq.length < lineasPorColumna) {
            colIzq.add(linea);
          } else {
            colDer.add(linea);
          }
        }
      }
    }

    // Emparejar fila a fila → Rows pequeños que MultiPage puede paginar
    final widgets = <pw.Widget>[];
    final totalFilas = colIzq.length > colDer.length
        ? colIzq.length
        : colDer.length;

    for (int i = 0; i < totalFilas; i++) {
      final lineaIzq = i < colIzq.length ? colIzq[i] : '';
      final lineaDer = i < colDer.length ? colDer[i] : '';

      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _buildLineaWidget(lineaIzq, monoFont)),
            pw.SizedBox(width: 18),
            pw.Expanded(child: _buildLineaWidget(lineaDer, monoFont)),
          ],
        ),
      );
    }

    return widgets;
  }

  // =======================================================================
  // AGRUPACIÓN EN SECCIONES
  // =======================================================================

  /// Agrupa líneas en secciones: cada sección empieza con una palabra clave
  /// (CORO/VERSO/PUENTE/ESTRIBILLO/etc.) y llega hasta la siguiente.
  static List<List<String>> _agruparEnSecciones(List<String> lineas) {
    final secciones = <List<String>>[];
    List<String> actual = [];

    for (final linea in lineas) {
      if (_keywordRegex.hasMatch(linea) && actual.isNotEmpty) {
        secciones.add(actual);
        actual = [linea];
      } else {
        actual.add(linea);
      }
    }

    if (actual.isNotEmpty) secciones.add(actual);

    return secciones;
  }

  // =======================================================================
  // WIDGET DE LÍNEA INDIVIDUAL
  // =======================================================================

  /// Construye una línea coloreando acordes (azul) y keywords (dorado),
  /// usando siempre la misma fuente monoespaciada y el mismo tamaño para
  /// mantener el alineado calibrado manualmente.
  static pw.Widget _buildLineaWidget(String linea, pw.Font monoFont) {
    if (linea.isEmpty) {
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
        spans.add(pw.TextSpan(
          text: linea.substring(current, match.start),
          style: pw.TextStyle(font: monoFont, fontSize: _lyricsFontSize),
        ));
      }

      final token = match.group(0)!;
      final esAcorde = _chordRegex.hasMatch(token);

      spans.add(pw.TextSpan(
        text: token,
        style: pw.TextStyle(
          font: monoFont,
          fontSize: _lyricsFontSize,
          color: esAcorde ? _chordColor : _keywordColor,
        ),
      ));

      current = match.end;
    }

    if (current < linea.length) {
      spans.add(pw.TextSpan(
        text: linea.substring(current),
        style: pw.TextStyle(font: monoFont, fontSize: _lyricsFontSize),
      ));
    }

    return pw.RichText(text: pw.TextSpan(children: spans));
  }
}