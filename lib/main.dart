import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notifications_handler.dart';
import 'utils/launch_url.dart';
import 'pages/splash_page.dart';
import 'utils/app_theme.dart';
import 'utils/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Notificaciones locales: inicializar UNA sola vez, aquí, antes de
  // runApp(). Esto crea el canal de Android y registra qué hacer cuando el
  // usuario toca una notificación. SIN ESTO, en Android 13+ el sistema
  // puede bloquear notificaciones silenciosamente porque nunca se preparó
  // el canal correctamente.
  await initializeLocalNotifications(
    onTapPayload: (url) {
      if (url.isNotEmpty) {
        launchExternalUrl(url);
      }
    },
  );

  // Handler de background: UNA sola vez, aquí.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Notificación recibida con la app en PRIMER PLANO (foreground).
  // Esto es lo que faltaba en la versión que tenías: sin este listener,
  // si el usuario tiene la app abierta cuando llega la notificación, no se
  // muestra ningún banner ni se guarda en el historial.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showLocalNotification(message);
    saveMessage(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['url'] != null && message.data['url']!.isNotEmpty) {
      if (lastHandledNotificationId == message.messageId) return;
      lastHandledNotificationId = message.messageId;
      _handleNotification(message);
    }
  });

  // Si la app se abrió tocando una notificación estando totalmente cerrada.
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null &&
      initialMessage.data['url'] != null &&
      initialMessage.data['url']!.isNotEmpty) {
    lastHandledNotificationId = initialMessage.messageId;
    _handleNotification(initialMessage);
  }

  // CRÍTICO: sin pedir este permiso explícitamente, en Android 13+ (tu
  // Samsung probablemente ya es Android 13 o 14) las notificaciones push
  // NO llegan al dispositivo — el sistema operativo las descarta antes de
  // que la app pueda hacer nada con ellas. Esta era la causa más probable
  // de que tus 2 pruebas desde Firebase Console no llegaran.
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('[main] Permiso de notificaciones: ${settings.authorizationStatus}');

  await ThemeController.instance.load();
  
  runApp(const MclvMusicApp());
}

void _handleNotification(RemoteMessage message) {
  if (message.data['url'] != null && message.data['url']!.isNotEmpty) {
    if (lastHandledNotificationId == message.messageId) return;
    lastHandledNotificationId = message.messageId;
    launchExternalUrl(message.data['url']!);
  }
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