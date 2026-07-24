import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/Mcanciones.dart';
import 'dart:async';
import '../utils/thumbnail_cache_service.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_theme.dart';
import '../utils/song_pdf_generator.dart';
import '../pages/song_picker_page.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/favorites_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/song_id.dart';
import '../widgets/enhanced_youtube_player.dart';
import '../widgets/youtube_embed.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/metronome_service.dart';

class Vcanciones extends StatefulWidget {
  final Song cancion;

  const Vcanciones({super.key, required this.cancion});

  @override
  _VcancionesState createState() => _VcancionesState();
}

class _VcancionesState extends State<Vcanciones> with SingleTickerProviderStateMixin {
  // Máximo de miniaturas guardadas en disco (LRU: se borra la más antigua
  // al superar este límite). Cubre bien el repertorio típico que se repite
  // semana a semana sin dejar crecer el almacenamiento indefinidamente.
  static const int _maxCachedThumbnails = 40;
  static const String _thumbnailOrderKey = 'thumbnail_cache_order';
  late Future<String> _thumbnailFuture;
  bool isMetronomePlaying = false;
  int transposeValue = 0;
  double _lyricsFontSize = 16.0;
  static const double _minFontSize = 12.0;
  static const double _maxFontSize = 28.0;  final int originalTransposeValue = 0;
  bool showTransposeButtons = false;
  bool isMultitrackPlaying = false;
  bool isMultitrackVisible = false;
  bool isAutoscrollActive = false;
  bool showSpeedOptions = false;
  double scrollSpeed = 1.0;
  bool _isFavorite = false;
  YoutubePlayerController? _multitrackController;
  YoutubePlayerController? _youtubeController;

  // Escucha en tiempo real el documento de Firestore de esta canción, para
  // que cualquier edición hecha desde la consola se refleje al instante
  // sin tener que salir y volver a entrar a la pantalla.
  late final Stream<DocumentSnapshot> _songStream;

  bool _youtubeHasError = false;
  bool _multitrackHasError = false;

  bool? _hasConnection;

  final ScrollController _scrollController = ScrollController();
  Timer? _autoscrollTimer;
  final GlobalKey _youtubePlayerKey = GlobalKey();
  bool _youtubePlayerVisible = false;
  // Cada color extraído tiene una variante para fondo oscuro y otra para
  // fondo claro. Se calculan una sola vez desde el color dominante de la
  // miniatura, y se elige la variante correcta según el tema activo dentro
  // de build().
  Color? primaryColorDark;
  Color? primaryColorLight;
  Color? secondaryColorDark;
  Color? secondaryColorLight;
  Color? accentColorDark;
  Color? accentColorLight;

  bool showInstrumentLinks = false;
  String? currentInstrument;
  String? videoId;


  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // IMPORTANTE: esto tiene que inicializarse aquí, antes de que build()
    // lo use en el StreamBuilder — si se deja sin asignar, la app crashea
    // con LateInitializationError apenas se abre la pantalla.
    _songStream = FirebaseFirestore.instance
        .collection('canciones')
        .doc(slugifySongTitle(widget.cancion.title))
        .snapshots();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fadeAnimation = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    _loadFontSizePreference();
    _checkConnectionAndInit();
    _loadFavoriteState();
    FavoritesRepository.instance.registerSongOpened(widget.cancion.title);

