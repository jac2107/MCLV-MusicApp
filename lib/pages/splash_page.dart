import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';
import '../utils/app_theme.dart';

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
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
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