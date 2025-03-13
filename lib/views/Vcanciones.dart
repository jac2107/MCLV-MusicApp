import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/Mcanciones.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class Vcanciones extends StatefulWidget {
  final Song cancion;

  const Vcanciones({super.key, required this.cancion});

  @override
  _VcancionesState createState() => _VcancionesState();
}

class _VcancionesState extends State<Vcanciones> {
  late Future<String> _thumbnailFuture;
  bool isMetronomePlaying = false;
  Timer? metronomeTimer;
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

  @override
  void initState() {
    super.initState();
    _initializeYoutubeControllers();
    _thumbnailFuture = _getThumbnailUrl();
    _extractColorsFromImage();

    // Simular carga de 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isContentVisible = true; // Hacer que el contenido sea visible
      });
    });
  }

  Future<String> _getThumbnailUrl() async {
    if (widget.cancion.youtubeLink != null &&
        widget.cancion.youtubeLink != "null" &&
        widget.cancion.youtubeLink!.isNotEmpty) {
      videoId = YoutubePlayer.convertUrlToId(widget.cancion.youtubeLink!);
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
        return fallbackUrl; // En caso de error, devuelve el primer fotograma
      }
    }
    return ''; // Si no hay enlace, retorna una cadena vacía
  }

  void _initializeYoutubeControllers() {
    _multitrackController = YoutubePlayerController(
      initialVideoId: widget.cancion.multitrackLink != null && widget.cancion.multitrackLink != "null"
          ? YoutubePlayer.convertUrlToId(widget.cancion.multitrackLink!)!
          : '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.cancion.youtubeLink != null && widget.cancion.youtubeLink != "null"
          ? YoutubePlayer.convertUrlToId(widget.cancion.youtubeLink!)!
          : '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  Future<void> _extractColorsFromImage() async {
    String thumbnailUrl = await _thumbnailFuture;

    if (thumbnailUrl.isNotEmpty) {
      try {
        final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
          NetworkImage(thumbnailUrl),
        );

        Color dominantColor = paletteGenerator.dominantColor?.color ?? Colors.blue;

        primaryColor = dominantColor;
        secondaryColor = lighten(dominantColor, 0.2);
        accentColor = darken(dominantColor, 0.2);
      } catch (e) {
        primaryColor = Color.fromARGB(255, 18, 60, 140);
        secondaryColor = Color.fromARGB(255, 50, 86, 151);
        accentColor = Colors.red;
      }
    } else {
      primaryColor = Color.fromARGB(255, 18, 60, 140);
      secondaryColor = Color.fromARGB(255, 50, 86, 151);
      accentColor = Colors.red;
    }

    setState(() {});
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
  final chordRegex = RegExp(r'\b[A-G][#b]?(m|maj|min|dim|aug|sus\d*|7|m7)?\d*\b');
  final keywordRegex = RegExp(r'\b(CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO 1|VERSO|VERSO 2|VERSO 3|PRE-CORO|CORO|INSTRUMENTAL|SOLO|PUENTE)\b');

  List<TextSpan> spans = [];
  text.split('\n').forEach((line) {
    List<TextSpan> lineSpans = [];
    line.split(' ').forEach((word) {
      String transposedWord = word; // Mantener palabra original por defecto

      if (chordRegex.hasMatch(word)) {
        transposedWord = transposeChord(word); // Solo transponer si es un acorde
      }

      TextStyle textStyle;
      if (chordRegex.hasMatch(word)) {
        textStyle = TextStyle(color: primaryColor ?? Color(0xFF4A90E2), fontWeight: FontWeight.bold);
      } else if (keywordRegex.hasMatch(word.toUpperCase())) {
        textStyle = TextStyle(color: secondaryColor ?? Color(0xFF4A90E2), fontWeight: FontWeight.bold);
      } else {
        textStyle = TextStyle(color: Colors.black);
      }

      lineSpans.add(TextSpan(text: '$transposedWord ', style: textStyle));
    });
    spans.add(TextSpan(text: '\n'));
    spans.addAll(lineSpans);
  });
  return spans;
}