    _scrollController.addListener(_updateYoutubePlayerVisibility);
  }

  Future<void> _checkConnectionAndInit() async {
    final bool hasConnection = await _checkConnection();
    if (!mounted) return;
    setState(() {
      _hasConnection = hasConnection;
    });

    _thumbnailFuture = _getThumbnailUrl();
    _extractColorsFromImage();

    if (hasConnection && !kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _getOrCreateYoutubeController();
          });
        }
      });
    }
  }
  Future<void> _loadFontSizePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('lyrics_font_size');
    if (saved != null && mounted) {
      setState(() => _lyricsFontSize = saved);
    }
    }

  Future<void> _changeFontSize(double delta) async {
    final newSize = (_lyricsFontSize + delta).clamp(_minFontSize, _maxFontSize);
    setState(() => _lyricsFontSize = newSize);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lyrics_font_size', newSize);
  }
  Future<void> _loadFavoriteState() async {
    final fav = await FavoritesRepository.instance.isFavorite(widget.cancion.title);
    if (!mounted) return;
    setState(() {
      _isFavorite = fav;
    });
  }

  Future<void> _toggleFavorite() async {
    final nowFavorite = await FavoritesRepository.instance.toggleFavorite(widget.cancion.title);
    if (!mounted) return;
    setState(() {
      _isFavorite = nowFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowFavorite ? 'Agregada a favoritos' : 'Quitada de favoritos'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<bool> _checkConnection() async {
    try {
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      return true;
    }
  }

  Future<void> _retryConnection() async {
    final bool hasConnection = await _checkConnection();
    if (!mounted) return;
    setState(() {
      _hasConnection = hasConnection;
    });
    if (hasConnection && !kIsWeb && _youtubeController == null) {
      _getOrCreateYoutubeController();
      setState(() {});
    }
  }

  static const int _thumbnailCacheVersion = 2;
  String _thumbnailCacheKey() => 'thumb_v${_thumbnailCacheVersion}_${videoId ?? widget.cancion.title}';

  Future<void> _touchThumbnailLru(String key) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> order = prefs.getStringList(_thumbnailOrderKey) ?? [];

    order.remove(key);
    order.add(key);

    if (order.length > _maxCachedThumbnails) {
      final String oldestKey = order.removeAt(0);
      await ThumbnailCacheService.deleteCached(oldestKey);
    }

    await prefs.setStringList(_thumbnailOrderKey, order);
  }

  Future<String> _getThumbnailUrl() async {
    final String extractedId = _safeExtractVideoId(widget.cancion.youtubeLink);
    if (extractedId.isEmpty) {
      return 'assets/image.png';
    }
    videoId = extractedId;

    final String thumbUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    // En web no hay cache en disco: el navegador ya cachea la imagen de
    // red por su cuenta vía HTTP, así que devolvemos la URL directo.
    if (kIsWeb) {
      return thumbUrl;
    }

    final String cacheKey = _thumbnailCacheKey();
    final String? cachedPath = await ThumbnailCacheService.getCachedPath(cacheKey);

    if (cachedPath != null) {
      await _touchThumbnailLru(cacheKey);
      return cachedPath;
    }

    if (_hasConnection == false) {
      return 'assets/image.png';
    }

    try {
      final response = await http.get(Uri.parse(thumbUrl));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final String localPath = await ThumbnailCacheService.save(cacheKey, response.bodyBytes);
        await _touchThumbnailLru(cacheKey);
        return localPath;
      }
    } catch (e) {
      print('Error al descargar la miniatura: $e');
    }

    return 'assets/image.png';
  }

  bool _isLocalFilePath(String path) {
    return ThumbnailCacheService.isLocalPath(path);
  }

  Widget _buildThumbnailImage(String path, {required double height, BoxFit fit = BoxFit.cover}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: KeyedSubtree(
        key: ValueKey(path),
        child: _buildThumbnailImageRaw(path, height: height, fit: fit),
      ),
    );
  }

  Widget _buildThumbnailImageRaw(String path, {required double height, BoxFit fit = BoxFit.cover}) {
    if (path == 'assets/image.png') {
      return Image.asset('assets/image.png', fit: fit, height: height, width: double.infinity);
    }
    if (_isLocalFilePath(path)) {
      return ThumbnailCacheService.imageFromLocalPath(
        path,
        fit: fit,
        height: height,
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

  String _safeExtractVideoId(String? link) {
    if (link == null || link.isEmpty || link == "null") return '';
    try {
      return YoutubePlayer.convertUrlToId(link) ?? '';
    } catch (e) {
      return '';
    }
  }

  Widget _buildWebYoutubeEmbed(String? link) {
    final String id = _safeExtractVideoId(link);
    if (id.isEmpty) {
      return _buildVideoErrorFallback(
        message: 'Este enlace de YouTube no es válido o está roto.',
        originalLink: link,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppShapes.radiusMd),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubeIframeEmbed(videoId: id),
      ),
    );
  }

YoutubePlayerController _getOrCreateYoutubeController() {
  if (_youtubeController == null) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: _safeExtractVideoId(widget.cancion.youtubeLink),
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
        hideControls: true,
      ),
    )..addListener(_onYoutubeValueChanged);
  }
  return _youtubeController!;
}

  YoutubePlayerController _getOrCreateMultitrackController() {
    if (_multitrackController == null) {
      _multitrackController = YoutubePlayerController(
        initialVideoId: _safeExtractVideoId(widget.cancion.multitrackLink),
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      )..addListener(_onMultitrackValueChanged);
    }
    return _multitrackController!;
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

  Widget _buildVideoErrorFallback({required String message, required String? originalLink}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          const Icon(Icons.videocam_off, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 14)),
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
      final String cacheKey = 'song_colors_v2_${videoId ?? widget.cancion.title}';
      final prefs = await SharedPreferences.getInstance();
      final String? cached = prefs.getString(cacheKey);

      if (cached != null) {
        final parts = cached.split(',');
        if (parts.length == 6) {
          final values = parts.map(int.tryParse).toList();
          if (!values.contains(null)) {
            primaryColorDark = Color(values[0]!);
            primaryColorLight = Color(values[1]!);
            secondaryColorDark = Color(values[2]!);
            secondaryColorLight = Color(values[3]!);
            accentColorDark = Color(values[4]!);
            accentColorLight = Color(values[5]!);
            if (mounted) setState(() {});
            return;
          } else {
            await prefs.remove(cacheKey);
          }
        }
      }

      try {
        final ImageProvider imageProvider = _isLocalFilePath(thumbnailPath)
            ? ThumbnailCacheService.imageProviderFromLocalPath(thumbnailPath)
            : NetworkImage(thumbnailPath);

        final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);
        Color dominantColor = paletteGenerator.dominantColor?.color ?? Colors.blue;

        _applyExtractedColors(dominantColor);

        await prefs.setString(
          cacheKey,
          '${primaryColorDark!.value},${primaryColorLight!.value},'
          '${secondaryColorDark!.value},${secondaryColorLight!.value},'
          '${accentColorDark!.value},${accentColorLight!.value}',
        );
      } catch (e) {
        _applyFallbackColors();
      }
    } else {
      _applyFallbackColors();
    }

    if (mounted) setState(() {});
  }

