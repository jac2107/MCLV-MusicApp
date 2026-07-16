import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/Mcanciones.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Vcanciones extends StatefulWidget {
  final Song cancion;

  const Vcanciones({super.key, required this.cancion});

  @override
  _VcancionesState createState() => _VcancionesState();
}

class _VcancionesState extends State<Vcanciones> {
  late Future<String> _thumbnailFuture;
  bool isMetronomePlaying = false;
  int transposeValue = 0;
  final int originalTransposeValue = 0;
  bool showTransposeButtons = false;
  final AudioPlayer player = AudioPlayer();
  bool isMultitrackPlaying = false;
  bool isMultitrackVisible = false; 
  bool isAutoscrollActive = false;
  bool showSpeedOptions = false;
  double scrollSpeed = 1.0; 


  late YoutubePlayerController _multitrackController; 
  late YoutubePlayerController _youtubeController; 

  final ScrollController _scrollController = ScrollController();
  Timer? _autoscrollTimer;

  Color? primaryColor;
  Color? secondaryColor;
  Color? accentColor;

  bool showInstrumentLinks = false; 
  String? currentInstrument; 
  String? videoId;
  bool _isContentVisible = false; // Estado para controlar la visibilidad del contenido
bool _metronomeRunning = false;
int _intervalMs = 0;
late DateTime _metronomeStart;
Timer? _metronomeTimer;
  @override
void initState() {
  super.initState();
  _initializeYoutubeControllers();
  _thumbnailFuture = _getThumbnailUrl();
  _extractColorsFromImage();

  // Simula carga de 2 segundos para mostrar el contenido
  Future.delayed(Duration(seconds: 2), () {
    setState(() {
      _isContentVisible = true;
    });
  });
  
  // Precargar el sonido para minimizar la latencia
  // Asegúrate de que el asset esté declarado en pubspec.yaml
  player.setSource(AssetSource('sounds/metronome_tick.mp3'));
}

Future<String> _getThumbnailUrl() async {
  final String extractedId = _safeExtractVideoId(widget.cancion.youtubeLink);
  if (extractedId.isNotEmpty) {
    videoId = extractedId;
    final String maxresUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    final String fallbackUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

    try {
      final response = await http.get(Uri.parse(maxresUrl));
      if (response.statusCode == 200) {
        return maxresUrl; // Devuelve la miniatura si existe
      } else {
        return fallbackUrl; // Si no existe, devuelve el primer fotograma
      }
    } catch (e) {
      // Manejo de errores: devuelve la imagen predeterminada en caso de error
      print('Error al obtener la miniatura: $e'); // Imprime el error en la consola
    }
  }
  return 'assets/image.png'; // Si no hay enlace, retorna la imagen predeterminada
}

  /// Extrae el ID de video de un link de YouTube de forma segura.
  /// Antes se usaba `convertUrlToId(...)!` con force-unwrap: si el link tenía
  /// un formato inválido (typo, link roto, etc.), convertUrlToId devolvía null
  /// y el "!" hacía crashear la app. Ahora simplemente devuelve '' en ese caso.
  String _safeExtractVideoId(String? link) {
    if (link == null || link.isEmpty || link == "null") return '';
    try {
      return YoutubePlayer.convertUrlToId(link) ?? '';
    } catch (e) {
      return '';
    }
  }

