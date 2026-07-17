import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notifications_handler.dart';
import 'utils/launch_url.dart';
import 'pages/splash_page.dart';

// Variable global para evitar duplicados
String? lastHandledNotificationId;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    print("Mensaje en background: ${message.messageId}");
    await saveMessage(message);
  } catch (e, s) {
    print("Error en background handler: $e");
    print(s);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['url'] != null && message.data['url']!.isNotEmpty) {
      if (lastHandledNotificationId == message.messageId) return;
      lastHandledNotificationId = message.messageId;
      _handleNotification(message);
    }
  });

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MCLV MusicApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}