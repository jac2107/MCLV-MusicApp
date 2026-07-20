import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  bool _sending = false;

  Future<void> _sendFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);

    final name = _nameController.text.trim();
    final feedback = _feedbackController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'name': name,
        'message': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _feedbackController.clear();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('¡Gracias! Tu recomendación fue enviada.'),
            ],
          ),
          backgroundColor: AppColors.steelBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusSm)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar, intenta de nuevo: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppThemeData.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: const Text('Recomendaciones'),
        backgroundColor: t.appBarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado con ícono, en vez de solo un párrafo de texto
                // suelto: le da una intención visual clara a la pantalla.
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppShapes.softCard(
                    color: t.cardColor,
                    radius: AppShapes.radiusLg,
                    dark: t.isDark,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat_bubble_rounded, color: AppColors.gold, size: 30),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Cuéntanos qué piensas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: t.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Envíanos recomendaciones, reporta errores o comparte '
                        'ideas para mejorar la app. Tu opinión nos ayuda a '
                        'seguir creciendo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tu nombre',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  enabled: !_sending,
                  style: TextStyle(color: t.textPrimary),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Escribe tu nombre' : null,
                  decoration: _fieldDecoration(t, hint: 'Ej: Jhoan'),
                ),
                const SizedBox(height: 18),
                Text(
                  'Tu comentario',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feedbackController,
                  enabled: !_sending,
                  maxLines: 5,
                  style: TextStyle(color: t.textPrimary),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Escribe tu comentario' : null,
                  decoration: _fieldDecoration(t, hint: 'Escribe aquí tu recomendación...'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _sendFeedback,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    label: Text(_sending ? 'Enviando...' : 'Enviar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusMd)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(AppThemeData t, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: t.textSecondary.withOpacity(0.6)),
      filled: true,
      fillColor: t.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        borderSide: BorderSide(color: t.isDark ? Colors.white12 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        borderSide: BorderSide(color: t.isDark ? Colors.white12 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}