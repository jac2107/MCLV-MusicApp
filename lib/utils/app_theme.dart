import 'package:flutter/material.dart';

/// Paleta y estilos centrales del rediseño MCLV — inspirados en el logo:
/// dorado tostado, azul acero suave, crema hueso, carbón oscuro.
///
/// Estos valores base NO cambian entre modo claro/oscuro (son los mismos
/// colores de marca). Lo que cambia es CUÁLES de ellos se usan como fondo,
/// texto, tarjeta, etc. — eso vive en AppThemeData más abajo.
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

  // atardecer) que se hunde en un azul-carbón profundo abajo, en vez de
  // ir directo a negro plano.
  static const warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A4E6E), Color(0xFF232C42), charcoal],
    stops: [0.0, 0.5, 1.0],
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
  
// Día en tono rosa-dorado (mismo tono elegido para Alabanzas), más suave
// y elegante que el naranja/dorado anterior.
static const warmGradientLight = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFE8C4AE), Color(0xFFD9A488), Color(0xFFB06B52)],
  stops: [0.0, 0.5, 1.0],
);
}

class AppShapes {
  AppShapes._();

  static const double radiusLg = 28.0;
  static const double radiusMd = 20.0;
  static const double radiusSm = 14.0;

  /// `color` sigue siendo opcional (default blanco, como en tu versión
  /// original) para no romper las llamadas existentes en categoria_page.dart
  /// y otros archivos que ya usan `AppShapes.softCard(radius: ...)` sin
  /// pasar color. `dark` es nuevo y opcional: solo ajusta la sombra si se
  /// lo pasas explícitamente desde una pantalla que ya sepa que está en
  /// modo oscuro.
  static BoxDecoration softCard({Color color = Colors.white, double radius = radiusMd, bool dark = false}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: dark ? Colors.black.withOpacity(0.35) : AppColors.charcoal.withOpacity(0.08),
          blurRadius: dark ? 12 : 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration gradientButton(Gradient gradient, {double radius = radiusLg, Color? glowColor}) {
  return BoxDecoration(
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: (glowColor ?? AppColors.gold).withOpacity(0.35),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
}

/// Colección de colores "semánticos" (fondo de pantalla, texto principal,
/// texto secundario, color de tarjeta) que SÍ cambian entre modo claro y
/// oscuro. En vez de escribir `isDark ? colorA : colorB` repetido por toda
/// la app, cada pantalla simplemente hace `AppThemeData.of(context)` y usa
/// `.background`, `.cardColor`, `.textPrimary`, etc.
///
/// Diseño pensado para que NINGUNO de los dos modos canse la vista:
/// - Claro: crema cálido (no blanco puro, que sí cansa por el brillo) con
///   texto carbón (no negro puro, que da demasiado contraste).
/// - Oscuro: carbón profundo (no negro puro OLED, que crea demasiado
///   contraste con el texto y cansa igual) con texto crema suave (no
///   blanco puro).
class AppThemeData {
  final Brightness brightness;
  final Color background;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color appBarBackground;
  final Color accent;

  const AppThemeData._({
    required this.brightness,
    required this.background,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.appBarBackground,
    required this.accent,
  });

  bool get isDark => brightness == Brightness.dark;

  static const light = AppThemeData._(
    brightness: Brightness.light,
    background: AppColors.cream,
    cardColor: Colors.white,
    textPrimary: AppColors.charcoal,
    textSecondary: Color(0xFF5A5F66),
    appBarBackground: AppColors.charcoal,
    accent: Color(0xFFC98A6B), // rosa-dorado, combina con warmGradientLight
  );

  static const dark = AppThemeData._(
    brightness: Brightness.dark,
    background: AppColors.charcoal,
    cardColor: AppColors.charcoalSoft,
    textPrimary: AppColors.cream,
    textSecondary: Color(0xFFB6BAC2),
    appBarBackground: AppColors.charcoalSoft,
    accent: AppColors.gold, // dorado clásico, combina con warmGradient de noche
  );

  static AppThemeData of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

/// Construye el ThemeData completo de Material para cada modo, usado en
/// MaterialApp(theme:, darkTheme:, themeMode:).
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppThemeData.light);
  static ThemeData get dark => _build(AppThemeData.dark);

  static ThemeData _build(AppThemeData t) {
    return ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      scaffoldBackgroundColor: t.background,
      colorScheme: t.isDark
          ? ColorScheme.fromSeed(
              seedColor: AppColors.steelBlue,
              brightness: Brightness.dark,
              surface: AppColors.charcoalSoft,
              background: AppColors.charcoal,
            )
          : ColorScheme.fromSeed(
              seedColor: AppColors.steelBlue,
              brightness: Brightness.light,
              surface: Colors.white,
              background: AppColors.cream,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.appBarBackground,
        foregroundColor: t.textPrimary == AppColors.charcoal ? Colors.white : t.textPrimary,
        elevation: 0,
      ),
      textTheme: ThemeData(brightness: t.brightness).textTheme.apply(
            bodyColor: t.textPrimary,
            displayColor: t.textPrimary,
          ),
      cardColor: t.cardColor,
      dividerColor: t.isDark ? Colors.white12 : Colors.black12,
    );
  }
}