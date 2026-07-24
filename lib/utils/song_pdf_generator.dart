// lib/utils/song_pdf_generator.dart
//
// Genera un PDF presentable a partir de una o varias canciones.
// - 1 canción: cabecera simple con título/tonalidad/tiempo + letra.
// - 2+ canciones: portada tipo "Repertorio" con el listado (en el MISMO
//   orden en que el usuario las seleccionó), luego cada canción en su
//   propia página.
//
// IMPORTANTE:
// Se utiliza Roboto Mono (fuente monoespaciada) para garantizar
// el alineado perfecto de acordes y letra.

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/Mcanciones.dart';

class SongPdfGenerator {
  SongPdfGenerator._();

  // ---------------------------------------------------------------------
  // Reconocimiento de acordes / palabras clave
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
  // Colores del PDF
  // ---------------------------------------------------------------------
  static final PdfColor _chordColor = PdfColor.fromInt(0xFF7EA0B0); // steelBlue
  static final PdfColor _keywordColor = PdfColor.fromInt(0xFFC9A24B); // gold
  static final PdfColor _textColor = PdfColors.black;
  static final PdfColor _titleColor = PdfColor.fromInt(0xFF1B1E23); // charcoal

  static const double _lyricsFontSize = 10.0;

  // Altura máxima de la columna utilizable en A4 (en puntos)
  static const double _maxColumnaHeightPrimeraPagina = 680.0;
  static const double _maxColumnaHeightPaginaSiguiente = 750.0;

  static const pw.EdgeInsets _pageMargin = pw.EdgeInsets.only(
    left: 16,
    right: 16,
    top: 20,
    bottom: 20,
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
    // Normalizar saltos de línea
    final textLimpio = cancion.text.replaceAll('\r\n', '\n');
    
    // Dividir en secciones/bloques usando las líneas en blanco
    final rawBloques = textLimpio.split(RegExp(r'\n\s*\n'));
    final bloques = rawBloques
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: _pageMargin,
      header: (context) => context.pageNumber == 1
          ? _buildEncabezado(cancion)
          : pw.SizedBox(),
      build: (context) {
        final widgets = <pw.Widget>[];
        int offset = 0;
        bool esPrimeraPagina = true;

        while (offset < bloques.length) {
          final maxAlt = esPrimeraPagina
              ? _maxColumnaHeightPrimeraPagina
              : _maxColumnaHeightPaginaSiguiente;

          // 1. Llenar Columna Izquierda con bloques enteros
          final colIzquierda = <String>[];
          double altColIzquierda = 0;

          while (offset < bloques.length) {
            final bloque = bloques[offset];
            final altBloque = _estimarAlturaBloque(bloque);

            if (altColIzquierda + altBloque <= maxAlt || colIzquierda.isEmpty) {
              colIzquierda.add(bloque);
              altColIzquierda += altBloque;
              offset++;
            } else {
              break;
            }
          }

          // 2. Si quedan bloques, llenar Columna Derecha
          final colDerecha = <String>[];
          double altColDerecha = 0;

          while (offset < bloques.length) {
            final bloque = bloques[offset];
            final altBloque = _estimarAlturaBloque(bloque);

            if (altColDerecha + altBloque <= maxAlt || colDerecha.isEmpty) {
              // Si de por sí cabe en una sola columna todo lo que queda, preferimos 1 columna
              if (colDerecha.isEmpty && (altColIzquierda + altBloque <= maxAlt * 1.1)) {
                break;
              }
              colDerecha.add(bloque);
              altColDerecha += altBloque;
              offset++;
            } else {
              break;
            }
          }

          // Renderizar según si se usó la columna derecha o no
          if (colDerecha.isEmpty) {
            widgets.add(_buildColumnaBloques(colIzquierda, monoFont));
          } else {
            widgets.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: _buildColumnaBloques(colIzquierda, monoFont)),
                  pw.SizedBox(width: 16),
                  pw.Expanded(child: _buildColumnaBloques(colDerecha, monoFont)),
                ],
              ),
            );
          }

          esPrimeraPagina = false;
        }

        return widgets;
      },
    );
  }

  /// Estima la altura en puntos de un bloque completo de estrofa
  static double _estimarAlturaBloque(String bloque) {
    final lineas = bloque.split('\n');
    // Altura por línea + margen vertical inferior del bloque
    return (lineas.length * (_lyricsFontSize * 1.25)) + 12.0;
  }

  static pw.Widget _buildColumnaBloques(List<String> bloques, pw.Font monoFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: bloques.map((b) => _buildBloqueWidget(b, monoFont)).toList(),
    );
  }

  static pw.Widget _buildBloqueWidget(String bloque, pw.Font monoFont) {
    final lineas = bloque.split('\n');
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: lineas.map((l) => _buildLineaWidget(l, monoFont)).toList(),
      ),
    );
  }

  static pw.Widget _buildEncabezado(Song cancion) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          cancion.title,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: _titleColor,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            _buildTag('Tonalidad: ${cancion.tonalidad}'),
            pw.SizedBox(width: 8),
            if (cancion.tiempo > 0) _buildTag('${cancion.tiempo} bpm'),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: PdfColors.grey400, thickness: 0.8),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildTag(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F1E8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, color: _chordColor),
      ),
    );
  }

  // =======================================================================
  // RENDERIZADO DE LÍNEA DE TEXTO Y ACORDES
  // =======================================================================

  static pw.Widget _buildLineaWidget(String linea, pw.Font monoFont) {
    if (linea.trim().isEmpty) {
      return pw.SizedBox(height: _lyricsFontSize * 1.1);
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