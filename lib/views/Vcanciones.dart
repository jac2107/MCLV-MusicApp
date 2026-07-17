import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/Mcanciones.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_theme.dart';
class Vcanciones extends StatefulWidget {
  final Song cancion;

  const Vcanciones({super.key, required this.cancion});

  @override
  _VcancionesState createState() => _VcancionesState();
}

class _VcancionesState extends State<Vcanciones> {
  // Sube este número para invalidar TODOS los colores cacheados de golpe.
  static const int _colorCacheVersion = 1;

  // Máximo de miniaturas guardadas en disco (LRU: se borra la más antigua
  // al superar este límite). Cubre bien el repertorio típico que se repite
  // semana a semana sin dejar crecer el almacenamiento indefinidamente.
  static const int _maxCachedThumbnails = 40;
  static const String _thumbnailOrderKey = 'thumbnail_cache_order';

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

  YoutubePlayerController? _multitrackController;
  YoutubePlayerController? _youtubeController;

  bool _youtubeHasError = false;
  bool _multitrackHasError = false;

  // ====== Estado de conectividad ======
  // null = todavía no se verificó; true/false = resultado de la última
  // verificación. Se usa para decidir si vale la pena intentar instanciar
  // los reproductores de YouTube en absoluto, en vez de dejarlos "cargando"
  // indefinidamente sin internet.
  bool? _hasConnection;

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
    _checkConnectionAndInit();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });

    player.setSource(AssetSource('sounds/metronome_tick.mp3'));
  }

  Future<void> _checkConnectionAndInit() async {
    final bool hasConnection = await _checkConnection();
    if (!mounted) return;
    setState(() {
      _hasConnection = hasConnection;
    });

    // La miniatura se intenta cargar siempre: si está cacheada en disco de
    // una visita anterior, se muestra igual aunque no haya internet ahora.
    _thumbnailFuture = _getThumbnailUrl();
    _extractColorsFromImage();

    // Los reproductores de YouTube solo se instancian si hay conexión.
    // Sin esto, YoutubePlayerController intenta cargar igual y se queda
    // "esperando" sin avisar nada al usuario.
    if (hasConnection) {
      _initializeYoutubeControllers();
    }
  }

  Future<bool> _checkConnection() async {
    try {
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      // Si el chequeo falla por algún motivo, asumimos que sí hay conexión
      // y dejamos que el propio player/http fallen con su manejo de error
      // normal, en vez de bloquear al usuario por un falso negativo.
      return true;
    }
  }

  Future<void> _retryConnection() async {
    final bool hasConnection = await _checkConnection();
    if (!mounted) return;
    setState(() {
      _hasConnection = hasConnection;
    });
    if (hasConnection && _youtubeController == null) {
      _initializeYoutubeControllers();
      setState(() {});
    }
  }

  /// Carpeta local donde se guardan los archivos de miniaturas cacheadas.
  Future<Directory> _thumbnailCacheDir() async {
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${base.path}/thumbnail_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

static const int _thumbnailCacheVersion = 2; // súbelo cuando cambies la calidad de imagen
  String _thumbnailCacheKey() => 'thumb_v${_thumbnailCacheVersion}_${videoId ?? widget.cancion.title}';
  /// Registra el uso de una miniatura en el orden LRU y borra la más
  /// antigua si se supera el límite de _maxCachedThumbnails.
  Future<void> _touchThumbnailLru(String key) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> order = prefs.getStringList(_thumbnailOrderKey) ?? [];

    order.remove(key);
    order.add(key); // más reciente al final

    if (order.length > _maxCachedThumbnails) {
      final String oldestKey = order.removeAt(0);
      try {
        final Directory dir = await _thumbnailCacheDir();
        final File oldFile = File('${dir.path}/$oldestKey.jpg');
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        // Si falla el borrado no es crítico, simplemente queda un archivo
        // huérfano; no interrumpimos el flujo por esto.
      }
    }

    await prefs.setStringList(_thumbnailOrderKey, order);
  }

  Future<String> _getThumbnailUrl() async {
    final String extractedId = _safeExtractVideoId(widget.cancion.youtubeLink);
    if (extractedId.isEmpty) {
      return 'assets/image.png';
    }
    videoId = extractedId;

    final String cacheKey = _thumbnailCacheKey();
    final Directory dir = await _thumbnailCacheDir();
    final File localFile = File('${dir.path}/$cacheKey.jpg');

    // 1) Si ya existe en disco, se usa directo (sirve incluso sin internet).
    if (await localFile.exists()) {
      await _touchThumbnailLru(cacheKey);
      return localFile.path; // Se distingue de una URL por no empezar con http.
    }

    // 2) Sin conexión y sin caché local: no hay nada que mostrar salvo el
    //    placeholder por defecto.
    if (_hasConnection == false) {
      return 'assets/image.png';
    }

    // 3) Con conexión: descargar hqdefault (480x360, ~15-25 KB) — mejor
    //    nitidez que mqdefault sin llegar al peso de maxresdefault.
    final String thumbUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    try {
      final response = await http.get(Uri.parse(thumbUrl));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        await localFile.writeAsBytes(response.bodyBytes);
        await _touchThumbnailLru(cacheKey);
        return localFile.path;
      }
    } catch (e) {
      print('Error al descargar la miniatura: $e');
    }

    return 'assets/image.png';
  }

  /// true si la ruta es un archivo local (caché en disco), false si es una
  /// URL de red o el asset por defecto. Se usa para decidir entre
  /// Image.file(...) e Image.network(...) al mostrarla.
  bool _isLocalFilePath(String path) {
    return path.isNotEmpty && !path.startsWith('http') && path != 'assets/image.png';
  }

  Widget _buildThumbnailImage(String path, {required double height, BoxFit fit = BoxFit.cover}) {
    if (path == 'assets/image.png') {
      return Image.asset('assets/image.png', fit: fit, height: height, width: double.infinity);
    }
    if (_isLocalFilePath(path)) {
      return Image.file(
        File(path),
        fit: fit,
        height: height,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/image.png', fit: fit, height: height, width: double.infinity);
        },
      );
    }
    return Image.network(
      path,
      fit: fit,
      height: height,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/image.png', fit: fit, height: height, width: double.infinity);
      },
    );
  }

  /// Extrae el ID de video de un link de YouTube de forma segura.
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
    final bool hasError = _youtubeController?.value.hasError ?? false;
    if (hasError != _youtubeHasError) {
      setState(() {
        _youtubeHasError = hasError;
      });
    }
  }

  void _onMultitrackValueChanged() {
    final bool hasError = _multitrackController?.value.hasError ?? false;
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

  /// Aviso de "sin conexión" que reemplaza a los reproductores de YouTube
  /// (video principal y multitrack) cuando no hay internet. Evita que el
  /// usuario se quede esperando una carga que nunca va a terminar.
  Widget _buildNoConnectionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 36, color: Colors.orange),
          const SizedBox(height: 8),
          const Text(
            'Sin conexión a internet. La letra y los acordes siguen disponibles, pero el video y el multitrack necesitan internet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _retryConnection,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusSm)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _extractColorsFromImage() async {
    String thumbnailPath = await _thumbnailFuture;

    if (thumbnailPath.isNotEmpty && thumbnailPath != 'assets/image.png') {
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
        final ImageProvider imageProvider = _isLocalFilePath(thumbnailPath)
            ? FileImage(File(thumbnailPath)) as ImageProvider
            : NetworkImage(thumbnailPath);

        final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
          imageProvider,
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
    _youtubeController?.removeListener(_onYoutubeValueChanged);
    _multitrackController?.removeListener(_onMultitrackValueChanged);
    _multitrackController?.dispose();
    _youtubeController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<TextSpan> parseLyrics(String text) {
    final String _suffix =
        r'(?:maj7|maj|min|dim7|dim|aug|sus\d*|add\d*|m7|m9|m6|m|[°+])?';
    final String _bassPart =
        r'(?:\/[A-G][#b]?' + _suffix + r'\d*)*';
    final String _chordUnit =
        r'[A-G][#b]?' + _suffix + r'\d*' + _bassPart;

    final chordRegex = RegExp(
      r'(?:(?<=^)|(?<=\s))' +
      '(?:$_chordUnit)' +
      '(?:-(?:$_chordUnit))*' +
      r'(?:(?=$)|(?=[\s/]))'
    );

    final keywordRegex = RegExp(
      r'\b(?:CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?: \d+)?|PRE-CORO|CORO 1 Y 2|CORO(?: \d+)?|INSTRUMENTAL|FINAL|ESTROFA|SOLO|PUENTE(?: \d+)?|BAJO|SALIDA(?: \d+)?)\b');

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
    if (chord.contains('-')) {
      return chord.split('-').map(transposeChord).join('-');
    }

    if (chord.contains('/')) {
      return chord.split('/').map(transposeChord).join('/');
    }

    final m = RegExp(r'^([A-G][#b]?)(.*)$').firstMatch(chord);
    if (m == null) return chord;
    final root = m.group(1)!;
    final suffix = m.group(2)!;

    const sharpScale = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
    const flatScale  = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];

    int index = sharpScale.indexOf(root);
    bool hadSharp = true;
    if (index == -1) {
      index = flatScale.indexOf(root);
      hadSharp = false;
    }
    if (index == -1) return chord;

    int newIndex = (index + transposeValue) % 12;
    if (newIndex < 0) newIndex += 12;

    List<String> outScale;
    if (transposeValue > 0) {
      outScale = sharpScale;
    } else if (transposeValue < 0) {
      outScale = flatScale;
    } else {
      outScale = hadSharp ? sharpScale : flatScale;
    }

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
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: ListTile(
      leading: Icon(icon, color: AppColors.goldLight),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusSm)),
      tileColor: Colors.white.withOpacity(0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
  );
}

  void _selectInstrument(String instrument) {
    setState(() {
      showInstrumentLinks = true;
      currentInstrument = instrument;
    });
    Navigator.pop(context);
  }

  Widget _buildInstrumentPlayer(String link) {
    if (_hasConnection == false) {
      return _buildVideoErrorFallback(
        message: 'Sin conexión a internet. Conéctate para ver este instrumento.',
        originalLink: link,
      );
    }
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
    if (_hasConnection == null) {
      // Aún verificando conectividad antes de decidir qué mostrar.
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          String thumbnailPath = snapshot.data ?? '';
          bool hasThumbnail = thumbnailPath.isNotEmpty && thumbnailPath != 'assets/image.png';

          return Scaffold(
            backgroundColor: AppColors.cream,
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
                            child: _buildThumbnailImage(thumbnailPath, height: 200),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.goldLight.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                              ),
                            ),
                          ),
                          if (!hasThumbnail)
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
                            background: _buildThumbnailImage(thumbnailPath, height: 200),
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
                        SliverToBoxAdapter(
                          child: Container(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            child: Stack(
                              children: [
                                _buildThumbnailImage(thumbnailPath, height: 200),
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
                                            AppColors.charcoal.withOpacity(0.75),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    if (_hasConnection == false)
                                      _buildNoConnectionBanner()
                                    else ...[
                                      if (widget.cancion.multitrackLink != null &&
                                          widget.cancion.multitrackLink!.isNotEmpty)
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              isMultitrackVisible = !isMultitrackVisible;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accentColor ?? AppColors.steelBlue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusMd)),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            isMultitrackVisible ? "OCULTAR" : "MULTITRACK",
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      if (isMultitrackVisible && _multitrackController != null)
                                        (_multitrackController!.initialVideoId.isEmpty)
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
                                                          controller: _multitrackController!,
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
                                                                valueListenable: _multitrackController!,
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
                                                                                _multitrackController!.seekTo(
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
                                                                                        _multitrackController!.play();
                                                                                      } else {
                                                                                        _multitrackController!.pause();
                                                                                      }
                                                                                    });
                                                                                  }
                                                                                : null,
                                                                          ),
                                                                          IconButton(
                                                                            icon: const Icon(Icons.replay_10),
                                                                            onPressed: isReady
                                                                                ? () {
                                                                                    final currentPosition = _multitrackController!.value.position;
                                                                                    final newPosition = currentPosition - const Duration(seconds: 10);
                                                                                    _multitrackController!.seekTo(newPosition);
                                                                                  }
                                                                                : null,
                                                                          ),
                                                                          IconButton(
                                                                            icon: const Icon(Icons.forward_10),
                                                                            onPressed: isReady
                                                                                ? () {
                                                                                    final currentPosition = _multitrackController!.value.position;
                                                                                    final newPosition = currentPosition + const Duration(seconds: 10);
                                                                                    _multitrackController!.seekTo(newPosition);
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
                                    ],
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
                                    if (_hasConnection == true &&
                                        widget.cancion.youtubeLink != null &&
                                        widget.cancion.youtubeLink != "null" &&
                                        widget.cancion.youtubeLink!.isNotEmpty &&
                                        _youtubeController != null)
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                        child: _youtubeController!.initialVideoId.isEmpty
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
                                                      _youtubeController!.seekTo(
                                                        _youtubeController!.value.position + const Duration(seconds: 10),
                                                      );
                                                    },
                                                    onLongPress: () {
                                                      _youtubeController!.setPlaybackRate(2.0);
                                                    },
                                                    onLongPressEnd: (_) {
                                                      _youtubeController!.setPlaybackRate(1.0);
                                                    },
                                                    child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        YoutubePlayer(
                                                          controller: _youtubeController!,
                                                          showVideoProgressIndicator: true,
                                                        ),
                                                        ValueListenableBuilder(
                                                          valueListenable: _youtubeController!,
                                                          builder: (context, YoutubePlayerValue value, child) {
                                                            if (!value.isPlaying && !value.hasError) {
                                                              return IconButton(
                                                                icon: const Icon(Icons.play_arrow, size: 64, color: Colors.white),
                                                                onPressed: () {
                                                                  _youtubeController!.play();
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
              backgroundColor: isAutoscrollActive ? (secondaryColor ?? AppColors.gold) : Colors.white,
              elevation: 4,
              child: Icon(
                isAutoscrollActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isAutoscrollActive ? Colors.white : (primaryColor ?? AppColors.charcoal),
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: scrollSpeed == speed ? (secondaryColor ?? AppColors.gold) : AppColors.softBlueGray,
            borderRadius: BorderRadius.circular(80),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scrollSpeed == speed ? Colors.white : AppColors.charcoal,
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isReset ? AppColors.softBlueGray : (accentColor ?? AppColors.steelBlue).withOpacity(0.12),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accentColor ?? AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Reproductor aislado para cada link de instrumento (voces/guitarra/piano/
/// bajo/batería). Cada uno crea y gestiona su propio YoutubePlayerController
/// y escucha value.hasError para mostrar el fallback si el video se cayó.
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
        color: AppColors.softBlueGray.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
      ),
        child: Column(
          children: [
            Icon(Icons.videocam_off_rounded, size: 40, color: AppColors.steelBlue),
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