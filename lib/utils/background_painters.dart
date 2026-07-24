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
@override
void paint(Canvas canvas, Size size) {
  _drawRibbon(canvas, size,
      baseHeightFraction: 0.04,
      amplitude: 26,
      strokeWidth: 2.4,
      opacity: 0.09,
      speed: 0.55,
      phaseOffset: 0.02,
      freq: 1.3);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.08,
      amplitude: 38,
      strokeWidth: 1.2,
      opacity: 0.07,
      speed: 0.85,
      phaseOffset: 0.55,
      freq: 2.0);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.12,
      amplitude: 22,
      strokeWidth: 2.0,
      opacity: 0.10,
      speed: 0.60,
      phaseOffset: 0.12,
      freq: 1.7);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.16,
      amplitude: 42,
      strokeWidth: 1.2,
      opacity: 0.08,
      speed: 1.0,
      phaseOffset: 0.70,
      freq: 1.0);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.21,
      amplitude: 30,
      strokeWidth: 2.6,
      opacity: 0.11,
      speed: 0.55,
      phaseOffset: 0.32,
      freq: 1.5);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.25,
      amplitude: 18,
      strokeWidth: 1.6,
      opacity: 0.08,
      speed: 1.20,
      phaseOffset: 0.08,
      freq: 2.3);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.30,
      amplitude: 36,
      strokeWidth: 2.2,
      opacity: 0.10,
      speed: 0.75,
      phaseOffset: 0.48,
      freq: 1.1);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.35,
      amplitude: 24,
      strokeWidth: 1.4,
      opacity: 0.08,
      speed: 0.95,
      phaseOffset: 0.82,
      freq: 1.9);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.40,
      amplitude: 44,
      strokeWidth: 2.4,
      opacity: 0.10,
      speed: 0.50,
      phaseOffset: 0.22,
      freq: 1.3);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.45,
      amplitude: 20,
      strokeWidth: 1.6,
      opacity: 0.08,
      speed: 1.10,
      phaseOffset: 0.64,
      freq: 2.2);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.49,
      amplitude: 34,
      strokeWidth: 2.0,
      opacity: 0.09,
      speed: 0.70,
      phaseOffset: 0.36,
      freq: 1.2);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.54,
      amplitude: 26,
      strokeWidth: 1.4,
      opacity: 0.08,
      speed: 0.90,
      phaseOffset: 0.12,
      freq: 1.8);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.58,
      amplitude: 40,
      strokeWidth: 2.2,
      opacity: 0.09,
      speed: 0.55,
      phaseOffset: 0.74,
      freq: 1.0);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.63,
      amplitude: 22,
      strokeWidth: 1.8,
      opacity: 0.08,
      speed: 1.00,
      phaseOffset: 0.18,
      freq: 2.0);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.67,
      amplitude: 36,
      strokeWidth: 2.4,
      opacity: 0.10,
      speed: 0.45,
      phaseOffset: 0.60,
      freq: 1.4);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.72,
      amplitude: 28,
      strokeWidth: 1.6,
      opacity: 0.08,
      speed: 0.80,
      phaseOffset: 0.92,
      freq: 2.0);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.76,
      amplitude: 42,
      strokeWidth: 2.0,
      opacity: 0.09,
      speed: 0.60,
      phaseOffset: 0.40,
      freq: 1.0);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.81,
      amplitude: 24,
      strokeWidth: 1.4,
      opacity: 0.08,
      speed: 1.10,
      phaseOffset: 0.30,
      freq: 2.1);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.85,
      amplitude: 34,
      strokeWidth: 2.2,
      opacity: 0.09,
      speed: 0.65,
      phaseOffset: 0.70,
      freq: 1.3);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.90,
      amplitude: 20,
      strokeWidth: 1.6,
      opacity: 0.07,
      speed: 1.20,
      phaseOffset: 0.14,
      freq: 2.3);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.94,
      amplitude: 30,
      strokeWidth: 2.6,
      opacity: 0.08,
      speed: 0.60,
      phaseOffset: 0.54,
      freq: 1.2);

  _drawRibbon(canvas, size,
      baseHeightFraction: 0.98,
      amplitude: 18,
      strokeWidth: 1.2,
      opacity: 0.06,
      speed: 1.00,
      phaseOffset: 0.88,
      freq: 1.7);
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
    ..color = const Color.fromARGB(255, 254, 115, 1).withOpacity(opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;

  canvas.drawPath(path, paint);
}
  @override
  bool shouldRepaint(covariant _RibbonWavesPainter oldDelegate) => oldDelegate.progress != progress;
}
