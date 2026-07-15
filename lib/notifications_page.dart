import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notifications_handler.dart'; // Importa el handler común
String? lastHandledNotificationId;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NotificationsPage(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<SerializableMessage> _messages = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
@override
void initState() {
  super.initState();
  _requestPermissions();
  _initializeLocalNotifications();
  _loadMessages();
  _checkForInitialMessage(); // Agregado para cuando la app se abre desde terminated
  _configureFirebaseListeners(); // Asegúrate de que esto esté llamado correctamente
}

  

  void _checkForInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data.containsKey("url") && initialMessage.data["url"]!.isNotEmpty) {
      _launchURL(initialMessage.data["url"]!);
    }
  }

  Future<void> _requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission();
  }

Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null && response.payload!.isNotEmpty) {
        // Abre el enlace del payload (URL) directamente
        _launchURL(response.payload!);
      }
    },
  );
}


bool _isNotificationHandled = false;

void _configureFirebaseListeners() {
  // Escucha las notificaciones cuando la app está en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Mensaje en foreground recibido: ${message.messageId}");
    
    // Verifica si la notificación ya ha sido borrada de la barra de notificaciones
    if (message.notification != null) {
      // Solo guarda si no ha sido eliminada de la barra
      saveMessage(message);
    }
  });

  // Este listener escucha cuando la notificación es tocada
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Mensaje al hacer click (foreground): ${message.messageId}");
    if (message.data['url'] != null && message.data['url']!.isNotEmpty) {
      _launchURL(message.data['url']!);
    }
  });

  // Escucha las notificaciones cuando la app está en segundo plano o cerrada
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}


Future<void> _showNotification(RemoteMessage message) async {
  int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true, // Reproduce sonido de notificación
    autoCancel: true, // Se cancela automáticamente después de ser tocada
  );
  const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

  // Enviamos el URL como payload
  await flutterLocalNotificationsPlugin.show(
    notificationId,
    message.notification?.title,
    message.notification?.body,
    notificationDetails,
    payload: message.data['url'] ?? '',  // El URL se pasa en el payload
  );

  // Guarda el mensaje en el historial
  await saveMessage(message);
}



Future<void> _loadMessages() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? messagesJson = prefs.getStringList('messages');

  if (messagesJson != null) {
    setState(() {
      _messages = messagesJson
          .map((msg) => SerializableMessage.fromJson(json.decode(msg)))
          .toList();
    });

    // Filtrar las notificaciones que tienen "Sin título" y "Sin contenido"
    _messages.removeWhere((message) =>
        message.title == 'Sin título' && message.body == 'Sin contenido');
  }
}



  Future<void> _updateMessagesStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messagesJson = _messages.map((msg) => json.encode(msg.toJson())).toList();
    await prefs.setStringList('messages', messagesJson);
  }

Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'No se pudo abrir $url';
  }
}


  String _formatTimestamp(String timestamp) {
    DateTime date = DateTime.parse(timestamp);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}:${date.second}";
  }

  void _deleteMessage(int index) async {
    setState(() {
      _messages.removeAt(index);
    });
    await _updateMessagesStorage();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Notificaciones'),
      backgroundColor: const Color(0xFF0D1B2A),
    ),
    body: _messages.isEmpty
        ? const Center(child: Text("No hay notificaciones aún."))
        : ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final key = (message.messageId?.isNotEmpty == true)
                  ? message.messageId!
                  : index.toString();
              return Dismissible(
                key: Key(key),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  _deleteMessage(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notificación eliminada")),
                  );
                },
                child: ListTile(
                  title: Text(
                    message.title ?? 'Sin título',
                    style: TextStyle(
                      fontWeight: message.seen ? FontWeight.normal : FontWeight.bold,
                      color: message.seen ? Colors.black54 : Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.body ?? 'Sin contenido'),
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      message.seen = true;
                      _isNotificationHandled = false; // Reinicia el estado al tocar la notificación
                    });
                    _updateMessagesStorage();
                    if (message.url != null && message.url!.isNotEmpty) {
                      _launchURL(message.url!); // Abre la URL
                    }
                  },
                ),
              );
            },
          ),
  );
}
}