  void _initializeYoutubeControllers() {
    _multitrackController = YoutubePlayerController(
      initialVideoId: _safeExtractVideoId(widget.cancion.multitrackLink),
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

   _youtubeController = YoutubePlayerController(
  initialVideoId: _safeExtractVideoId(widget.cancion.youtubeLink),
  flags: const YoutubePlayerFlags(
    autoPlay: false,
    mute: false,
  ),
);

// Widget que contiene el reproductor con gestos
GestureDetector(
  onDoubleTap: () {
    _youtubeController.seekTo(_youtubeController.value.position + Duration(seconds: 10));
  },
  onLongPress: () {
    _youtubeController.setPlaybackRate(2.0); // Aumentar velocidad a x2
  },
  onLongPressEnd: (_) {
    _youtubeController.setPlaybackRate(1.0); // Volver a velocidad normal
  },
  child: YoutubePlayer(
    controller: _youtubeController,
    showVideoProgressIndicator: true,
  ),
);

  }

  Future<void> _extractColorsFromImage() async {
    String thumbnailUrl = await _thumbnailFuture;

    if (thumbnailUrl.isNotEmpty) {
      // Clave de caché: por videoId si existe, si no por título (fallback estable).
      final String cacheKey = 'song_colors_${videoId ?? widget.cancion.title}';
      final prefs = await SharedPreferences.getInstance();
      final String? cached = prefs.getString(cacheKey);

      if (cached != null) {
        // Ya calculamos los colores de esta canción antes: reusarlos sin
        // volver a descargar la miniatura ni recalcular la paleta.
        final parts = cached.split(',');
        if (parts.length == 3) {
          primaryColor = Color(int.parse(parts[0]));
          secondaryColor = Color(int.parse(parts[1]));
          accentColor = Color(int.parse(parts[2]));
          setState(() {});
          return;
        }
      }

      try {
        final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
          NetworkImage(thumbnailUrl),
        );

        Color dominantColor = paletteGenerator.dominantColor?.color ?? Colors.blue;

        primaryColor = dominantColor;
        secondaryColor = _getContrastingColor(lighten(dominantColor, 0.2));
        accentColor = _getContrastingColor(darken(dominantColor, 0.2));

        // Guardar en caché para no repetir este trabajo la próxima vez.
        await prefs.setString(
          cacheKey,
          '${primaryColor!.value},${secondaryColor!.value},${accentColor!.value}',
        );
      } catch (e) {
        primaryColor = Color.fromARGB(255, 0, 0, 0);  // Negro profundo
        secondaryColor = Color.fromARGB(255, 161, 119, 69);  // Dorado oscuro
        accentColor = Color.fromARGB(255, 96, 139, 151);  // Azul grisáceo
      }
    } else {
      primaryColor = Color.fromARGB(255, 0, 0, 0);  // Negro profundo
      secondaryColor = Color.fromARGB(255, 161, 119, 69);  // Dorado oscuro
      accentColor = Color.fromARGB(255, 96, 139, 151);  // Azul grisáceo
    }

    setState(() {});
  }

  Color _getContrastingColor(Color color) {
    // Calcular la luminancia
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    // Si la luminancia es alta, oscurecer el color
    if (luminance > 0.7) {
      return darken(color, 0.3); // Oscurecer el color
    }
    return color; // Retornar el color original si ya es suficientemente oscuro
  }

  Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    return Color.fromARGB(
      color.alpha,
      (color.red + ((255 - color.red) * amount)).toInt(),
      (color.green + ((255 - color.green) * amount)).toInt(),
      (color.blue + ((255 - color.blue) * amount)).toInt(),
    );
  }

  Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - amount)).toInt(),
      (color.green * (1 - amount)).toInt(),
      (color.blue * (1 - amount)).toInt(),
    );
  }

  @override
void dispose() {
  stopMetronome();
  stopAutoscroll();
  player.dispose();
  _multitrackController.dispose();
  _youtubeController.dispose();
  _scrollController.dispose();
  super.dispose();
}