// Los 2 fondos reales contra los que deben contrastar los colores.
static const Color _bgDark = Color(0xFF1E2126);
static const Color _bgLight = Color(0xFFFAFAF8);

void _applyExtractedColors(Color dominantColor) {
  // Variantes para fondo oscuro: se aclaran hasta separarse claramente
  // de _bgDark (gris oscuro) sin volverse blanco puro.
  primaryColorDark = _ensureContrast(dominantColor, _bgDark, minDiff: 0.28, towardsLight: true);
  secondaryColorDark = _ensureContrast(lighten(dominantColor, 0.3), _bgDark, minDiff: 0.35, towardsLight: true);
  accentColorDark = _ensureContrast(lighten(dominantColor, 0.15), _bgDark, minDiff: 0.30, towardsLight: true);

  // Variantes para fondo claro: se oscurecen hasta separarse claramente
  // de _bgLight (casi blanco) sin volverse negro puro.
  primaryColorLight = _ensureContrast(dominantColor, _bgLight, minDiff: 0.28, towardsLight: false);
  secondaryColorLight = _ensureContrast(darken(dominantColor, 0.25), _bgLight, minDiff: 0.35, towardsLight: false);
  accentColorLight = _ensureContrast(darken(dominantColor, 0.4), _bgLight, minDiff: 0.30, towardsLight: false);
}

void _applyFallbackColors() {
  primaryColorDark = AppColors.goldLight;
  primaryColorLight = const Color(0xFF8A5A2E);
  secondaryColorDark = AppColors.steelBlueLight;
  secondaryColorLight = AppColors.steelBlue;
  accentColorDark = AppColors.gold;
  accentColorLight = const Color(0xFF6B4423);
}

