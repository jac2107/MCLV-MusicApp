// Clase de datos pura (Dart puro, sin dependencias de Firebase) para
// serializar el historial de notificaciones guardado en SharedPreferences.
// Vive en un archivo aparte para que notifications_page.dart pueda
// importarla SIN arrastrar transitivamente firebase_messaging (que rompe
// la compilación web — ver notification_bootstrap.dart para el detalle).
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