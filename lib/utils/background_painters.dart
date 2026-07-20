import 'dart:math';
import 'package:flutter/material.dart';

/// Estrellas animadas con leve parpadeo y desplazamiento vertical lento.
class StarsPainter extends StatefulWidget {
  const StarsPainter({super.key});

  @override
  State<StarsPainter> createState() => _StarsPainterState();
}

class _StarsPainterState extends State<StarsPainter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _StarsFieldPainter(progress: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarsFieldPainter extends CustomPainter {
  final double progress;

  _StarsFieldPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint();

    for (int i = 0; i < 70; i++) {
      final baseDx = random.nextDouble() * size.width;
      final baseDy = random.nextDouble() * size.height * 0.65;
      final phase = random.nextDouble();
      final driftSpeed = random.nextDouble() * 0.02 + 0.005;

      final dy = (baseDy + progress * driftSpeed * size.height * 10) % (size.height * 0.65);

      final twinkle = (sin((progress + phase) * 2 * pi) + 1) / 2;
      final radius = random.nextDouble() * 1.2 + 0.3;
      final baseOpacity = random.nextDouble() * 0.5 + 0.15;
      final opacity = (baseOpacity * (0.5 + 0.5 * twinkle)).clamp(0.0, 1.0);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(baseDx, dy), radius, paint);
    }

    for (int i = 0; i < 8; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height * 0.55;
      final phase = random.nextDouble();
      final twinkle = (sin((progress + phase) * 2 * pi) + 1) / 2;

      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3 + 0.4 * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(dx, dy), 1.6, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsFieldPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Ondas de "calor" animadas para el fondo de modo claro: varias capas de
/// curvas naranjas semitransparentes que se mueven horizontalmente y
/// oscilan en altura, como el aire caliente distorsionándose. Cada capa
/// tiene su propia velocidad y fase para que no se sientan sincronizadas.
/// Líneas delgadas de "viento cálido" para el fondo de modo claro: trazos
/// finos naranjas que se desplazan horizontalmente en distintas alturas,
/// simulando corrientes de aire caliente. Son strokes, no áreas rellenas.
/// Ondas largas tipo "listón" para el fondo de modo claro: curvas suaves
/// que recorren todo el ancho de la pantalla (como cintas de aire/agua),
/// varias capas superpuestas con distinta altura, grosor y velocidad,
/// desplazándose horizontalmente en bucle continuo.
class SunsetWavesPainter extends StatefulWidget {
  const SunsetWavesPainter({super.key});

  @override
  State<SunsetWavesPainter> createState() => _SunsetWavesPainterState();
}

class _SunsetWavesPainterState extends State<SunsetWavesPainter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _RibbonWavesPainter(progress: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RibbonWavesPainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0, ciclo continuo

  _RibbonWavesPainter({required this.progress});

  @override
void paint(Canvas canvas, Size size) {
  // 10 capas de viento con estilos variados: unas más largas y lentas,
  // otras más cortas y rápidas, distinta frecuencia de ondulación para
  // que no se vean como copias desplazadas de la misma curva.
  _drawRibbon(canvas, size, baseHeightFraction: 0.15, amplitude: 45, strokeWidth: 1.4, opacity: 0.09, speed: 0.9, phaseOffset: 0.62, freq: 2.0);
  _drawRibbon(canvas, size, baseHeightFraction: 0.17, amplitude: 25, strokeWidth: 2.4, opacity: 0.14, speed: 0.65, phaseOffset: 0.15, freq: 1.6);
  _drawRibbon(canvas, size, baseHeightFraction: 0.19, amplitude: 50, strokeWidth: 1.0, opacity: 0.08, speed: 1.1, phaseOffset: 0.8, freq: 0.9);
  _drawRibbon(canvas, size, baseHeightFraction: 0.21, amplitude: 35, strokeWidth: 2.8, opacity: 0.13, speed: 0.55, phaseOffset: 0.4, freq: 1.4);
  _drawRibbon(canvas, size, baseHeightFraction: 0.23, amplitude: 20, strokeWidth: 1.8, opacity: 0.11, speed: 1.3, phaseOffset: 0.05, freq: 2.4);
  _drawRibbon(canvas, size, baseHeightFraction: 0.26, amplitude: 40, strokeWidth: 2.0, opacity: 0.12, speed: 0.7, phaseOffset: 0.5, freq: 1.0);
  _drawRibbon(canvas, size, baseHeightFraction: 0.28, amplitude: 28, strokeWidth: 1.2, opacity: 0.10, speed: 0.95, phaseOffset: 0.28, freq: 1.8);
  _drawRibbon(canvas, size, baseHeightFraction: 0.31, amplitude: 45, strokeWidth: 2.6, opacity: 0.11, speed: 0.4, phaseOffset: 0.7, freq: 0.8);
  _drawRibbon(canvas, size, baseHeightFraction: 0.33, amplitude: 22, strokeWidth: 1.6, opacity: 0.09, speed: 1.0, phaseOffset: 0.9, freq: 2.1);
  // 20 capas de viento distribuidas por toda la pantalla, con distinta
  // altura, amplitud, grosor, velocidad y frecuencia — más densidad sin
  // verse repetitivo porque cada capa varía en varios ejes a la vez.
  _drawRibbon(canvas, size, baseHeightFraction: 0.04, amplitude: 26, strokeWidth: 2.8, opacity: 0.11, speed: 0.5, phaseOffset: 0.02, freq: 1.3);
  _drawRibbon(canvas, size, baseHeightFraction: 0.09, amplitude: 40, strokeWidth: 1.2, opacity: 0.07, speed: 0.85, phaseOffset: 0.55, freq: 2.1);
  _drawRibbon(canvas, size, baseHeightFraction: 0.14, amplitude: 22, strokeWidth: 2.0, opacity: 0.10, speed: 0.6, phaseOffset: 0.12, freq: 1.7);
  _drawRibbon(canvas, size, baseHeightFraction: 0.19, amplitude: 34, strokeWidth: 1.4, opacity: 0.08, speed: 1.05, phaseOffset: 0.7, freq: 0.9);
  _drawRibbon(canvas, size, baseHeightFraction: 0.25, amplitude: 45, strokeWidth: 2.4, opacity: 0.10, speed: 0.5, phaseOffset: 0.35, freq: 1.5);
  _drawRibbon(canvas, size, baseHeightFraction: 0.30, amplitude: 18, strokeWidth: 1.6, opacity: 0.08, speed: 1.25, phaseOffset: 0.08, freq: 2.4);
  _drawRibbon(canvas, size, baseHeightFraction: 0.36, amplitude: 30, strokeWidth: 2.2, opacity: 0.09, speed: 0.75, phaseOffset: 0.48, freq: 1.1);
  _drawRibbon(canvas, size, baseHeightFraction: 0.41, amplitude: 42, strokeWidth: 1.0, opacity: 0.06, speed: 0.95, phaseOffset: 0.82, freq: 1.9);
  _drawRibbon(canvas, size, baseHeightFraction: 0.46, amplitude: 24, strokeWidth: 2.6, opacity: 0.10, speed: 0.55, phaseOffset: 0.2, freq: 1.4);
  _drawRibbon(canvas, size, baseHeightFraction: 0.52, amplitude: 36, strokeWidth: 1.4, opacity: 0.07, speed: 1.15, phaseOffset: 0.65, freq: 0.85);
  _drawRibbon(canvas, size, baseHeightFraction: 0.57, amplitude: 20, strokeWidth: 2.0, opacity: 0.09, speed: 0.65, phaseOffset: 0.38, freq: 2.2);
  _drawRibbon(canvas, size, baseHeightFraction: 0.62, amplitude: 44, strokeWidth: 1.8, opacity: 0.08, speed: 0.9, phaseOffset: 0.15, freq: 1.2);
    _drawRibbon(canvas, size, baseHeightFraction: 0.64, amplitude: 44, strokeWidth: 1.8, opacity: 0.08, speed: 0.9, phaseOffset: 0.15, freq: 1.2);
  _drawRibbon(canvas, size, baseHeightFraction: 0.66, amplitude: 30, strokeWidth: 1.2, opacity: 0.08, speed: 0.9, phaseOffset: 0.15, freq: 1.2);

  _drawRibbon(canvas, size, baseHeightFraction: 0.67, amplitude: 28, strokeWidth: 2.4, opacity: 0.10, speed: 0.45, phaseOffset: 0.6, freq: 1.6);
    _drawRibbon(canvas, size, baseHeightFraction: 0.70, amplitude: 40, strokeWidth: 1.2, opacity: 0.08, speed: 0.45, phaseOffset: 0.15, freq: 1.2);

  _drawRibbon(canvas, size, baseHeightFraction: 0.72, amplitude: 38, strokeWidth: 1.2, opacity: 0.07, speed: 1.1, phaseOffset: 0.92, freq: 2.0);
  _drawRibbon(canvas, size, baseHeightFraction: 0.77, amplitude: 22, strokeWidth: 2.2, opacity: 0.09, speed: 0.7, phaseOffset: 0.3, freq: 1.0);
  _drawRibbon(canvas, size, baseHeightFraction: 0.82, amplitude: 32, strokeWidth: 1.6, opacity: 0.08, speed: 0.8, phaseOffset: 0.75, freq: 1.8);
  _drawRibbon(canvas, size, baseHeightFraction: 0.87, amplitude: 40, strokeWidth: 2.0, opacity: 0.09, speed: 0.5, phaseOffset: 0.42, freq: 0.95);
  _drawRibbon(canvas, size, baseHeightFraction: 0.91, amplitude: 20, strokeWidth: 1.4, opacity: 0.07, speed: 1.2, phaseOffset: 0.1, freq: 2.3);
  _drawRibbon(canvas, size, baseHeightFraction: 0.95, amplitude: 30, strokeWidth: 2.6, opacity: 0.08, speed: 0.6, phaseOffset: 0.55, freq: 1.3);
  _drawRibbon(canvas, size, baseHeightFraction: 0.98, amplitude: 18, strokeWidth: 1.0, opacity: 0.06, speed: 1.0, phaseOffset: 0.88, freq: 1.7);
}

void _drawRibbon(
  Canvas canvas,
  Size size, {
  required double baseHeightFraction,
  required double amplitude,
  required double strokeWidth,
  required double opacity,
  required double speed,
  required double phaseOffset,
  required double freq,
}) {
  final baseY = size.height * baseHeightFraction;
  final wavePhase = (progress * speed + phaseOffset) * 2 * pi;

  final path = Path();
  const steps = 60;
  for (int i = 0; i <= steps; i++) {
    final x = size.width * (i / steps);
    final t = (i / steps) * 2 * pi;
    final y = baseY + sin(t * freq + wavePhase) * amplitude + sin(t * (freq * 0.35) - wavePhase * 0.7) * (amplitude * 0.4);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }

  final paint = Paint()
    ..color = const Color.fromARGB(255, 238, 136, 41).withOpacity(opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;

  canvas.drawPath(path, paint);
}
  @override
  bool shouldRepaint(covariant _RibbonWavesPainter oldDelegate) => oldDelegate.progress != progress;
}
class _WindLinesPainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0, ciclo continuo

  _WindLinesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);

    // Varias líneas, cada una con: altura, longitud, velocidad, grosor y
    // opacidad propias — para que el conjunto no se sienta mecánico.
    for (int i = 0; i < 30; i++) {
      final baseY = random.nextDouble() * size.height * 0.75 + size.height * 0.1;
      final lineLength = random.nextDouble() * 60 + 40;
      final speed = random.nextDouble() * 0.6 + 0.5;
      final phaseOffset = random.nextDouble();
      final strokeWidth = random.nextDouble() * 1.2 + 0.6;
      final opacity = random.nextDouble() * 0.25 + 0.12;
      final waviness = random.nextDouble() * 6 + 2;

      // La línea recorre todo el ancho y se recicla (wrap) al salir.
      final travel = ((progress * speed + phaseOffset) % 1.0) * (size.width + lineLength) - lineLength;

      final path = Path();
      path.moveTo(travel, baseY);
      path.quadraticBezierTo(
        travel + lineLength * 0.5,
        baseY - waviness,
        travel + lineLength,
        baseY,
      );

      final paint = Paint()
        ..color = const Color(0xFFFFB870).withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WindLinesPainter oldDelegate) => oldDelegate.progress != progress;
}
class _HeatWavesPainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0, ciclo continuo

  _HeatWavesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(canvas, size, baseHeightFraction: 0.68, amplitude: 22, opacity: 0.12, speed: 1.0, phaseOffset: 0.0);
    _drawWave(canvas, size, baseHeightFraction: 0.80, amplitude: 16, opacity: 0.10, speed: 1.4, phaseOffset: 0.3);
    _drawWave(canvas, size, baseHeightFraction: 0.90, amplitude: 24, opacity: 0.08, speed: 0.7, phaseOffset: 0.6);
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double baseHeightFraction,
    required double amplitude,
    required double opacity,
    required double speed,
    required double phaseOffset,
  }) {
    final path = Path();
    final baseY = size.height * baseHeightFraction;
    final wavePhase = (progress * speed + phaseOffset) * 2 * pi;

    path.moveTo(0, baseY);

    // Curva ondulante con dos "lomos" cuya altura oscila con el tiempo —
    // simula el temblor del aire caliente en vez de una sola curva fija.
    final mid1X = size.width * 0.25;
    final mid2X = size.width * 0.75;
    final wobble1 = sin(wavePhase) * amplitude;
    final wobble2 = sin(wavePhase + pi * 0.6) * amplitude;

    path.quadraticBezierTo(mid1X, baseY - wobble1, size.width * 0.5, baseY);
    path.quadraticBezierTo(mid2X, baseY + wobble2, size.width, baseY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..color = const Color(0xFFFFA94D).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeatWavesPainter oldDelegate) => oldDelegate.progress != progress;
}