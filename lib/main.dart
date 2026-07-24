import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'utils/app_theme.dart';
import 'utils/theme_controller.dart';
import 'firebase_options.dart';
import 'notification_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // En Android/iOS esto inicializa notificaciones push + locales. En web es
  // un no-op (ver notification_bootstrap.dart) — así firebase_messaging
  // nunca se compila para el target web, donde su paquete web no es
  // compatible con el SDK de Dart actual.
  await NotificationBootstrap.init();

  await ThemeController.instance.load();

  runApp(const MclvMusicApp());
}

class MclvMusicApp extends StatelessWidget {
  const MclvMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MCLV MusicApp',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeController.instance.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}