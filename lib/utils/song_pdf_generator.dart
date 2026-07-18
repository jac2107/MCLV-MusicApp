// lib/utils/song_pdf_generator.dart
//
// Genera un PDF presentable a partir de una o varias canciones.
// - 1 canción: cabecera simple con título/tonalidad/tiempo + letra.
// - 2+ canciones: portada tipo "Repertorio" con el listado, luego cada
//   canción en su propia página (como un medley compartido).
//
// Reutiliza la MISMA lógica de reconocimiento de acordes que Vcanciones.dart
// (regex de acordes + palabras clave como CORO/VERSO/etc.) para que el PDF
// se vea consistente con lo que el usuario ve en la app.

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/Mcanciones.dart';

class SongPdfGenerator {
  SongPdfGenerator._();

  // Mismos patrones que en Vcanciones.dart — si cambias uno, cambia el otro.
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

  // Colores del PDF (independientes del theme dinámico de la app, para que
  // el documento compartido se vea igual sin importar de qué canción salió)
  static final PdfColor _chordColor = PdfColor.fromInt(0xFF7EA0B0); // steelBlue
  static final PdfColor _keywordColor = PdfColor.fromInt(0xFFC9A24B); // gold
  static final PdfColor _textColor = PdfColors.black;
  static final PdfColor _titleColor = PdfColor.fromInt(0xFF1B1E23); // charcoal

  /// Genera el PDF a partir de canciones ya separadas por categoría.
  /// Muestra portada con índice (Adoración primero, luego Alabanza) si hay
  /// más de una canción en total o si el usuario puso un título de evento.
  static Future<Uint8List> generate({
    required List<Song> adoracion,
    required List<Song> alabanza,
    String? tituloRepertorio, // nombre del evento/repertorio, si aplica
  }) async {
    final doc = pw.Document();
    final todas = [...adoracion, ...alabanza];
    final tieneTitulo = tituloRepertorio != null && tituloRepertorio.trim().isNotEmpty;
    final mostrarPortada = todas.length > 1 || tieneTitulo;

    if (mostrarPortada) {
      doc.addPage(_buildPortada(adoracion, alabanza, tituloRepertorio));
    }

    for (final cancion in todas) {
      doc.addPage(_buildSongPage(cancion));
    }

    return doc.save();
  }

  static pw.Page _buildPortada(
    List<Song> adoracion,
    List<Song> alabanza,
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
            ..._buildIndicePorCategoria(adoracion, alabanza),
          ],
        );
      },
    );
  }

  /// Construye el índice de la portada agrupado por categoría
  /// (Adoración primero, luego Alabanza), con numeración propia en cada
  /// grupo.
  static List<pw.Widget> _buildIndicePorCategoria(
    List<Song> adoracion,
    List<Song> alabanza,
  ) {
    final widgets = <pw.Widget>[];

    void agregarGrupo(String titulo, List<Song> lista) {
      if (lista.isEmpty) return;
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
          child: pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _keywordColor,
            ),
          ),
        ),
      );
      for (var i = 0; i < lista.length; i++) {
        final s = lista[i];
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 22,
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
                    s.title,
                    style: pw.TextStyle(fontSize: 13, color: _textColor),
                  ),
                ),
                pw.Text(
                  s.tonalidad,
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
    }

    agregarGrupo('ADORACIÓN', adoracion);
    agregarGrupo('ALABANZA', alabanza);

    return widgets;
  }

  static pw.Page _buildSongPage(Song cancion) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
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
            pw.RichText(text: _buildLyricsRichText(cancion.text)),
          ],
        );
      },
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

  /// Misma lógica de parseLyrics() de Vcanciones.dart, pero produciendo
  /// TextSpan de `package:pdf` en vez de Flutter.
  static pw.TextSpan _buildLyricsRichText(String text) {
    final List<pw.TextSpan> children = [];

    for (final line in text.split('\n')) {
      final matches = <RegExpMatch>[
        ..._keywordRegex.allMatches(line),
        ..._chordRegex.allMatches(line),
      ]..sort((a, b) => a.start.compareTo(b.start));

      int currentIndex = 0;
      for (final match in matches) {
        if (match.start > currentIndex) {
          children.add(pw.TextSpan(
            text: line.substring(currentIndex, match.start),
            style: pw.TextStyle(fontSize: 10.5, color: _textColor),
          ));
        }

        final token = match.group(0)!;
        final bool isChord = _chordRegex.hasMatch(token);

        children.add(pw.TextSpan(
          text: token,
          style: pw.TextStyle(
            fontSize: 10.5,
            color: isChord ? _chordColor : _keywordColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ));
        currentIndex = match.end;
      }

      if (currentIndex < line.length) {
        children.add(pw.TextSpan(
          text: line.substring(currentIndex),
          style: pw.TextStyle(fontSize: 10.5, color: _textColor),
        ));
      }
      children.add(const pw.TextSpan(text: '\n'));
    }

    return pw.TextSpan(children: children);
  }
}