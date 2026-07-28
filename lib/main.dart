import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'utils/app_theme.dart';
import 'utils/theme_controller.dart';
import 'firebase_options.dart';
import 'notification_bootstrap.dart';
import 'models/song_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationBootstrap.init();
  await ThemeController.instance.load();

  // Precarga las canciones de ambas categorías en segundo plano ni bien
  // arranca la app -- SIN await, para no bloquear el splash ni la
  // navegación. syncFromFirestore ya guarda el resultado en caché local
  // (SharedPreferences) antes de devolver, así que cuando el usuario
  // entre a CategoriaPage o al picker de compartir (SongPickerPage),
  // loadFromCache() ya encuentra la versión más reciente, sin tener que
  // esperar un nuevo fetch en ese momento.
  SongRepository.instance.syncFromFirestore('adoracion');
  SongRepository.instance.syncFromFirestore('alabanza');

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