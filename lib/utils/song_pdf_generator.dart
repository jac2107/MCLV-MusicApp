// lib/utils/song_pdf_generator.dart

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/Mcanciones.dart';

class SongPdfGenerator {
  SongPdfGenerator._();

  // -----------------------------------------------------------------------
  // Reconocimiento de acordes / palabras clave
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
    r'\b(?:VERSO(?: \d+)?|PRE-CORO|CORO 1 Y 2|'
    r'CORO AUMENTADO|CORO(?: \d+)?|ESTRIBILLO|INSTRUMENTAL|GUITARRA|FINAL|ESTROFA|'
    r'SOLO|PUENTE(?: \d+)?|BAJO|SALIDA(?: \d+)?)\b',
  );

  // -----------------------------------------------------------------------
  // Colores
  // -----------------------------------------------------------------------
  static final PdfColor _chordColor   = PdfColor.fromInt(0xFF7EA0B0);
  static final PdfColor _keywordColor = PdfColor.fromInt(0xFFC9A24B);
  static final PdfColor _textColor    = PdfColors.black;
  static final PdfColor _titleColor   = PdfColor.fromInt(0xFF1B1E23);

  static const double _lyricsFontSize = 10.5;

  static const pw.EdgeInsets _pageMargin = pw.EdgeInsets.symmetric(
    horizontal: 36,
    vertical: 36,
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
      doc.addPage(_buildSongPage(cancion, monoFont));
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
      build: (context) => pw.Column(
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
      ),
    );
  }

  static List<pw.Widget> _buildIndice(
    List<Song> canciones,
    String? Function(Song song)? categoriaDe,
  ) {
    return List.generate(canciones.length, (i) {
      final song = canciones[i];
      final categoria = categoriaDe?.call(song);
      return pw.Padding(
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
      );
    });
  }

  // =======================================================================
  // PÁGINA DE CANCIÓN — MultiPage, 1 columna, corte por secciones
  // =======================================================================

 static pw.MultiPage _buildSongPage(Song cancion, pw.Font monoFont) {
  final lineas = cancion.text.split('\n');
  final secciones = _agruparEnSecciones(lineas);

  // Altura aproximada por línea (fuente 10.5 + leading)
  const double altLinea = 10.5 * 1.4;
  const double altSeparador = 10;
  const double altEncabezado = 90;
  final double altPagina =
      PdfPageFormat.a4.height - _pageMargin.vertical - altEncabezado;

  return pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: _pageMargin,
    header: (context) => context.pageNumber == 1
        ? _buildEncabezado(cancion)
        : pw.SizedBox(),
    build: (context) {
      final widgets = <pw.Widget>[];
      double altUsada = 0;

      for (int i = 0; i < secciones.length; i++) {
        final seccion = secciones[i];
        final altSeccion = seccion.length * altLinea;
        final altConSep = altSeccion + (i > 0 ? altSeparador : 0);

        // Si no cabe en lo que queda de página → forzar salto
        if (altUsada > 0 && altUsada + altConSep > altPagina) {
          widgets.add(pw.NewPage());
          altUsada = 0;
        }

        if (i > 0 && altUsada > 0) {
          widgets.add(pw.SizedBox(height: altSeparador));
          altUsada += altSeparador;
        }

        for (final linea in seccion) {
          widgets.add(_buildLineaWidget(linea, monoFont));
          altUsada += altLinea;
        }
      }

      return widgets;
    },
  );
}

  // =======================================================================
  // ENCABEZADO
  // =======================================================================

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
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 12),
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
  // SECCIÓN COMO BLOQUE ÚNICO
  // =======================================================================

  /// Toda la sección (VERSO/CORO/PUENTE/etc.) como un pw.Column.
  /// MultiPage lo trata como unidad — si no cabe en el espacio restante
  /// de la página, salta completo a la siguiente.
  static pw.Widget _buildSeccion(List<String> lineas, pw.Font monoFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lineas
          .map((linea) => _buildLineaWidget(linea, monoFont))
          .toList(growable: false),
    );
  }

  // =======================================================================
  // AGRUPACIÓN EN SECCIONES
  // =======================================================================

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

  static pw.Widget _buildLineaWidget(String linea, pw.Font monoFont) {
    if (linea.trim().isEmpty) {
      return pw.SizedBox(height: 5);
    }

    final matches = <RegExpMatch>[
      ..._keywordRegex.allMatches(linea),
      ..._chordRegex.allMatches(linea),
    ]..sort((a, b) => a.start.compareTo(b.start));

    // Eliminar overlaps
    final filtrados = <RegExpMatch>[];
    int lastEnd = 0;
    for (final m in matches) {
      if (m.start >= lastEnd) {
        filtrados.add(m);
        lastEnd = m.end;
      }
    }

    final spans = <pw.TextSpan>[];
    int current = 0;

    for (final match in filtrados) {
      if (match.start > current) {
        spans.add(pw.TextSpan(
          text: linea.substring(current, match.start),
          style: pw.TextStyle(font: monoFont, fontSize: _lyricsFontSize),
        ));
      }
      final token = match.group(0)!;
      final esKeyword = _keywordRegex.hasMatch(token);
      spans.add(pw.TextSpan(
        text: token,
        style: pw.TextStyle(
          font: monoFont,
          fontSize: _lyricsFontSize,
          color: esKeyword ? _keywordColor : _chordColor,
          fontWeight:
              esKeyword ? pw.FontWeight.bold : pw.FontWeight.normal,
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

    return pw.RichText(
      text: pw.TextSpan(children: spans),
      softWrap: false, // preserva espaciado manual de acordes
    );
  }
}