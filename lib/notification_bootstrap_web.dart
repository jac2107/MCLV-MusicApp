// En web no hay notificaciones push/locales configuradas (requeriría
// service worker + VAPID key aparte). No-op a propósito: este archivo NO
// importa firebase_messaging ni flutter_local_notifications, así que esos
// paquetes ni se compilan para web.
class NotificationBootstrap {
  static Future<void> init() async {}
}