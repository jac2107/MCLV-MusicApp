import 'package:flutter/material.dart';

/// Paleta y estilos centrales del rediseño MCLV — inspirados en el logo:
/// dorado tostado, azul acero suave, crema hueso, carbón oscuro.
class AppColors {
  AppColors._();

  static const gold = Color(0xFFC9A24B);
  static const goldLight = Color(0xFFE0C179);
  static const steelBlue = Color(0xFF7EA0B0);
  static const steelBlueLight = Color(0xFFA8C3CE);
  static const cream = Color(0xFFF5F1E8);
  static const softBlueGray = Color(0xFFDCE4E8);
  static const charcoal = Color(0xFF1B1E23);
  static const charcoalSoft = Color(0xFF2C313A);

  // Gradiente cálido principal (splash, fondos hero)
  static const warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [charcoal, charcoalSoft, steelBlue],
  );

  // Gradiente dorado para acentos/botones
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold],
  );

  // Gradiente azul para la sección Alabanzas
  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [steelBlueLight, steelBlue],
  );
}

class AppShapes {
  AppShapes._();

  static const double radiusLg = 28.0;
  static const double radiusMd = 20.0;
  static const double radiusSm = 14.0;

  static BoxDecoration softCard({Color color = Colors.white, double radius = radiusMd}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.charcoal.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration gradientButton(Gradient gradient, {double radius = radiusLg}) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.gold.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}