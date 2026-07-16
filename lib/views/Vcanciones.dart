import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/Mcanciones.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Vcanciones extends StatefulWidget {
  final Song cancion;

  const Vcanciones({super.key, required this.cancion});

  @override
  _VcancionesState createState() => _VcancionesState();
}

class _VcancionesState extends State<Vcanciones> {
  // Sube este número para invalidar TODOS los colores cacheados de golpe.
  static const int _colorCacheVersion = 1;

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

  // ====== Manejo de errores de reproducción ======
  // Marca si el controlador principal / multitrack quedó en estado de error
  // (video borrado, privado, bloqueado por región, etc.). Se actualiza vía
  // listener porque YoutubePlayer no lanza excepciones Dart normales para
  // estos casos: expone value.hasError / value.errorCode.
  bool _youtubeHasError = false;
  bool _multitrackHasError = false;

  final ScrollController _scrollController = ScrollController();
  Timer? _autoscrollTimer;

  Color? primaryColor;
  Color? secondaryColor;
  Color? accentColor;

  bool showInstrumentLinks = false;
  String? currentInstrument;
  String? videoId;
  bool _isContentVisible = false;
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });

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
          return maxresUrl;
        } else {
          return fallbackUrl;
        }
      } catch (e) {
        print('Error al obtener la miniatura: $e');
      }
    }
    return 'assets/image.png';
  }

  /// Extrae el ID de video de un link de YouTube de forma segura.
  /// Devuelve '' si el link es nulo, vacío, "null", o si convertUrlToId
  /// no puede parsearlo — así se evita el crash del force-unwrap ('!').
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
    )..addListener(_onMultitrackValueChanged);

    _youtubeController = YoutubePlayerController(
      initialVideoId: _safeExtractVideoId(widget.cancion.youtubeLink),
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    )..addListener(_onYoutubeValueChanged);
  }

  void _onYoutubeValueChanged() {
    final bool hasError = _youtubeController.value.hasError;
    if (hasError != _youtubeHasError) {
      setState(() {
        _youtubeHasError = hasError;
      });
    }
  }

  void _onMultitrackValueChanged() {
    final bool hasError = _multitrackController.value.hasError;
    if (hasError != _multitrackHasError) {
      setState(() {
        _multitrackHasError = hasError;
      });
    }
  }

  Future<void> _openInYoutubeApp(String? link) async {
    if (link == null || link.isEmpty || link == "null") return;
    final Uri? uri = Uri.tryParse(link);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace de YouTube.')),
        );
      }
    }
  }

  /// Widget de reemplazo cuando un video no está disponible: link vacío/roto
  /// (nunca tuvo un ID válido) o hasError=true (existía pero YouTube lo
  /// rechaza: borrado, privado, bloqueado por región, etc.).
  Widget _buildVideoErrorFallback({
    required String message,
    required String? originalLink,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.videocam_off, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          if (originalLink != null && originalLink.isNotEmpty && originalLink != "null") ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _openInYoutubeApp(originalLink),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Abrir en YouTube'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _extractColorsFromImage() async {
    String thumbnailUrl = await _thumbnailFuture;

    if (thumbnailUrl.isNotEmpty) {
      final String cacheKey =
          'song_colors_v${_colorCacheVersion}_${videoId ?? widget.cancion.title}';
      final prefs = await SharedPreferences.getInstance();
      final String? cached = prefs.getString(cacheKey);

      if (cached != null) {
        final parts = cached.split(',');
        if (parts.length == 3) {
          final int? p = int.tryParse(parts[0]);
          final int? s = int.tryParse(parts[1]);
          final int? a = int.tryParse(parts[2]);
          if (p != null && s != null && a != null) {
            primaryColor = Color(p);
            secondaryColor = Color(s);
            accentColor = Color(a);
            if (mounted) setState(() {});
            return;
          } else {
            await prefs.remove(cacheKey);
          }
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

        await prefs.setString(
          cacheKey,
          '${primaryColor!.value},${secondaryColor!.value},${accentColor!.value}',
        );
      } catch (e) {
        primaryColor = const Color.fromARGB(255, 0, 0, 0);
        secondaryColor = const Color.fromARGB(255, 161, 119, 69);
        accentColor = const Color.fromARGB(255, 96, 139, 151);
      }
    } else {
      primaryColor = const Color.fromARGB(255, 0, 0, 0);
      secondaryColor = const Color.fromARGB(255, 161, 119, 69);
      accentColor = const Color.fromARGB(255, 96, 139, 151);
    }

    if (mounted) setState(() {});
  }

  Color _getContrastingColor(Color color) {
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    if (luminance > 0.7) {
      return darken(color, 0.3);
    }
    return color;
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
    _youtubeController.removeListener(_onYoutubeValueChanged);
    _multitrackController.removeListener(_onMultitrackValueChanged);
    _multitrackController.dispose();
    _youtubeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<TextSpan> parseLyrics(String text) {
    // Unidad base de un acorde individual: raíz + sufijo + dígitos + bajo(s) opcional(es).
    final String _suffix =
        r'(?:maj7|maj|min|dim7|dim|aug|sus\d*|add\d*|m7|m9|m6|m|[°+])?';
    // Bajo tras la barra: ahora soporta 0, 1 o VARIAS barras seguidas
    // (ej. "C/E/G"), no solo una. Antes con "(?:...)?" solo se permitía una
    // barra; con "(?:...)*" se permiten encadenadas.
    final String _bassPart =
        r'(?:\/[A-G][#b]?' + _suffix + r'\d*)*';
    final String _chordUnit =
        r'[A-G][#b]?' + _suffix + r'\d*' + _bassPart;

    // Regex de acordes: uno o más "_chordUnit" unidos por guiones sin espacio
    // (ej. "G-A", "D2-A2-G/Em-A-A/G-F#m-Bm"), rodeado de inicio/fin, espacio,
    // o "/" (para casos como "// Dm Bb F C//", donde el último acorde queda
    // pegado sin espacio al separador de repetición "//").
    // IMPORTANTE: se detecta el acorde DONDE APAREZCA en la línea, sin exigir
    // que toda la línea "parezca" de acordes. Se intentó esa restricción antes,
    // pero las intros usan demasiados símbolos distintos como separadores
    // ("...", "....", "//", "////", "x4", "(x4)", "*PIANO*", "(notas del coro)",
    // etc.) y era imposible listarlos todos: cualquier símbolo no contemplado
    // rompía la línea COMPLETA de acordes. Es más robusto reconocer acordes
    // donde aparezcan y simplemente ignorar todo lo que no matchee el patrón.
    final chordRegex = RegExp(
      r'(?:(?<=^)|(?<=\s))' +
      '(?:$_chordUnit)' +
      '(?:-(?:$_chordUnit))*' +
      r'(?:(?=$)|(?=[\s/]))'
    );

    // Regex de keywords (marcadores de sección)
    final keywordRegex = RegExp(
    r'\b(?:CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?: \d+)?|PRE-CORO|CORO 1 Y 2|CORO(?: \d+)?|INSTRUMENTAL|FINAL|ESTROFA|SOLO|PUENTE(?: \d+)?|BAJO|SALIDA(?: \d+)?)\b');

    // Nota: se evaluó proteger la cabecera (CANCIÓN/TONALIDAD/TIEMPO/artista) de
    // la detección de acordes, pero el formato real de las canciones NO es
    // consistente: algunas tienen una línea en blanco después de la cabecera y
    // otras no (ej. "PERDÓN" no la tiene), así que esa protección terminaba
    // ocultando acordes reales del INTRO/primer verso en esas canciones. Se
    // comprobó que los límites estrictos del chordRegex (debe estar rodeado de
    // espacio/inicio/fin/"/") ya evitan por sí solos que palabras como
    // "Marcos", "Brunet" o "Barrientos" se confundan con acordes.

    List<TextSpan> spans = [];

    for (var line in text.split('\n')) {
      final matches = <RegExpMatch>[
        ...keywordRegex.allMatches(line),
        ...chordRegex.allMatches(line),
      ]..sort((a, b) => a.start.compareTo(b.start));

      int currentIndex = 0;
      for (var match in matches) {
        if (match.start > currentIndex) {
          spans.add(TextSpan(
            text: line.substring(currentIndex, match.start),
            style: const TextStyle(color: Colors.black),
          ));
        }

        final token = match.group(0)!;
        TextStyle style;
        String rendered;

        if (chordRegex.hasMatch(token)) {
          rendered = transposeChord(token);
          style = TextStyle(
            color: secondaryColor ?? const Color(0xFF4A90E2),
            fontWeight: FontWeight.bold,
          );
        } else {
          rendered = token;
          style = TextStyle(
            color: accentColor ?? const Color(0xFF4A90E2),
            fontWeight: FontWeight.bold,
          );
        }

        spans.add(TextSpan(text: rendered, style: style));
        currentIndex = match.end;
      }

      if (currentIndex < line.length) {
        spans.add(TextSpan(
          text: line.substring(currentIndex),
          style: const TextStyle(color: Colors.black),
        ));
      }
      spans.add(const TextSpan(text: '\n'));
    }

    return spans;
  }

  String transposeChord(String chord) {
    // 0) Soportar cadenas de acordes pegados con guion sin espacio (ej. "G-A",
    //    "D2-A2-G/Em-A-A/G-F#m-Bm"): transponer cada uno por separado.
    if (chord.contains('-')) {
      return chord.split('-').map(transposeChord).join('-');
    }

    // 1) Soportar bajos invertidos, incluyendo MÚLTIPLES barras (ej. "C/E",
    //    "C/E/G"). Antes solo se tomaban parts[0] y parts[1] y cualquier bajo
    //    extra tras una segunda barra se perdía silenciosamente al transponer.
    //    Ahora se transponen todas las partes, sin importar cuántas haya.
    if (chord.contains('/')) {
      return chord.split('/').map(transposeChord).join('/');
    }

    // 2) Separar raíz y sufijo
    final m = RegExp(r'^([A-G][#b]?)(.*)$').firstMatch(chord);
    if (m == null) return chord;
    final root = m.group(1)!;   // p.ej. "D", "F#", "Bb"
    final suffix = m.group(2)!; // p.ej. "m7", "maj", "sus4", "add9", ""

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

  void startMetronome() {
    if (widget.cancion.tiempo <= 0) {
      _metronomeRunning = false;
      return;
    }
    _metronomeRunning = true;
    _intervalMs = (60000 / widget.cancion.tiempo).round();
    _metronomeStart = DateTime.now();

    _metronomeTimer?.cancel();
    _metronomeTimer = Timer.periodic(Duration(milliseconds: _intervalMs), (timer) {
      if (!_metronomeRunning) {
        timer.cancel();
        return;
      }

      DateTime expectedTickTime = _metronomeStart.add(Duration(milliseconds: timer.tick * _intervalMs));
      Duration drift = expectedTickTime.difference(DateTime.now());

      if (drift.isNegative) {
        drift = Duration.zero;
      }

      player.play(AssetSource('sounds/metronome_tick.mp3'));

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

  Future<void> playMetronomeSound() async {
    await player.play(AssetSource('sounds/metronome_tick.mp3'));
  }

  void toggleAutoscroll() {
    setState(() {
      if (isAutoscrollActive) {
        stopAutoscroll();
        scrollSpeed = 1.0;
        showSpeedOptions = true;
      } else {
        isAutoscrollActive = true;
        showSpeedOptions = false;
        startAutoscroll();
      }
    });
  }

  void startAutoscroll() {
    _autoscrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
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

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  void _selectInstrument(String instrument) {
    setState(() {
      showInstrumentLinks = true;
      currentInstrument = instrument;
    });
    Navigator.pop(context);
  }

  /// Reemplaza el patrón `convertUrlToId(link)!` (force-unwrap inseguro) por
  /// una versión que, si el link es inválido, muestra el fallback en vez de
  /// crashear la app.
  Widget _buildInstrumentPlayer(String link) {
    final String id = _safeExtractVideoId(link);
    if (id.isEmpty) {
      return _buildVideoErrorFallback(
        message: 'Este enlace de instrumento no es válido o está roto.',
        originalLink: link,
      );
    }
    return _InstrumentYoutubePlayer(videoId: id, originalLink: link);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar la imagen'));
        } else {
          String thumbnailUrl = snapshot.data ?? '';

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                widget.cancion.title,
                style: const TextStyle(fontSize: 20),
              ),
              backgroundColor: primaryColor ?? const Color(0xFF1B263B),
              foregroundColor: Colors.white,
              actions: [
                if (widget.cancion.instrument != 0)
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black),
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
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: thumbnailUrl.isNotEmpty
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
                          if (thumbnailUrl.isEmpty)
                            const Positioned.fill(
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
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                          const Divider(color: Colors.white24),
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
              duration: const Duration(seconds: 1),
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
                                ...widget.cancion.voicesLinks!.map((link) => Container(
                                      margin: const EdgeInsets.all(8.0),
                                      child: _buildInstrumentPlayer(link),
                                    )),
                              if (currentInstrument == 'guitar' && widget.cancion.guitarLink != null)
                                ...widget.cancion.guitarLink!.map((link) => Container(
                                      margin: const EdgeInsets.all(8.0),
                                      child: _buildInstrumentPlayer(link),
                                    )),
                              if (currentInstrument == 'piano' && widget.cancion.pianoLink != null)
                                ...widget.cancion.pianoLink!.map((link) => Container(
                                      margin: const EdgeInsets.all(8.0),
                                      child: _buildInstrumentPlayer(link),
                                    )),
                              if (currentInstrument == 'bass' && widget.cancion.bassLink != null)
                                ...widget.cancion.bassLink!.map((link) => Container(
                                      margin: const EdgeInsets.all(8.0),
                                      child: _buildInstrumentPlayer(link),
                                    )),
                              if (currentInstrument == 'drums' && widget.cancion.drumsLink != null)
                                ...widget.cancion.drumsLink!.map((link) => Container(
                                      margin: const EdgeInsets.all(8.0),
                                      child: _buildInstrumentPlayer(link),
                                    )),
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
                              color: const Color.fromARGB(255, 255, 255, 255),
                              child: Stack(
                                children: [
                                  Image.network(
                                    thumbnailUrl,
                                    fit: BoxFit.cover,
                                    height: 200.0,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/icono.png',
                                        fit: BoxFit.contain,
                                        height: 200.0,
                                        width: double.infinity,
                                      );
                                    },
                                  ),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.5),
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
                                    if (widget.cancion.multitrackLink != null &&
                                        widget.cancion.multitrackLink!.isNotEmpty)
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isMultitrackVisible = !isMultitrackVisible;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentColor ?? Colors.grey,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          isMultitrackVisible ? "OCULTAR" : "MULTITRACK",
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    if (isMultitrackVisible)
                                      _multitrackController.initialVideoId.isEmpty
                                          ? _buildVideoErrorFallback(
                                              message: 'El enlace del multitrack no es válido.',
                                              originalLink: widget.cancion.multitrackLink,
                                            )
                                          : _multitrackHasError
                                              ? _buildVideoErrorFallback(
                                                  message: 'El video del multitrack ya no está disponible (puede haber sido eliminado o ser privado).',
                                                  originalLink: widget.cancion.multitrackLink,
                                                )
                                              : Column(
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
                                                                      max: value.metaData.duration.inSeconds.toDouble() > 0
                                                                          ? value.metaData.duration.inSeconds.toDouble()
                                                                          : 1,
                                                                      onChanged: isReady
                                                                          ? (newValue) {
                                                                              _multitrackController.seekTo(
                                                                                Duration(seconds: newValue.toInt()),
                                                                              );
                                                                            }
                                                                          : null,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        IconButton(
                                                                          icon: Icon(isMultitrackPlaying ? Icons.pause : Icons.play_arrow),
                                                                          onPressed: isReady
                                                                              ? () {
                                                                                  setState(() {
                                                                                    isMultitrackPlaying = !isMultitrackPlaying;
                                                                                    if (isMultitrackPlaying) {
                                                                                      _multitrackController.play();
                                                                                    } else {
                                                                                      _multitrackController.pause();
                                                                                    }
                                                                                  });
                                                                                }
                                                                              : null,
                                                                        ),
                                                                        IconButton(
                                                                          icon: const Icon(Icons.replay_10),
                                                                          onPressed: isReady
                                                                              ? () {
                                                                                  final currentPosition = _multitrackController.value.position;
                                                                                  final newPosition = currentPosition - const Duration(seconds: 10);
                                                                                  _multitrackController.seekTo(newPosition);
                                                                                }
                                                                              : null,
                                                                        ),
                                                                        IconButton(
                                                                          icon: const Icon(Icons.forward_10),
                                                                          onPressed: isReady
                                                                              ? () {
                                                                                  final currentPosition = _multitrackController.value.position;
                                                                                  final newPosition = currentPosition + const Duration(seconds: 10);
                                                                                  _multitrackController.seekTo(newPosition);
                                                                                }
                                                                              : null,
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
                                          icon: const Icon(Icons.music_note),
                                          onPressed: toggleTransposeButtons,
                                          padding: EdgeInsets.zero,
                                        ),
                                        const SizedBox(width: 5),
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
                                        const SizedBox(width: 5),
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
                                    if (widget.cancion.youtubeLink != null &&
                                        widget.cancion.youtubeLink != "null" &&
                                        widget.cancion.youtubeLink!.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                        child: _youtubeController.initialVideoId.isEmpty
                                            ? _buildVideoErrorFallback(
                                                message: 'Este enlace de YouTube no es válido o está roto.',
                                                originalLink: widget.cancion.youtubeLink,
                                              )
                                            : _youtubeHasError
                                                ? _buildVideoErrorFallback(
                                                    message: 'Este video ya no está disponible (puede haber sido eliminado, ser privado o estar bloqueado en tu región).',
                                                    originalLink: widget.cancion.youtubeLink,
                                                  )
                                                : GestureDetector(
                                                    onDoubleTap: () {
                                                      _youtubeController.seekTo(
                                                        _youtubeController.value.position + const Duration(seconds: 10),
                                                      );
                                                    },
                                                    onLongPress: () {
                                                      _youtubeController.setPlaybackRate(2.0);
                                                    },
                                                    onLongPressEnd: (_) {
                                                      _youtubeController.setPlaybackRate(1.0);
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
                                                            if (!value.isPlaying && !value.hasError) {
                                                              return IconButton(
                                                                icon: const Icon(Icons.play_arrow, size: 64, color: Colors.white),
                                                                onPressed: () {
                                                                  _youtubeController.play();
                                                                },
                                                              );
                                                            }
                                                            return const SizedBox.shrink();
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
              backgroundColor: isAutoscrollActive ? secondaryColor ?? const Color.fromARGB(255, 50, 86, 151) : Colors.white,
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
            color: scrollSpeed == speed ? secondaryColor ?? const Color.fromARGB(255, 42, 69, 118) : Colors.grey,
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

/// Reproductor aislado para cada link de instrumento (voces/guitarra/piano/
/// bajo/batería). Cada uno crea y gestiona su propio YoutubePlayerController
/// y escucha value.hasError para mostrar el fallback si el video se cayó,
/// en vez de dejar el player roto sin explicación.
class _InstrumentYoutubePlayer extends StatefulWidget {
  final String videoId;
  final String originalLink;

  const _InstrumentYoutubePlayer({
    required this.videoId,
    required this.originalLink,
  });

  @override
  State<_InstrumentYoutubePlayer> createState() => _InstrumentYoutubePlayerState();
}

class _InstrumentYoutubePlayerState extends State<_InstrumentYoutubePlayer> {
  late YoutubePlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    )..addListener(_onValueChanged);
  }

  void _onValueChanged() {
    final bool hasError = _controller.value.hasError;
    if (hasError != _hasError && mounted) {
      setState(() {
        _hasError = hasError;
      });
    }
  }

  Future<void> _openInYoutubeApp() async {
    final Uri? uri = Uri.tryParse(widget.originalLink);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace de YouTube.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Icon(Icons.videocam_off, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'Este video ya no está disponible.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _openInYoutubeApp,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Abrir en YouTube'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}