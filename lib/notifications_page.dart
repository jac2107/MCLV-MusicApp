import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'utils/launch_url.dart';
import 'utils/app_theme.dart';
import 'notifications_handler.dart'; // Importa el handler común

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<SerializableMessage> _messages = [];
  bool _loading = true;

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

    List<SerializableMessage> loaded = [];
    if (messagesJson != null) {
      loaded = messagesJson
          .map((msg) => SerializableMessage.fromJson(json.decode(msg)))
          .toList();

      // Filtrar las notificaciones que tienen "Sin título" y "Sin contenido"
      loaded.removeWhere((message) =>
          message.title == 'Sin título' && message.body == 'Sin contenido');

      // Más recientes primero.
      loaded.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    if (!mounted) return;
    setState(() {
      _messages = loaded;
      _loading = false;
    });
  }

  Future<void> _updateMessagesStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messagesJson = _messages.map((msg) => json.encode(msg.toJson())).toList();
    await prefs.setStringList('messages', messagesJson);
  }

  String _formatTimestamp(String timestamp) {
    final date = DateTime.tryParse(timestamp);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24 && now.day == date.day) return 'Hoy · ${_hourMinute(date)}';
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.day == date.day && yesterday.month == date.month) {
      return 'Ayer · ${_hourMinute(date)}';
    }
    return '${date.day}/${date.month}/${date.year} · ${_hourMinute(date)}';
  }

  String _hourMinute(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _deleteMessage(int index) async {
    setState(() {
      _messages.removeAt(index);
    });
    await _updateMessagesStorage();
  }

  void _markAsSeen(SerializableMessage message) {
    setState(() {
      message.seen = true;
    });
    _updateMessagesStorage();
    if (message.url != null && message.url!.isNotEmpty) {
      launchExternalUrl(message.url!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppThemeData.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: t.appBarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? _buildEmptyState(t)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final key = (message.messageId?.isNotEmpty == true)
                        ? message.messageId!
                        : '$index-${message.timestamp}';
                    return _NotificationTile(
                      key: Key(key),
                      message: message,
                      themeData: t,
                      formattedTime: _formatTimestamp(message.timestamp),
                      onTap: () => _markAsSeen(message),
                      onDismissed: () {
                        _deleteMessage(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificación eliminada')),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(AppThemeData t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: t.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones aún',
              style: TextStyle(fontSize: 16, color: t.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una fila de notificación individual: simple, sin adornos extra —
/// solo un punto indicador de "no leída", título, cuerpo y fecha relativa.
class _NotificationTile extends StatelessWidget {
  final SerializableMessage message;
  final AppThemeData themeData;
  final String formattedTime;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationTile({
    super.key,
    required this.message,
    required this.themeData,
    required this.formattedTime,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final bool unread = !message.seen;

    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.85),
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppShapes.softCard(
              color: t.cardColor,
              radius: AppShapes.radiusMd,
              dark: t.isDark,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Punto indicador de no leída: simple, no un ícono grande.
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 12),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unread ? AppColors.gold : Colors.transparent,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title ?? 'Sin título',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                          color: t.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.body ?? 'Sin contenido',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: t.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedTime,
                        style: TextStyle(fontSize: 12, color: t.textSecondary.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}