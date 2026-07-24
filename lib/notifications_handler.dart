import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'models/serializable_message.dart';

/// Variable única y compartida para evitar procesar la misma notificación dos veces.
/// Antes existía una copia de esta variable en main.dart y otra en notifications_page.dart,
/// lo que hacía que la deduplicación no funcionara entre ambos flujos.
String? lastHandledNotificationId;

/// Instancia única del plugin de notificaciones locales, compartida por toda la app.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
  'mclv_default_channel',
  'Notificaciones MCLV',
  description: 'Notificaciones generales de la aplicación',
  importance: Importance.max,
);

/// Debe llamarse una sola vez, al inicio de main(), antes de runApp().
Future<void> initializeLocalNotifications({
  void Function(String payload)? onTapPayload,
}) async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (onTapPayload != null &&
          response.payload != null &&
          response.payload!.isNotEmpty) {
        onTapPayload(response.payload!);
      }
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_defaultChannel);
}

/// Muestra el banner/notificación visual al usuario cuando la app está en foreground.
/// Antes esta función existía pero nunca se llamaba desde el listener de onMessage,
/// por eso las notificaciones "no se veían" con la app abierta.
Future<void> showLocalNotification(RemoteMessage message) async {
  final String? title = message.notification?.title;
  final String? body = message.notification?.body;
  if (title == null && body == null) return; // Nada que mostrar visualmente

  final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    _defaultChannel.id,
    _defaultChannel.name,
    channelDescription: _defaultChannel.description,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    autoCancel: true,
  );
  final NotificationDetails details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    title,
    body,
    details,
    payload: message.data['url'] ?? '',
  );
}

/// Función que guarda el mensaje en SharedPreferences
Future<void> saveMessage(RemoteMessage message, {bool seen = false}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> messagesJson = prefs.getStringList('messages') ?? [];

  String messageId = message.messageId ?? '';

  // Solo descarta el mensaje si NO tiene título/cuerpo Y TAMPOCO tiene datos personalizados.
  // Antes se descartaba cualquier mensaje sin 'notification', incluso si traía 'data' útil.
  final bool hasNotificationContent =
      message.notification?.title != null || message.notification?.body != null;
  final bool hasDataContent = message.data.isNotEmpty;
  if (!hasNotificationContent && !hasDataContent) {
    return; // Mensaje realmente vacío, no hay nada que guardar
  }

  if (messagesJson.any((msgJson) => SerializableMessage.fromJson(json.decode(msgJson)).messageId == messageId)) {
    return; // Si el mensaje ya existe, no hacer nada
  }

  final newMessage = SerializableMessage(
    messageId: messageId,
    title: message.notification?.title ?? 'Sin título',
    body: message.notification?.body ?? 'Sin contenido',
    data: message.data,
    url: message.data['url'] ?? '',
    timestamp: DateTime.now().toLocal().toString(),
    seen: seen,
  );

  messagesJson.add(json.encode(newMessage.toJson()));
  await prefs.setStringList('messages', messagesJson);
  print("Notificación guardada: ${newMessage.toJson()}");
}



/// Handler único para mensajes en segundo plano/app cerrada.
/// IMPORTANTE: debe registrarse UNA sola vez, en main() antes de runApp(),
/// nunca dentro de un widget (antes se registraba dos veces: en main.dart
/// y otra vez dentro de NotificationsPage, lo cual es redundante e innecesario).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Corre en un isolate separado: necesita inicializar Firebase por su cuenta.
    await Firebase.initializeApp();
    await saveMessage(message);
  } catch (e, s) {
    print("Error en background handler: $e");
    print(s);
  }
}