import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';
import '../utils/app_theme.dart';

// URL del version.json que el script de deploy genera y publica en
// Firebase Hosting junto con la web. Contiene la última versión publicada
// y el nombre del archivo a descargar (ver deploy.ps1, paso 6).
const String _kVersionCheckUrl = 'https://mclv-musicapp.web.app/version.json';

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
  _InfoVersionNueva? _versionNueva;

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
    // En web no tiene sentido ofrecer descargar un APK -- el usuario web
    // ya está usando la versión más reciente por definición (Hosting
    // siempre sirve el último deploy). kIsWeb evalúa en tiempo de
    // compilación, así que Platform.isAndroid ni se ejecuta en web.
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;

    try {
      final paqueteInfo = await PackageInfo.fromPlatform();
      final versionInstalada = paqueteInfo.version; // ej. "1.0.0"

      final respuesta = await http
          .get(Uri.parse(_kVersionCheckUrl))
          .timeout(const Duration(seconds: 5));

      if (respuesta.statusCode != 200) return;

      final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
      final versionRemota = datos['version'] as String?;
      final downloadUrl = datos['downloadUrl'] as String?;
      final apkFileName = datos['apkFileName'] as String?;
      final zipFileName = datos['zipFileName'] as String?;

      if (versionRemota == null ||
          downloadUrl == null ||
          apkFileName == null ||
          zipFileName == null) {
        return;
      }

      if (_esVersionMasNueva(versionRemota, versionInstalada)) {
        if (!mounted) return;
        setState(() {
          _versionNueva = _InfoVersionNueva(
            version: versionRemota,
            downloadUrl: downloadUrl,
            apkFileName: apkFileName,
            zipFileName: zipFileName,
            notas: datos['notas'] as String? ?? '',
          );
        });
      }
    } catch (_) {
      // Silencioso a propósito: cualquier fallo aquí (sin internet, JSON
      // mal formado, timeout) no debe afectar el arranque normal de la
      // app. El peor caso es simplemente que no se avisa de la
      // actualización esta vez.
    }
  }

  /// Compara dos versiones tipo "1.2.0" componente por componente
  /// (mayor.menor.parche). Devuelve true si `remota` es estrictamente
  /// mayor que `instalada`.
  bool _esVersionMasNueva(String remota, String instalada) {
    List<int> partes(String v) => v
        .split('+')
        .first // ignora el build number tipo "1.0.0+1"
        .split('.')
        .map((p) => int.tryParse(p) ?? 0)
        .toList();

    final partesRemota = partes(remota);
    final partesInstalada = partes(instalada);

    for (var i = 0; i < 3; i++) {
      final r = i < partesRemota.length ? partesRemota[i] : 0;
      final inst = i < partesInstalada.length ? partesInstalada[i] : 0;
      if (r != inst) return r > inst;
    }
    return false;
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

  void _mostrarDialogoActualizacion(_InfoVersionNueva info) {
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
  Future<void> _descargarEInstalar(_InfoVersionNueva info) async {
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
      final uri = Uri.file(rutaApk);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
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
        // DecoratedBox en vez de Container: evita un layer de composición
        // extra innecesario ya que no necesitamos padding/margin aquí.
        decoration: const BoxDecoration(gradient: AppColors.warmGradient),
        child: Center(
          child: RepaintBoundary(
            // Aísla la animación en su propia capa de repintado: así Flutter
            // no tiene que re-rasterizar el gradiente de fondo completo en
            // cada uno de los frames de la animación de escala/fade, solo
            // este widget pequeño. Esto es lo que más ayuda contra el jank.
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
                      // Mientras la imagen se precachea, muestra un círculo
                      // vacío del mismo tamaño en vez de nada (evita "salto"
                      // de layout cuando aparece).
                      child: _imageReady
                          ? ClipOval(
                              child: Image.asset(
                                'assets/image.png',
                                fit: BoxFit.cover,
                                // gaplessPlayback evita un parpadeo si el
                                // widget se reconstruye antes de navegar.
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

class _InfoVersionNueva {
  final String version;
  final String downloadUrl;
  final String apkFileName;
  final String zipFileName;
  final String notas;

  _InfoVersionNueva({
    required this.version,
    required this.downloadUrl,
    required this.apkFileName,
    required this.zipFileName,
    required this.notas,
  });
}