double _luminance(Color color) => (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

/// Ajusta `color` (aclarando u oscureciendo según `towardsLight`) hasta que
/// su luminancia difiera de la de `background` en al menos `minDiff`.
/// Esto es lo que evita el caso "notas blancas sobre fondo casi blanco":
/// aquí comparamos contra el fondo REAL, no un umbral genérico.
Color _ensureContrast(Color color, Color background, {required double minDiff, required bool towardsLight}) {
  final double bgLum = _luminance(background);
  Color result = color;
  int guard = 0;
  while ((_luminance(result) - bgLum).abs() < minDiff && guard < 12) {
    result = towardsLight ? lighten(result, 0.1) : darken(result, 0.1);
    guard++;
  }
  return result;
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
  _entryController.dispose();
  stopMetronome();
  stopAutoscroll();
  _youtubeController?.removeListener(_onYoutubeValueChanged);
  _multitrackController?.removeListener(_onMultitrackValueChanged);
  _multitrackController?.dispose();
  _youtubeController?.dispose();
  _scrollController.removeListener(_updateYoutubePlayerVisibility);
  _scrollController.dispose();
  _tituloPdfController.dispose();
  super.dispose();
}
  List<TextSpan> parseLyrics(String text, Color chordColor, Color keywordColor, Color textColor) {
    final String _suffix = r'(?:maj7|maj|min|dim7|dim|aug|sus\d*|add\d*|m7|m9|m6|m|[°+])?';
    final String _bassPart = r'(?:\/[A-G][#b]?' + _suffix + r'\d*)*';
    final String _chordUnit = r'[A-G][#b]?' + _suffix + r'\d*' + _bassPart;

    final chordRegex = RegExp(
      r'(?:(?<=^)|(?<=\s))' + '(?:$_chordUnit)' + '(?:-(?:$_chordUnit))*' + r'(?:(?=$)|(?=[\s/]))',
    );

    final keywordRegex = RegExp(
      r'\b(?:CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?: \d+)?|PRE-CORO|CORO 1 Y 2|CORO(?: \d+)?|INSTRUMENTAL|FINAL|ESTROFA|SOLO|PUENTE(?: \d+)?|BAJO|SALIDA(?: \d+)?)\b',
    );

    List<TextSpan> spans = [];

    for (var line in text.split('\n')) {
      final matches = <RegExpMatch>[
        ...keywordRegex.allMatches(line),
        ...chordRegex.allMatches(line),
      ]..sort((a, b) => a.start.compareTo(b.start));

      int currentIndex = 0;
      for (var match in matches) {
        if (match.start > currentIndex) {
          spans.add(TextSpan(text: line.substring(currentIndex, match.start), style: TextStyle(color: textColor)));
        }

        final token = match.group(0)!;
        TextStyle style;
        String rendered;

        if (chordRegex.hasMatch(token)) {
          rendered = transposeChord(token);
          style = TextStyle(color: chordColor);
        } else {
          rendered = token;
          style = TextStyle(color: keywordColor);
        }

        spans.add(TextSpan(text: rendered, style: style));
        currentIndex = match.end;
      }

      if (currentIndex < line.length) {
        spans.add(TextSpan(text: line.substring(currentIndex), style: TextStyle(color: textColor)));
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

    const sharpScale = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    const flatScale = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

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
        MetronomeService.start(widget.cancion.tiempo);
      } else {
        MetronomeService.stop();
      }
    });
  }