List<TextSpan> parseLyrics(String text) {
  // Unidad base de un acorde individual: raíz + sufijo + dígitos + bajo opcional.
  // '-' se sacó de los sufijos (era ambiguo) porque en tus canciones el guion
  // se usa para UNIR varios acordes pegados sin espacio (ej. "G-A", "F#m-Bm"),
  // no como notación de acorde menor.
  final String _suffix =
      r'(?:maj7|maj|min|dim7|dim|aug|sus\d*|add\d*|m7|m9|m6|m|[°+])?';
  final String _chordUnit =
      r'[A-G][#b]?' + _suffix + r'\d*' + r'(?:\/[A-G][#b]?' + _suffix + r'\d*)?';

  // 1) Regex de acordes: uno o más "_chordUnit" unidos por guiones sin espacio
  //    (ej. "G-A", "D2-A2-G/Em-A-A/G-F#m-Bm"), rodeado de inicio/fin o espacio.
  final chordRegex = RegExp(
    r'(?<=^|\s)' +
    '(?:$_chordUnit)' +
    '(?:-(?:$_chordUnit))*' +
    r'(?=$|\s)'
  );

  // 1b) Versión "anclada" (^...$) para decidir si una LÍNEA COMPLETA es una
  // línea de acordes o una línea de letra normal. Antes el chordRegex se
  // aplicaba token por token sobre cualquier línea, así que una palabra suelta
  // en mayúscula dentro de la letra (ej. una "A" o "E" que sea preposición,
  // no acorde) se pintaba y transponía como si fuera un acorde real.
  final chordOnlyLineToken = RegExp(
    '^(?:(?:$_chordUnit)(?:-(?:$_chordUnit))*|[/|.x]+|-)\$'
  );

  bool _looksLikeChordLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    final tokens = trimmed.split(RegExp(r'\s+'));
    // Es línea de acordes solo si TODOS los tokens no vacíos parecen acordes
    // (o separadores de repetición como "//", "x4", "-" suelto), nunca si hay
    // alguna palabra de letra normal mezclada.
    return tokens.every((t) => chordOnlyLineToken.hasMatch(t));
  }

  // 2) Regex de keywords (igual que antes)
  final keywordRegex = RegExp(
  r'\b(?:CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?: \d+)?|PRE-CORO|CORO 1 Y 2|CORO(?: \d+)?|INSTRUMENTAL|FINAL|ESTROFA|SOLO|PUENTE(?: \d+)?|BAJO|SALIDA(?: \d+)?)\b');

  List<TextSpan> spans = [];

  for (var line in text.split('\n')) {
    final bool isChordLine = _looksLikeChordLine(line);

    final matches = <RegExpMatch>[
      ...keywordRegex.allMatches(line),
      if (isChordLine) ...chordRegex.allMatches(line),
    ]..sort((a, b) => a.start.compareTo(b.start));

    int currentIndex = 0;
    for (var match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: line.substring(currentIndex, match.start),
          style: TextStyle(color: Colors.black),
        ));
      }

      final token = match.group(0)!;
      TextStyle style;
      String rendered;

      if (isChordLine && chordRegex.hasMatch(token)) {
        rendered = transposeChord(token);
        style = TextStyle(
          color: secondaryColor ?? Color(0xFF4A90E2),
          fontWeight: FontWeight.bold,
        );
      } else {
        rendered = token;
        style = TextStyle(
          color: accentColor ?? Color(0xFF4A90E2),
          fontWeight: FontWeight.bold,
        );
      }

      spans.add(TextSpan(text: rendered, style: style));
      currentIndex = match.end;
    }

    if (currentIndex < line.length) {
      spans.add(TextSpan(
        text: line.substring(currentIndex),
        style: TextStyle(color: Colors.black),
      ));
    }
    spans.add(TextSpan(text: '\n'));
  }

  return spans;
}


String transposeChord(String chord) {
  // 0) Soportar cadenas de acordes pegados con guion sin espacio (ej. "G-A",
  //    "D2-A2-G/Em-A-A/G-F#m-Bm"): transponer cada uno por separado.
  if (chord.contains('-')) {
    return chord.split('-').map(transposeChord).join('-');
  }

  // 1) Soportar bajos invertidos (e.g. G/Bb)
  if (chord.contains('/')) {
    final parts = chord.split('/');
    return '${transposeChord(parts[0])}/${transposeChord(parts[1])}';
  }

  // 2) Separar raíz y sufijo
  final m = RegExp(r'^([A-G][#b]?)(.*)$').firstMatch(chord);
  if (m == null) return chord;
  final root = m.group(1)!;   // p.ej. "D", "F#", "Bb"
  final suffix = m.group(2)!; // p.ej. "m7", "maj", ""

  // 3) Listas cíclicas de 12 tonos (ambas formas)
  const sharpScale = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
  const flatScale  = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];

  // 4) Buscar índice en la escala correspondiente al accidental de la raíz
  int index = sharpScale.indexOf(root);
  bool hadSharp = true;
  if (index == -1) {
    index = flatScale.indexOf(root);
    hadSharp = false;
  }
  if (index == -1) return chord; // raíz no reconocida

  // 5) Calcular nuevo índice con wrap-around
  int newIndex = (index + transposeValue) % 12;
  if (newIndex < 0) newIndex += 12;

  // 6) Elegir salida: si sube semitonos, usar sharps; si baja, flats; si 0, respetar original
  List<String> outScale;
  if (transposeValue > 0) {
    outScale = sharpScale;
  } else if (transposeValue < 0) {
    outScale = flatScale;
  } else {
    outScale = hadSharp ? sharpScale : flatScale;
  }

  // 7) Reconstruir acorde transpuesto
  final newRoot = outScale[newIndex];
  return '$newRoot$suffix';
}



  void transpose(int semiTones) {
    setState(() {
      transposeValue += semiTones;
    });
  }

  void resetTranspose() {
    setState(() {
      transposeValue = originalTransposeValue;
    });
  }

  void toggleTransposeButtons() {
    setState(() {
      showTransposeButtons = !showTransposeButtons;
    });
  }

