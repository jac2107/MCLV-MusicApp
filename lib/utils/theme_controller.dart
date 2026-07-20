import 'dart:async';
import 'package:flutter/material.dart';

/// Controla el modo de tema (claro/oscuro) de toda la app.
///
/// SIEMPRE arranca en modo automático por hora cada vez que se abre la
/// app: claro entre 6:00 a.m. y 6:00 p.m., oscuro el resto del día. Si el
/// usuario toca el botón de sol/luna, fuerza manualmente ese modo, pero
/// SOLO para la sesión actual — no se guarda para la próxima vez que abra
/// la app. Al volver a abrir la app, siempre vuelve a decidir según la
/// hora actual.
///
/// `toggle(context)`, `isDark(context)` y `themeMode` mantienen la misma
/// firma que antes para no romper home_page.dart ni main.dart.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  // ThemeMode.system se reutiliza para representar "modo automático por
  // hora" (no "seguir el tema del sistema operativo", que no tenía mucho
  // sentido para esta app).
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode {
    if (_themeMode == ThemeMode.system) {
      return _isDarkByTime() ? ThemeMode.dark : ThemeMode.light;
    }
    return _themeMode;
  }

  /// true si el modo automático por hora está activo ahora mismo.
  bool get isAutoMode => _themeMode == ThemeMode.system;

  bool _loaded = false;
  bool get loaded => _loaded;

  Timer? _autoCheckTimer;

  /// Llamar una sola vez en main() antes de runApp(). Siempre arranca en
  /// modo automático — no hay nada que leer de una sesión anterior, a
  /// propósito, porque la elección manual del usuario no debe persistir
  /// entre aperturas de la app.
  Future<void> load() async {
    _themeMode = ThemeMode.system;
    _loaded = true;
    _startAutoCheckIfNeeded();
    notifyListeners();
  }

  /// Mientras esté en modo automático, revisa cada minuto si ya cruzamos
  /// la frontera de las 6:00 o las 18:00 con la app abierta, para que el
  /// cambio de tema ocurra solo, sin tener que reabrir la app.
  void _startAutoCheckIfNeeded() {
    _autoCheckTimer?.cancel();
    if (_themeMode != ThemeMode.system) return;
    _autoCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      notifyListeners();
    });
  }

  bool _isDarkByTime() {
    final hour = DateTime.now().hour;
    // Claro de 6:00 (inclusive) a 18:00 (exclusive); oscuro el resto.
    return !(hour >= 6 && hour < 18);
  }

  /// Cambia el modo SOLO para la sesión actual (no se guarda en disco).
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _startAutoCheckIfNeeded();
    notifyListeners();
  }

  /// Toque simple del botón: fuerza manualmente el modo contrario al que
  /// se está viendo ahora mismo, solo por esta sesión.
  Future<void> toggle(BuildContext context) async {
    final currentlyDark = isDark(context);
    setThemeMode(currentlyDark ? ThemeMode.light : ThemeMode.dark);
  }

  /// Presión larga del botón: vuelve al modo automático por hora
  /// (aunque esto ya vuelve a pasar solo, de todas formas, la próxima vez
  /// que se abra la app).
  Future<void> resetToAuto() async {
    setThemeMode(ThemeMode.system);
  }

  /// true si el tema activo ahora mismo (por hora o forzado en esta
  /// sesión) es oscuro.
  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return _isDarkByTime(); // modo automático
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }
}