void stopMetronome() {
    MetronomeService.stop();
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
void _updateYoutubePlayerVisibility() {
  final ctx = _youtubePlayerKey.currentContext;
  if (ctx == null) {
    if (_youtubePlayerVisible) setState(() => _youtubePlayerVisible = false);
    return;
  }

  final RenderBox box = ctx.findRenderObject() as RenderBox;
  final Offset position = box.localToGlobal(Offset.zero);
  final double screenHeight = MediaQuery.of(context).size.height;

  // Consideramos "visible" si al menos una parte del reproductor está
  // dentro del viewport (con un margen de 40px para que el FAB se oculte
  // un poco antes de que el reproductor asome del todo, evitando el
  // parpadeo justo en el borde).
  final bool visible = position.dy < screenHeight - 40 && (position.dy + box.size.height) > 40;

  if (visible != _youtubePlayerVisible) {
    setState(() => _youtubePlayerVisible = visible);
  }
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
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusSm)),
        tileColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Future<void> _compartirCancion() async {
    final alcance = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: const Text('Solo esta canción'),
              onTap: () => Navigator.pop(context, 'sola'),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_check_outlined),
              title: const Text('Elegir varias canciones'),
              onTap: () => Navigator.pop(context, 'varias'),
            ),
          ],
        ),
      ),
    );

    if (alcance == null || !mounted) return;

    if (alcance == 'varias') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SongPickerPage(preseleccionadas: [widget.cancion])),
      );
      return;
    }

    final formato = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Compartir como PDF'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet_outlined),
              title: const Text('Compartir como texto'),
              onTap: () => Navigator.pop(context, 'texto'),
            ),
          ],
        ),
      ),
    );

    if (formato == null || !mounted) return;

    if (formato == 'texto') {
      final buffer = StringBuffer();
      buffer.writeln(widget.cancion.title);
      buffer.writeln('Tonalidad: ${widget.cancion.tonalidad}');
      if (widget.cancion.tiempo > 0) {
        buffer.writeln('Tiempo: ${widget.cancion.tiempo} bpm');
      }
      buffer.writeln();
      buffer.write(widget.cancion.text.trim());
      await Share.share(buffer.toString());
      return;
    }

    final titulo = await _pedirTituloPdf();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final esAlabanza = widget.cancion.categoria == 'alabanza';
      final bytes = await SongPdfGenerator.generate(
        adoracion: esAlabanza ? [] : [widget.cancion],
        alabanza: esAlabanza ? [widget.cancion] : [],
        tituloRepertorio: titulo,
      );
      if (!mounted) return;
      Navigator.pop(context);
      final nombreArchivo =
          '${widget.cancion.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').replaceAll(' ', '_')}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: nombreArchivo);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo generar el PDF: $e')));
      }
    }
  }

  final TextEditingController _tituloPdfController = TextEditingController();

  Future<String?> _pedirTituloPdf() async {
    _tituloPdfController.clear();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Título del PDF (opcional)'),
        content: TextField(
          controller: _tituloPdfController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ej: Servicio Domingo'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, _tituloPdfController.text.trim()),
            child: const Text('Continuar'),
          ),
        ],
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
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubeIframeEmbed(videoId: id),
        ),
      );
    }
    return _InstrumentYoutubePlayer(videoId: id, originalLink: link);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _songStream,
      builder: (context, songSnapshot) {
        // Mientras no haya datos del stream (primer frame) o el doc no
        // exista, usamos la canción recibida al navegar como fallback.
        // Con persistencia offline habilitada en main.dart, si no hay
        // internet este snapshot igual trae la última versión en caché.
        final Song cancion = (songSnapshot.hasData && songSnapshot.data!.exists)
            ? Song.fromMap(songSnapshot.data!.data() as Map<String, dynamic>)
            : widget.cancion;

        final t = AppThemeData.of(context);
        final Color primaryColor =
            (t.isDark ? primaryColorDark : primaryColorLight) ?? (t.isDark ? AppColors.charcoalSoft : Colors.white);
        final Color secondaryColor = (t.isDark ? secondaryColorDark : secondaryColorLight) ??
            (t.isDark ? AppColors.steelBlueLight : AppColors.steelBlue);
        final Color accentColor =
            (t.isDark ? accentColorDark : accentColorLight) ?? (t.isDark ? AppColors.goldLight : AppColors.gold);
        final Color lyricsTextColor = t.isDark ? AppColors.cream : AppColors.charcoal;

        if (_hasConnection == null) {
          return Scaffold(
            backgroundColor: t.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return FutureBuilder<String>(
          future: _thumbnailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: t.background,
                body: const Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar la imagen'));
            } else {
              String thumbnailPath = snapshot.data ?? '';
              bool hasThumbnail = thumbnailPath.isNotEmpty && thumbnailPath != 'assets/image.png';

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _entryController.status == AnimationStatus.dismissed) {
                  _entryController.forward();
                }
              });

              return Scaffold(
                backgroundColor: t.background,
                appBar: AppBar(
                  title: Text(cancion.title, style: const TextStyle(fontSize: 20)),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                      onPressed: _compartirCancion,
                      tooltip: 'Compartir / PDF',
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.redAccent : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                      tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                    ),
                    if (cancion.instrument != 0)
                      Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
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
                    color: secondaryColor,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              Positioned.fill(child: _buildThumbnailImage(thumbnailPath, height: 200)),
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
                                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                              if (cancion.voicesLinks != null && cancion.voicesLinks!.isNotEmpty)
                                _buildMenuItem(icon: Icons.mic, title: 'Voces', onTap: () => _selectInstrument('voices')),
                              if (cancion.guitarLink != null && cancion.guitarLink!.isNotEmpty)
                                _buildMenuItem(
                                    icon: Icons.music_note, title: 'Guitarra', onTap: () => _selectInstrument('guitar')),
                              if (cancion.pianoLink != null && cancion.pianoLink!.isNotEmpty)
                                _buildMenuItem(icon: Icons.piano, title: 'Piano', onTap: () => _selectInstrument('piano')),
                              if (cancion.bassLink != null && cancion.bassLink!.isNotEmpty)
                                _buildMenuItem(
                                    icon: Icons.audiotrack, title: 'Bajo', onTap: () => _selectInstrument('bass')),
                              if (cancion.drumsLink != null && cancion.drumsLink!.isNotEmpty)
                                _buildMenuItem(
                                    icon: FontAwesomeIcons.drum, title: 'Batería', onTap: () => _selectInstrument('drums')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          // Fondo neutro y fijo: casi blanco en claro, gris oscuro en
                          // oscuro — nunca compite ni se confunde con los colores de las
                          // notas/acordes extraídos de la miniatura.
                          color: t.isDark ? const Color(0xFF1E2126) : const Color(0xFFFAFAF8),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
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
                                    delegate: SliverChildListDelegate([
                                      if (currentInstrument == 'voices' && cancion.voicesLinks != null)
                                        ...cancion.voicesLinks!.map(
                                          (link) =>
                                              Container(margin: const EdgeInsets.all(8.0), child: _buildInstrumentPlayer(link)),
                                        ),
                                      if (currentInstrument == 'guitar' && cancion.guitarLink != null)
                                        ...cancion.guitarLink!.map(
                                          (link) =>
                                              Container(margin: const EdgeInsets.all(8.0), child: _buildInstrumentPlayer(link)),
                                        ),
                                      if (currentInstrument == 'piano' && cancion.pianoLink != null)
                                        ...cancion.pianoLink!.map(
                                          (link) =>
                                              Container(margin: const EdgeInsets.all(8.0), child: _buildInstrumentPlayer(link)),
                                        ),
                                      if (currentInstrument == 'bass' && cancion.bassLink != null)
                                        ...cancion.bassLink!.map(
                                          (link) =>
                                              Container(margin: const EdgeInsets.all(8.0), child: _buildInstrumentPlayer(link)),
                                        ),
                                      if (currentInstrument == 'drums' && cancion.drumsLink != null)
                                        ...cancion.drumsLink!.map(
                                          (link) =>
                                              Container(margin: const EdgeInsets.all(8.0), child: _buildInstrumentPlayer(link)),
                                        ),
                                    ]),
                                  ),
                                ],
                              )
                            : CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Container(
                                      color: Colors.transparent,
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
                                                    colors: [Colors.transparent, AppColors.charcoal.withOpacity(0.75)],
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
                                                if (cancion.multitrackLink != null &&
                                                    cancion.multitrackLink!.isNotEmpty)
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isMultitrackVisible = !isMultitrackVisible;
                                                        if (isMultitrackVisible && !kIsWeb) {
                                                          _getOrCreateMultitrackController();
                                                        }
                                                      });
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: accentColor,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(AppShapes.radiusMd)),
                                                      elevation: 0,
                                                    ),
                                                    child: Text(
                                                      isMultitrackVisible ? "OCULTAR" : "MULTITRACK",
                                                      style: const TextStyle(
                                                          fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                                    ),
                                                  ),
                                                const SizedBox(height: 10),
                                                // En web mostramos un iframe visible con los controles nativos
                                                // de YouTube (play/pause/seek/volumen), en vez del reproductor
                                                // invisible + slider propio que se usa en Android/iOS. La
                                                // sincronización fina con slider custom no es viable sin JS
                                                // interop adicional, así que este es el trade-off para web.
                                                if (isMultitrackVisible && kIsWeb)
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 10),
                                                    child: _buildWebYoutubeEmbed(cancion.multitrackLink),
                                                  ),
                                                if (isMultitrackVisible && !kIsWeb && _multitrackController != null)
                                                  (_multitrackController!.initialVideoId.isEmpty)
                                                      ? _buildVideoErrorFallback(
                                                          message: 'El enlace del multitrack no es válido.',
                                                          originalLink: cancion.multitrackLink,
                                                        )
                                                      : _multitrackHasError
                                                          ? _buildVideoErrorFallback(
                                                              message:
                                                                  'El video del multitrack ya no está disponible (puede haber sido eliminado o ser privado).',
                                                              originalLink: cancion.multitrackLink,
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
                                                                            child: SizedBox(height: 1, child: player)),
                                                                        ValueListenableBuilder(
                                                                          valueListenable: _multitrackController!,
                                                                          builder:
                                                                              (context, YoutubePlayerValue value, child) {
                                                                            bool isReady = value.isReady;
                                                                            return Column(
                                                                              children: [
                                                                                Slider(
                                                                                  value:
                                                                                      value.position.inSeconds.toDouble(),
                                                                                  min: 0,
                                                                                  max: value.metaData.duration.inSeconds
                                                                                              .toDouble() >
                                                                                          0
                                                                                      ? value.metaData.duration.inSeconds
                                                                                          .toDouble()
                                                                                      : 1,
                                                                                  onChanged: isReady
                                                                                      ? (newValue) {
                                                                                          _multitrackController!.seekTo(
                                                                                            Duration(
                                                                                                seconds: newValue.toInt()),
                                                                                          );
                                                                                        }
                                                                                      : null,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment.center,
                                                                                  children: [
                                                                                    IconButton(
                                                                                      icon: Icon(isMultitrackPlaying
                                                                                          ? Icons.pause
                                                                                          : Icons.play_arrow),
                                                                                      onPressed: isReady
                                                                                          ? () {
                                                                                              setState(() {
                                                                                                isMultitrackPlaying =
                                                                                                    !isMultitrackPlaying;
                                                                                                if (isMultitrackPlaying) {
                                                                                                  _multitrackController!
                                                                                                      .play();
                                                                                                } else {
                                                                                                  _multitrackController!
                                                                                                      .pause();
                                                                                                }
                                                                                              });
                                                                                            }
                                                                                          : null,
                                                                                    ),
                                                                                    IconButton(
                                                                                      icon: const Icon(Icons.replay_10),
                                                                                      onPressed: isReady
                                                                                          ? () {
                                                                                              final currentPosition =
                                                                                                  _multitrackController!
                                                                                                      .value.position;
                                                                                              final newPosition =
                                                                                                  currentPosition -
                                                                                                      const Duration(
                                                                                                          seconds: 10);
                                                                                              _multitrackController!
                                                                                                  .seekTo(newPosition);
                                                                                            }
                                                                                          : null,
                                                                                    ),
                                                                                    IconButton(
                                                                                      icon: const Icon(Icons.forward_10),
                                                                                      onPressed: isReady
                                                                                          ? () {
                                                                                              final currentPosition =
                                                                                                  _multitrackController!
                                                                                                      .value.position;
                                                                                              final newPosition =
                                                                                                  currentPosition +
                                                                                                      const Duration(
                                                                                                          seconds: 10);
                                                                                              _multitrackController!
                                                                                                  .seekTo(newPosition);
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
                                                    icon: Icon(Icons.music_note, color: lyricsTextColor),
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
                                                        _buildTransposeButton("-1", -2, accentColor),
                                                        _buildTransposeButton("-½", -1, accentColor),
                                                        _buildTransposeButton("+½", 1, accentColor),
                                                        _buildTransposeButton("+1", 2, accentColor),
                                                        _buildTransposeButton("Original", 0, accentColor, isReset: true),
                                                      ],
                                                    ),
                                                  ),
                                            ],
                                            ),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 0),
                                                  // El metrónomo no está disponible en la versión web
                                                  // (native_metronome es un plugin nativo Android/iOS).
                                                  if (!kIsWeb)
                                                    IconButton(
                                                      icon: Icon(
                                                        isMetronomePlaying ? Icons.pause : Icons.play_arrow,
                                                        color: cancion.tiempo <= 0 ? Colors.grey : lyricsTextColor,
                                                      ),
                                                      onPressed: toggleMetronome,
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  if (!kIsWeb) const SizedBox(width: 5),
                                                  IconButton(
                                                    icon: Icon(Icons.text_decrease_rounded, color: lyricsTextColor),
                                                    onPressed: _lyricsFontSize > _minFontSize
                                                        ? () => _changeFontSize(-2)
                                                        : null,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.text_increase_rounded, color: lyricsTextColor),
                                                    onPressed: _lyricsFontSize < _maxFontSize
                                                        ? () => _changeFontSize(2)
                                                        : null,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ],
                                              ),
                                              if (showSpeedOptions)
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    _buildSpeedButton("x0.5", 0.5, secondaryColor, lyricsTextColor),
                                                    _buildSpeedButton("x0.75", 0.75, secondaryColor, lyricsTextColor),
                                                    _buildSpeedButton("x1", 1.0, secondaryColor, lyricsTextColor),
                                                    _buildSpeedButton("x1.25", 1.25, secondaryColor, lyricsTextColor),
                                                    _buildSpeedButton("x1.5", 1.5, secondaryColor, lyricsTextColor),
                                                    _buildSpeedButton("STOP", 0, secondaryColor, lyricsTextColor),
                                                  ],
                                                ),
                                              const SizedBox(height: 0),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: RichText(
                                                  softWrap: false,
                                                  text: TextSpan(
                                                    style: TextStyle(fontSize: _lyricsFontSize, fontFamily: 'RobotoMono'),
                                                    children: parseLyrics(
                                                        cancion.text, secondaryColor, accentColor, lyricsTextColor),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              if (_hasConnection == true &&
                                                  cancion.youtubeLink != null &&
                                                  cancion.youtubeLink != "null" &&
                                                  cancion.youtubeLink!.isNotEmpty &&
                                                  (kIsWeb || _youtubeController != null))
                                                Container(
                                                  key: _youtubePlayerKey,
                                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                                  child: kIsWeb
                                                      ? _buildWebYoutubeEmbed(cancion.youtubeLink)
                                                      : _youtubeController!.initialVideoId.isEmpty
                                                          ? _buildVideoErrorFallback(
                                                              message: 'Este enlace de YouTube no es válido o está roto.',
                                                              originalLink: cancion.youtubeLink,
                                                            )
                                                          : _youtubeHasError
                                                              ? _buildVideoErrorFallback(
                                                                  message:
                                                                      'Este video ya no está disponible (puede haber sido eliminado, ser privado o estar bloqueado en tu región).',
                                                                  originalLink: cancion.youtubeLink,
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                                                                  child: EnhancedYoutubePlayer(controller: _youtubeController!),
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
                    ),
                  ],
                ),
                floatingActionButton: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: _youtubePlayerVisible ? 0.0 : 1.0,
                curve: Curves.easeOut,
                child: IgnorePointer(
                  ignoring: _youtubePlayerVisible,
                  child: FloatingActionButton(
                    onPressed: toggleAutoscroll,
                    backgroundColor: isAutoscrollActive ? secondaryColor : Colors.white,
                    elevation: 4,
                    child: Icon(
                      isAutoscrollActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isAutoscrollActive ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildSpeedButton(String text, double speed, Color activeColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => setScrollSpeed(speed),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: scrollSpeed == speed ? activeColor : AppColors.softBlueGray,
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

  Widget _buildTransposeButton(String label, int semiTones, Color accentColor, {bool isReset = false}) {
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
            color: isReset ? AppColors.softBlueGray : accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: accentColor),
          ),
        ),
      ),
    );
  }
}

class _InstrumentYoutubePlayer extends StatefulWidget {
  final String videoId;
  final String originalLink;

  const _InstrumentYoutubePlayer({required this.videoId, required this.originalLink});

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
        YoutubePlayer(controller: _controller, showVideoProgressIndicator: true),
        const SizedBox(height: 8),
      ],
    );
  }
}