void toggleMetronome() {
  if (widget.cancion.tiempo <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta canción no tiene un tiempo (BPM) configurado, no se puede usar el metrónomo.'),
      ),
    );
    return;
  }
  setState(() {
    isMetronomePlaying = !isMetronomePlaying;
    if (isMetronomePlaying) {
      startMetronome();
      if (isMultitrackPlaying) {
        player.resume();
      }
    } else {
      stopMetronome();
      player.pause();
    }
  });
}

/// Inicia el metrónomo
void startMetronome() {
  if (widget.cancion.tiempo <= 0) {
    _metronomeRunning = false;
    return; // Evita división por cero (Infinity.round() crashea la app)
  }
  _metronomeRunning = true;
  _intervalMs = (60000 / widget.cancion.tiempo).round();
  _metronomeStart = DateTime.now();

  _metronomeTimer?.cancel(); // Asegurarse de que no haya otro Timer corriendo
  _metronomeTimer = Timer.periodic(Duration(milliseconds: _intervalMs), (timer) {
    if (!_metronomeRunning) {
      timer.cancel();
      return;
    }

    // Calcular el tiempo real esperado del tick
    DateTime expectedTickTime = _metronomeStart.add(Duration(milliseconds: timer.tick * _intervalMs));
    Duration drift = expectedTickTime.difference(DateTime.now());

    // Si hay un retraso acumulado, lo corregimos
    if (drift.isNegative) {
      drift = Duration.zero; // Evita que los ticks se acumulen más lento
    }

    // Reproducir el sonido del metrónomo sin retraso
    player.play(AssetSource('sounds/metronome_tick.mp3'));

    // Si el drift es alto, ajustar el siguiente tick
    if (drift.inMilliseconds.abs() > 10) {
      _metronomeTimer?.cancel();
      _metronomeTimer = Timer(Duration(milliseconds: _intervalMs - drift.inMilliseconds), startMetronome);
    }
  });
}

void stopMetronome() {
  _metronomeRunning = false;
  _metronomeTimer?.cancel();
}

/// Método que mantiene el BPM exacto usando tiempo absoluto


Future<void> playMetronomeSound() async {
  await player.play(AssetSource('sounds/metronome_tick.mp3'));
}
void toggleAutoscroll() {
  setState(() {
    if (isAutoscrollActive) {
      // Si está autoscrolleando y se presiona STOP:
      stopAutoscroll();
      scrollSpeed = 1.0; // Reinicia la velocidad a x1
      showSpeedOptions = true;
    } else {
      // Si no está autoscrolleando y se presiona PLAY:
      isAutoscrollActive = true;
      showSpeedOptions = false;
      startAutoscroll();
    }
  });
}

void startAutoscroll() {
  _autoscrollTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
    if (_scrollController.hasClients) {
      double newOffset = _scrollController.offset + scrollSpeed;
      if (newOffset < _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(newOffset);
      } else {
        // Cuando se alcanza el final, se detiene el autoscroll:
        stopAutoscroll();
      }
    }
  });
}