String transposeChord(String chord) {
  const List<String> chordList = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  const List<String> chordListFlat = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

  // Si el acorde tiene un bajo invertido (ejemplo: G/Em, A/C#)
  if (chord.contains('/')) {
    List<String> parts = chord.split('/');
    if (parts.length == 2) {
      String transposedRoot = transposeChord(parts[0]); // Transponer el primer acorde
      String transposedBass = transposeChord(parts[1]); // Transponer el acorde del bajo
      return '$transposedRoot/$transposedBass';
    }
  }

  // Expresión regular mejorada para capturar correctamente los acordes
  final chordRegex = RegExp(r'^([A-G][#b]?)(.*)$');

  final match = chordRegex.firstMatch(chord);
  if (match == null) return chord;

  String baseChord = match.group(1)!; // Raíz del acorde
  String suffix = match.group(2)!; // Sufijo (m, 7, sus4, etc.)

  int index = chordList.indexOf(baseChord);
  if (index == -1) {
    index = chordListFlat.indexOf(baseChord);
  }

  if (index == -1) return chord; // Si no se encuentra, devolver el acorde sin cambios

  int newIndex = (index + transposeValue + chordList.length) % chordList.length;
  String transposedChord = chordList[newIndex];

  return transposedChord + suffix;
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

  void startMetronome() {
    final bpm = widget.cancion.tiempo;
    final interval = Duration(milliseconds: (60000 / bpm).round());
    metronomeTimer = Timer.periodic(interval, (timer) {
      playMetronomeSound();
    });
  }

  void stopMetronome() {
    metronomeTimer?.cancel();
    metronomeTimer = null;
  }

  Future<void> playMetronomeSound() async {
    await player.play(AssetSource('sounds/metronome_tick.mp3'));
  }

  void toggleAutoscroll() {
    setState(() {
      isAutoscrollActive = !isAutoscrollActive;
      showSpeedOptions = !isAutoscrollActive; 
      scrollSpeed = 1.0; 
      if (isAutoscrollActive) {
        startAutoscroll(); 
      } else {
        stopAutoscroll(); 
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
                    Container(
                      height: 200,
                      color: Color(0xFF1B263B),
                      child: thumbnailUrl.isNotEmpty
                          ? Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Center(
                              child: Text(
                                'INSTRUMENTOS',
                                style: TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ListTile(
                            title: const Text('Página Principal', style: TextStyle(color: Colors.white)),
                            onTap: () {
                              setState(() {
                                showInstrumentLinks = false;
                                currentInstrument = null;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          if (widget.cancion.voicesLinks != null && widget.cancion.voicesLinks!.isNotEmpty)
                            ListTile(
                              title: const Text('Voces', style: TextStyle(color: Colors.white)),
                              onTap: () {
                                setState(() {
                                  showInstrumentLinks = true;
                                  currentInstrument = 'voices';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          if (widget.cancion.guitarLink != null && widget.cancion.guitarLink!.isNotEmpty)
                            ListTile(
                              title: const Text('Guitarra', style: TextStyle(color: Colors.white)),
                              onTap: () {
                                setState(() {
                                  showInstrumentLinks = true;
                                  currentInstrument = 'guitar';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          if (widget.cancion.pianoLink != null && widget.cancion.pianoLink!.isNotEmpty)
                            ListTile(
                              title: const Text('Piano', style: TextStyle(color: Colors.white)),
                              onTap: () {
                                setState(() {
                                  showInstrumentLinks = true;
                                  currentInstrument = 'piano';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          if (widget.cancion.bassLink != null && widget.cancion.bassLink!.isNotEmpty)
                            ListTile(
                              title: const Text('Bajo', style: TextStyle(color: Colors.white)),
                              onTap: () {
                                setState(() {
                                  showInstrumentLinks = true;
                                  currentInstrument = 'bass';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          if (widget.cancion.drumsLink != null && widget.cancion.drumsLink!.isNotEmpty)
                            ListTile(
                              title: const Text('Batería', style: TextStyle(color: Colors.white)),
                              onTap: () {
                                setState(() {
                                  showInstrumentLinks = true;
                                  currentInstrument = 'drums';
                                });
                                Navigator.pop(context);
                              },
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
                            background: Image.network(
                              thumbnailUrl,
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
                            child: Image.network(
                              thumbnailUrl,
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
                                          backgroundColor: secondaryColor ?? Colors.grey,
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
                                        child: YoutubePlayer(
                                          controller: YoutubePlayerController(
                                            initialVideoId: YoutubePlayer.convertUrlToId(widget.cancion.youtubeLink!)!,
                                            flags: const YoutubePlayerFlags(
                                              autoPlay: false,
                                              mute: false,
                                            ),
                                          ),
                                          showVideoProgressIndicator: true,
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