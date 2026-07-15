import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SerializableMessage {
  final String? messageId;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? url;
  final String timestamp;
  bool seen;

  SerializableMessage({
    this.messageId,
    this.title,
    this.body,
    this.data,
    this.url,
    required this.timestamp,
    this.seen = false,
  });

  factory SerializableMessage.fromJson(Map<String, dynamic> json) {
    return SerializableMessage(
      messageId: json['messageId'] ?? '',
      title: json['title'] ?? 'Sin título',
      body: json['body'] ?? 'Sin contenido',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      url: json['url'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().toLocal().toString(),
      seen: json['seen'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'title': title,
      'body': body,
      'data': data,
      'url': url,
      'timestamp': timestamp,
      'seen': seen,
    };
  }
}

/// Función que guarda el mensaje en SharedPreferences
Future<void> saveMessage(RemoteMessage message, {bool seen = false}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> messagesJson = prefs.getStringList('messages') ?? [];

  String messageId = message.messageId ?? '';
  
  // No guardes mensajes con "Sin título" y "Sin contenido"
  if (message.notification?.title == 'Sin título' && message.notification?.body == 'Sin contenido') {
    return; // No guardes esta notificación
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



/// Handler unificado para mensajes en segundo plano
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await saveMessage(message); // Guarda el mensaje en el historial
}