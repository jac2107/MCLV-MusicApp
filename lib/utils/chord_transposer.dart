// lib/utils/chord_transposer.dart
//
// Transpone TODOS los acordes de un texto de canción por una cantidad de
// semitonos, dejando intacta la letra y las palabras clave (CORO, VERSO,
// etc.). Usa el mismo regex/lógica que parseLyrics()/transposeChord() en
// Vcanciones.dart — si cambias el regex en un lado, cámbialo en el otro.
//
// Pensado para transposición "de una sola vez" (por ejemplo, al generar un
// PDF con una tonalidad distinta a la guardada), a diferencia del
// transposeValue en vivo de Vcanciones.dart que solo cambia lo que se ve
// en pantalla sin tocar el texto.

final String _suffix =
    r'(?:maj7|maj|min|dim7|dim|aug|sus\d*|add\d*|m7|m9|m6|m|[°+])?';
final String _bassPart = r'(?:\/[A-G][#b]?' + _suffix + r'\d*)*';
final String _chordUnit = r'[A-G][#b]?' + _suffix + r'\d*' + _bassPart;

final RegExp _chordRegex = RegExp(
  r'(?:(?<=^)|(?<=\s))' +
      '(?:$_chordUnit)' +
      '(?:-(?:$_chordUnit))*' +
      r'(?:(?=$)|(?=[\s/]))',
);

const List<String> _sharpScale = [
  'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
];
const List<String> _flatScale = [
  'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
];

/// Transpone un solo acorde (ej. "C#m7") por [semitones]. Reutilizado tanto
/// para acordes sueltos dentro del texto como para el nombre de la
/// tonalidad general de la canción.
String transposeChordToken(String chord, int semitones) {
  if (semitones == 0) return chord;

  if (chord.contains('-')) {
    return chord.split('-').map((c) => transposeChordToken(c, semitones)).join('-');
  }
  if (chord.contains('/')) {
    return chord.split('/').map((c) => transposeChordToken(c, semitones)).join('/');
  }

  final m = RegExp(r'^([A-G][#b]?)(.*)$').firstMatch(chord);
  if (m == null) return chord;
  final root = m.group(1)!;
  final suffix = m.group(2)!;

  int index = _sharpScale.indexOf(root);
  bool hadSharp = true;
  if (index == -1) {
    index = _flatScale.indexOf(root);
    hadSharp = false;
  }
  if (index == -1) return chord;

  int newIndex = (index + semitones) % 12;
  if (newIndex < 0) newIndex += 12;

  final List<String> outScale = semitones > 0
      ? _sharpScale
      : semitones < 0
          ? _flatScale
          : (hadSharp ? _sharpScale : _flatScale);

  return '${outScale[newIndex]}$suffix';
}

/// Transpone TODOS los acordes dentro de un texto completo de canción
/// (letra + acordes + keywords), por [semitones]. La letra y las palabras
/// clave (CORO, VERSO, etc.) quedan intactas — solo se tocan los tokens
/// que matchean como acordes.
String transposeSongText(String text, int semitones) {
  if (semitones == 0) return text;

  final buffer = StringBuffer();

  for (final line in text.split('\n')) {
    int currentIndex = 0;
    for (final match in _chordRegex.allMatches(line)) {
      buffer.write(line.substring(currentIndex, match.start));
      buffer.write(transposeChordToken(match.group(0)!, semitones));
      currentIndex = match.end;
    }
    buffer.write(line.substring(currentIndex));
    buffer.write('\n');
  }

  // El split/join agrega un '\n' extra al final; lo recortamos para no
  // acumular saltos de línea de más respecto al texto original.
  final result = buffer.toString();
  return result.endsWith('\n') ? result.substring(0, result.length - 1) : result;
}

/// Transpone el nombre de la tonalidad general (ej. "E" -> "F#" con +2),
/// para que el PDF muestre la tonalidad correcta en la cabecera.
String transposeKeyName(String tonalidad, int semitones) {
  if (semitones == 0 || tonalidad.trim().isEmpty) return tonalidad;
  return transposeChordToken(tonalidad.trim(), semitones);
}