import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'home_page.dart';
import '../utils/app_theme.dart';
import '../utils/version_checker.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _imageReady = false;

  // Info de una versión nueva encontrada en version.json, si la hay. Null
  // mientras se revisa, o si no hay ninguna más nueva que la instalada.
  InfoVersionNueva? _versionNueva;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // La verificación de versión corre en PARALELO a la animación normal
    // de splash -- nunca la bloquea ni la retrasa. Si falla (sin internet,
    // error de red, timeout) o no hay versión nueva, la app sigue
    // exactamente igual que si esto no existiera.
    _revisarVersionNueva();
  }

  Future<void> _revisarVersionNueva() async {
    // El splash es solo el flujo de la app instalada (Android). En web
    // este diálogo no aplica -- ahí el botón de descarga vive en
    // HomePage, siempre visible, sin necesidad de comparar versiones.
    if (kIsWeb) return;

    final info = await revisarVersionNueva();
    if (!mounted || info == null) return;
    setState(() => _versionNueva = info);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precachea la imagen ANTES de empezar la animación. Sin esto, el primer
    // frame que la muestra tiene que decodificarla desde cero (jank real,
    // sobre todo si la imagen pesa o tiene resolución alta), justo en medio
    // de la animación de escala/fade.
    if (!_imageReady) {
      precacheImage(const AssetImage('assets/image.png'), context).then((_) {
        if (!mounted) return;
        setState(() => _imageReady = true);
        _controller.forward();
        _scheduleNavigation();
      });
    }
  }

  void _scheduleNavigation() {
    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;

      // Si para este momento ya se detectó una versión nueva, se muestra
      // el diálogo de actualización ANTES de navegar a HomePage -- así el
      // usuario lo ve una sola vez, justo al abrir la app, sin interferir
      // con la navegación normal después.
      if (_versionNueva != null) {
        _mostrarDialogoActualizacion(_versionNueva!);
        return;
      }

      _navegarAHome();
    });
  }

  void _navegarAHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _mostrarDialogoActualizacion(InfoVersionNueva info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Nueva versión disponible'),
        content: Text(
          info.notas.isNotEmpty
              ? '${info.notas}\n\nVersión ${info.version} disponible.'
              : 'Hay una versión nueva (${info.version}) disponible para descargar.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navegarAHome();
            },
            child: const Text('Más tarde'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _descargarEInstalar(info);
              _navegarAHome();
            },
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
  }

  /// Descarga el .zip (el APK real comprimido -- necesario porque Firebase
  /// Hosting en el plan Spark rechaza subir archivos .apk directamente,
  /// incluso solo renombrados; solo acepta el contenido si está realmente
  /// comprimido), lo DESCOMPRIME en memoria para extraer el .apk real, lo
  /// guarda en el teléfono, y abre el instalador del sistema. Todo esto es
  /// automático -- el usuario nunca ve ni maneja el .zip directamente.
  Future<void> _descargarEInstalar(InfoVersionNueva info) async {
    try {
      final respuesta = await http.get(Uri.parse(info.downloadUrl));
      if (respuesta.statusCode != 200) {
        throw Exception('No se pudo descargar (HTTP ${respuesta.statusCode})');
      }

      // Descomprime el ZIP en memoria y busca el .apk dentro. Se busca por
      // sufijo ".apk" en vez de asumir un único archivo en el ZIP, para no
      // depender de que Compress-Archive (lado del script) mantenga
      // siempre una estructura interna exacta.
      final archivoZip = ZipDecoder().decodeBytes(respuesta.bodyBytes);
      final archivoApk = archivoZip.files.firstWhere(
        (f) => f.isFile && f.name.toLowerCase().endsWith('.apk'),
        orElse: () => throw Exception('El .zip descargado no contiene un .apk'),
      );

      final directorio = await getTemporaryDirectory();
      final rutaApk = '${directorio.path}/${info.apkFileName}';
      final archivo = File(rutaApk);
      await archivo.writeAsBytes(archivoApk.content as List<int>);

      // Abre el instalador nativo de Android para este APK ya extraído.
      // Requiere que el usuario ya haya dado permiso de "instalar apps
      // desconocidas" para esta app la primera vez (Android lo pide
      // automáticamente si falta).
      await OpenFilex.open(rutaApk);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo descargar la actualización: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.warmGradient),
        child: Center(
          child: RepaintBoundary(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: _imageReady
                          ? ClipOval(
                              child: Image.asset(
                                'assets/image.png',
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'M.C.L.V',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'MUSIC APP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.goldLight,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}