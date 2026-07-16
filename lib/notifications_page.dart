import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'notifications_handler.dart'; // Importa el handler común

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

  @override
  void initState() {
    super.initState();
    // La inicialización de Firebase Messaging y notificaciones locales ya se
    // hace UNA sola vez en main.dart al arrancar la app. Esta pantalla solo
    // necesita leer el historial ya guardado.
    _loadMessages();
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