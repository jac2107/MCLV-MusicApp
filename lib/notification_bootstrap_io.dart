import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notifications_handler.dart';
import 'utils/launch_url.dart';

class NotificationBootstrap {
  static Future<void> init() async {
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

    // CRÍTICO: sin pedir este permiso explícitamente, en Android 13+ las
    // notificaciones push NO llegan al dispositivo — el sistema operativo
    // las descarta antes de que la app pueda hacer nada con ellas.
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[NotificationBootstrap] Permiso de notificaciones: ${settings.authorizationStatus}');
  }

  static void _handleNotification(RemoteMessage message) {
    if (message.data['url'] != null && message.data['url']!.isNotEmpty) {
      if (lastHandledNotificationId == message.messageId) return;
      lastHandledNotificationId = message.messageId;
      launchExternalUrl(message.data['url']!);
    }
  }
}