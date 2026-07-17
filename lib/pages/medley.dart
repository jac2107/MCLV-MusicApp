import 'package:flutter/material.dart';
import '../models/Mcanciones.dart';
import 'categoria_page.dart';

// ====================== Medley (modelo) ======================
class Medley {
  final String name;
  final List<String> canciones;
  final bool isCustom;

  Medley({required this.name, required this.canciones, this.isCustom = false});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'canciones': canciones,
      'isCustom': isCustom,
    };
  }

  factory Medley.fromMap(Map<String, dynamic> map) {
    return Medley(
      name: map['name'] as String,
      canciones: List<String>.from(map['canciones'] as List),
      isCustom: map['isCustom'] as bool,
    );
  }
}

// ====================== CrearMedleyPage ======================
class CrearMedleyPage extends StatefulWidget {
  final CategoriaConfig config;
  final Medley? medley;
  const CrearMedleyPage({Key? key, required this.config, this.medley}) : super(key: key);

  @override
  _CrearMedleyPageState createState() => _CrearMedleyPageState();
}

class _CrearMedleyPageState extends State<CrearMedleyPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedSongs = [];
  final ScrollController _scrollController = ScrollController();

  bool _showNameError = false;

  @override
  void initState() {
    super.initState();
    if (widget.medley != null) {
      _nameController.text = widget.medley!.name;
      _selectedSongs.addAll(widget.medley!.canciones);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    setState(() {
      _showNameError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medley == null ? "Crear Medley" : "Editar Medley"),
        backgroundColor: widget.config.primaryColor,
        foregroundColor: widget.config.foregroundColor,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nombre del Medley",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _showNameError ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _showNameError ? Colors.red : Colors.blue,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty && _showNameError) {
                  setState(() {
                    _showNameError = false;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Selecciona las canciones (el orden en que las toques será el orden del medley):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.config.cancionesCompletas.length,
              itemBuilder: (context, index) {
                Song song = widget.config.cancionesCompletas[index];
                bool isSelected = _selectedSongs.contains(song.title.toUpperCase());
                return CheckboxListTile(
                  title: Text(song.title),
                  value: isSelected,
                  onChanged: (bool? newValue) {
                    setState(() {
                      if (newValue == true) {
                        if (!_selectedSongs.contains(song.title.toUpperCase())) {
                          _selectedSongs.add(song.title.toUpperCase());
                        }
                      } else {
                        _selectedSongs.remove(song.title.toUpperCase());
                      }
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isEmpty) {
                _showError("Falta ingresar el nombre del medley.");
                return;
              }
              if (_selectedSongs.isEmpty) {
                _showError("Debes seleccionar al menos una canción.");
                return;
              }
              Medley nuevoMedley = Medley(
                name: _nameController.text,
                canciones: List.from(_selectedSongs),
                isCustom: true,
              );
              Navigator.pop(context, nuevoMedley);
            },
            child: Text(widget.medley == null ? "Guardar" : "Actualizar"),
          ),
        )
      ],
    );
  }
}

// ====================== MedleyDetailPage ======================
class MedleyDetailPage extends StatelessWidget {
  final CategoriaConfig config;
  final Medley medley;
  const MedleyDetailPage({Key? key, required this.config, required this.medley}) : super(key: key);

  List<Song> getSongsForMedley() {
    List<Song> medleySongs = [];
    for (var title in medley.canciones) {
      try {
        Song song = config.cancionesCompletas.firstWhere(
          (s) => s.title.toUpperCase() == title.toUpperCase(),
        );
        medleySongs.add(song);
      } catch (e) {
        // Ignorar si no se encuentra.
      }
    }
    return medleySongs;
  }

  final Color primaryColor = const Color.fromARGB(255, 0, 0, 0);
  final Color secondaryColor = const Color.fromARGB(255, 161, 119, 69);
  final Color accentColor = const Color.fromARGB(255, 96, 139, 151);

  // NOTA: igual que en el original, esta función no transpone nada todavía.
  String transposeChord(String chord) {
    return chord;
  }

  List<TextSpan> parseLyrics(String text) {
    final chordRegex = RegExp(r'\b[A-G][#b]?(m|maj|min|dim|aug|sus\d*|7|m7)?\d*\b');
    final keywordRegex = RegExp(
        r'\b(CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?:\s\d+)?|PRE-CORO|CORO(?:\s\d+)?|INSTRUMENTAL|FINAL|ESTROFA|SOLO|PUENTE(?:\s\d+)?)\b');
    List<TextSpan> spans = [];
    for (final line in text.split('\n')) {
      List<TextSpan> lineSpans = [];
      for (final word in line.split(' ')) {
        String transposedWord = word;
        if (chordRegex.hasMatch(word)) {
          transposedWord = transposeChord(word);
        }
        TextStyle textStyle;
        if (chordRegex.hasMatch(word)) {
          textStyle = TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
          );
        } else if (keywordRegex.hasMatch(word.toUpperCase())) {
          textStyle = TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
          );
        } else {
          textStyle = TextStyle(color: primaryColor);
        }
        lineSpans.add(TextSpan(text: '$transposedWord ', style: textStyle));
      }
      spans.add(const TextSpan(text: '\n'));
      spans.addAll(lineSpans);
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final List<Song> medleySongs = getSongsForMedley();
    return Scaffold(
      appBar: AppBar(
        title: Text(medley.name),
        backgroundColor: config.primaryColor,
        foregroundColor: config.foregroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: medleySongs.map((song) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18),
                      children: parseLyrics(song.text),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}