void stopAutoscroll() {
  _autoscrollTimer?.cancel();
  _autoscrollTimer = null;
  isAutoscrollActive = false;
}


  void setScrollSpeed(double speed) {
    setState(() {
      scrollSpeed = speed;
      if (speed == 0) {
        stopAutoscroll(); 
      } else {
        if (!isAutoscrollActive) {
          isAutoscrollActive = true; 
          startAutoscroll(); 
        }
      }
      showSpeedOptions = false; 
    });
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white10, // Fondo sutil para mejorar el diseño
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  // Método auxiliar para cambiar el instrumento actual
  void _selectInstrument(String instrument) {
    setState(() {
      showInstrumentLinks = true;
      currentInstrument = instrument;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _thumbnailFuture, // Usa la variable _thumbnailFuture ya inicializada
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()), // Puedes cambiar esto si deseas
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar la imagen'));
        } else {
          String thumbnailUrl = snapshot.data ?? '';

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                widget.cancion.title,
                style: TextStyle(fontSize: 20),
              ),
              backgroundColor: primaryColor ?? const Color(0xFF1B263B),
              foregroundColor: Colors.white,
              actions: [
                if (widget.cancion.instrument != 0)
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: Icon(Icons.menu, color: Colors.black),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),
              ],
            ),
            endDrawer: Drawer(
              child: Container(
                color: secondaryColor ?? Colors.black54,
                child: Column(
                  children: [
                    // Cabecera con imagen y degradado
                    Container(
                      height: 200,
                      child: Stack(
                        children: [
                          // Imagen de fondo: usa la thumbnail si existe; de lo contrario, una imagen predeterminada de assets
                          Positioned.fill(
                            child: thumbnailUrl.isNotEmpty
                                ? Image.network(
                                    thumbnailUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/image.png', // Imagen predeterminada en caso de error
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/image.png', // Imagen predeterminada
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                          // Capa de degradado para oscurecer la parte inferior
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Texto "INSTRUMENTOS" cuando no hay thumbnail
                          if (thumbnailUrl.isEmpty)
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  'INSTRUMENTOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Menú de opciones con ListView
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        children: [
                          _buildMenuItem(
                            icon: Icons.home,
                            title: 'Página Principal',
                            onTap: () {
                              setState(() {
                                showInstrumentLinks = false;
                                currentInstrument = null;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          Divider(color: Colors.white24),
                          if (widget.cancion.voicesLinks != null &&
                              widget.cancion.voicesLinks!.isNotEmpty)
                            _buildMenuItem(
                              icon: Icons.mic,
                              title: 'Voces',
                              onTap: () => _selectInstrument('voices'),
                            ),
                          if (widget.cancion.guitarLink != null &&
                              widget.cancion.guitarLink!.isNotEmpty)
                            _buildMenuItem(
                              icon: Icons.music_note,
                              title: 'Guitarra',
                              onTap: () => _selectInstrument('guitar'),
                            ),
                          if (widget.cancion.pianoLink != null &&
                              widget.cancion.pianoLink!.isNotEmpty)
                            _buildMenuItem(
                              icon: Icons.piano,
                              title: 'Piano',
                              onTap: () => _selectInstrument('piano'),
                            ),
                          if (widget.cancion.bassLink != null &&
                              widget.cancion.bassLink!.isNotEmpty)
                            _buildMenuItem(
                              icon: Icons.audiotrack,
                              title: 'Bajo',
                              onTap: () => _selectInstrument('bass'),
                            ),
                          if (widget.cancion.drumsLink != null &&
                              widget.cancion.drumsLink!.isNotEmpty)
                            _buildMenuItem(
                              icon: FontAwesomeIcons.drum,
                              title: 'Batería',
                              onTap: () => _selectInstrument('drums'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: AnimatedOpacity(
              opacity: _isContentVisible ? 1.0 : 0.0,
              duration: Duration(seconds: 1), // Duración de la transición
              child: showInstrumentLinks
                  ? CustomScrollView(
                      key: ValueKey(currentInstrument),
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 200,
                          pinned: true,
                          automaticallyImplyLeading: false,
                          leading: Container(),
                          flexibleSpace: FlexibleSpaceBar(
                            background: thumbnailUrl.isNotEmpty
                              ? Image.network(
                                  thumbnailUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/image.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/image.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                      ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              if (currentInstrument == 'voices' && widget.cancion.voicesLinks != null)
                                ...widget.cancion.voicesLinks!.map((voiceLink) {
                                  String? voiceVideoId = YoutubePlayer.convertUrlToId(voiceLink);
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        YoutubePlayer(
                                          controller: YoutubePlayerController(
                                            initialVideoId: voiceVideoId!,
                                            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
                                          ),
                                          showVideoProgressIndicator: true,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              if (currentInstrument == 'guitar' && widget.cancion.guitarLink != null)
                                ...widget.cancion.guitarLink!.map((guitarLink) {
                                  String? guitarVideoId = YoutubePlayer.convertUrlToId(guitarLink);
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        YoutubePlayer(
                                          controller: YoutubePlayerController(
                                            initialVideoId: guitarVideoId!,
                                            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
                                          ),
                                          showVideoProgressIndicator: true,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              if (currentInstrument == 'piano' && widget.cancion.pianoLink != null)
                                ...widget.cancion.pianoLink!.map((pianoLink) {
                                  String? pianoVideoId = YoutubePlayer.convertUrlToId(pianoLink);
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        YoutubePlayer(
                                          controller: YoutubePlayerController(
                                            initialVideoId: pianoVideoId!,
                                            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
                                          ),
                                          showVideoProgressIndicator: true,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              if (currentInstrument == 'bass' && widget.cancion.bassLink != null)
                                ...widget.cancion.bassLink!.map((bassLink) {
                                  String? bassVideoId = YoutubePlayer.convertUrlToId(bassLink);
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        YoutubePlayer(
                                          controller: YoutubePlayerController(
                                            initialVideoId: bassVideoId!,
                                            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
                                          ),
                                          showVideoProgressIndicator: true,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              if (currentInstrument == 'drums' && widget.cancion.drumsLink != null)
                                ...widget.cancion.drumsLink!.map((drumsLink) {
                                  String? drumsVideoId = YoutubePlayer.convertUrlToId(drumsLink);
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        YoutubePlayer(
                                          controller: YoutubePlayerController(
                                            initialVideoId: drumsVideoId!,
                                            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
                                          ),
                                          showVideoProgressIndicator: true,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ],
                    )
                  : CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        if (thumbnailUrl.isNotEmpty)
                       SliverToBoxAdapter(
  child: Container(
    color: Color.fromARGB(255, 255, 255, 255), // Fondo con el color hexadecimal #d5d6d1
    child: Stack(
      children: [
        Image.network(
          thumbnailUrl,
          fit: BoxFit.cover, 
          height: 200.0, // Mantén la altura fija
          width: double.infinity, // Esto hace que la imagen ocupe todo el ancho disponible
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/icono.png', // Imagen predeterminada en caso de error
              fit: BoxFit.contain, // Asegura que la imagen se ajuste dentro del espacio sin deformarse
              height: 200.0,
              width: double.infinity,
            );
          },
        ),
        // Degradado negro desde abajo
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80.0, // Ajusta la altura del degradado
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5), // Negro con algo de opacidad
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
)


                      else
                        SliverToBoxAdapter(
                          child: Image.asset(
                            'assets/image.png',
                            fit: BoxFit.cover,
                            height: 200.0,
                            width: double.infinity,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    if (widget.cancion.multitrackLink != null && widget.cancion.multitrackLink!.isNotEmpty)
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isMultitrackVisible = !isMultitrackVisible;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentColor  ?? Colors.grey,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          isMultitrackVisible ? "OCULTAR" : "MULTITRACK",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    if (isMultitrackVisible)
                                      Column(
                                        children: [
                                          YoutubePlayerBuilder(
                                            player: YoutubePlayer(
                                              controller: _multitrackController,
                                              showVideoProgressIndicator: false,
                                            ),
                                            builder: (context, player) {
                                              return Column(
                                                children: [
                                                  Opacity(
                                                    opacity: 0.0,
                                                    child: SizedBox(height: 1, child: player),
                                                  ),
                                                  ValueListenableBuilder(
                                                    valueListenable: _multitrackController,
                                                    builder: (context, YoutubePlayerValue value, child) {
                                                      bool isReady = value.isReady; 
                                                      return Column(
                                                        children: [
                                                          Slider(
                                                            value: value.position.inSeconds.toDouble(),
                                                            min: 0,
                                                            max: value.metaData.duration.inSeconds.toDouble(),
                                                            onChanged: isReady ? (newValue) {
                                                              _multitrackController.seekTo(
                                                                Duration(seconds: newValue.toInt()),
                                                              );
                                                            } : null,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(isMultitrackPlaying ? Icons.pause : Icons.play_arrow),
                                                                onPressed: isReady ? () {
                                                                  setState(() {
                                                                    isMultitrackPlaying = !isMultitrackPlaying;
                                                                    if (isMultitrackPlaying) {
                                                                      _multitrackController.play();
                                                                    } else {
                                                                      _multitrackController.pause();
                                                                    }
                                                                  });
                                                                } : null,
                                                              ),
                                                              IconButton(
                                                                icon: Icon(Icons.replay_10),
                                                                onPressed: isReady ? () {
                                                                  final currentPosition = _multitrackController.value.position;
                                                                  final newPosition = currentPosition - Duration(seconds: 10);
                                                                  _multitrackController.seekTo(newPosition);
                                                                } : null,
                                                              ),
                                                              IconButton(
                                                                icon: Icon(Icons.forward_10),
                                                                onPressed: isReady ? () {
                                                                  final currentPosition = _multitrackController.value.position;
                                                                  final newPosition = currentPosition + Duration(seconds: 10);
                                                                  _multitrackController.seekTo(newPosition);
                                                                } : null,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.music_note),
                                          onPressed: toggleTransposeButtons,
                                          padding: EdgeInsets.zero,
                                        ),
                                        SizedBox(width: 5),
                                        AnimatedOpacity(
                                          opacity: showTransposeButtons ? 1.0 : 0.0,
                                          duration: const Duration(milliseconds: 250),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildTransposeButton("+1", 2),
                                              _buildTransposeButton("+½", 1),
                                              _buildTransposeButton("-½", -1),
                                              _buildTransposeButton("-1", -2),
                                              _buildTransposeButton("orig", 0, isReset: true),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        IconButton(
                                          icon: Icon(isMetronomePlaying ? Icons.pause : Icons.play_arrow),
                                          onPressed: toggleMetronome,
                                          color: widget.cancion.tiempo <= 0 ? Colors.grey : null,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                    if (showSpeedOptions)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildSpeedButton("x0.5", 0.5),
                                          _buildSpeedButton("x0.75", 0.75),
                                          _buildSpeedButton("x1", 1.0),
                                          _buildSpeedButton("x1.25", 1.25),
                                          _buildSpeedButton("x1.5", 1.5),
                                          _buildSpeedButton("STOP", 0),
                                        ],
                                      ),
                                    const SizedBox(height: 0),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                                        children: parseLyrics(widget.cancion.text),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    if (widget.cancion.youtubeLink != null && widget.cancion.youtubeLink != "null")
  Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: GestureDetector(
      onDoubleTap: () {
        _youtubeController.seekTo(
          _youtubeController.value.position + Duration(seconds: 10),
        );
      },
      onLongPress: () {
        _youtubeController.setPlaybackRate(2.0); // Aumenta velocidad a x2
      },
      onLongPressEnd: (_) {
        _youtubeController.setPlaybackRate(1.0); // Vuelve a velocidad normal
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          YoutubePlayer(
            controller: _youtubeController,
            showVideoProgressIndicator: true,
          ),
          ValueListenableBuilder(
            valueListenable: _youtubeController,
            builder: (context, YoutubePlayerValue value, child) {
              if (!value.isPlaying) {
                return IconButton(
                  icon: Icon(Icons.play_arrow, size: 64, color: Colors.white),
                  onPressed: () {
                    _youtubeController.play();
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    ),
  ),
const SizedBox(height: 20),

                                  ],
                                ),
                              );
                            },
                            childCount: 1,
                          ),
                        ),
                      ],
                    ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: toggleAutoscroll,
              child: Icon(isAutoscrollActive ? Icons.pause : Icons.play_arrow),
              backgroundColor: isAutoscrollActive ? secondaryColor ?? Color.fromARGB(255, 50, 86, 151) : Colors.white,
            ),
          );
        }
      },
    );
  }  

  Widget _buildSpeedButton(String text, double speed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => setScrollSpeed(speed),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: scrollSpeed == speed ? secondaryColor ?? Color.fromARGB(255, 42, 69, 118) : Colors.grey,
            borderRadius: BorderRadius.circular(80),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTransposeButton(String label, int semiTones, {bool isReset = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          if (isReset) {
            resetTranspose();
          } else {
            transpose(semiTones);
          }
        },
        borderRadius: BorderRadius.circular(500),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0x00000000),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}