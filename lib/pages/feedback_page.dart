import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  Future<void> _sendFeedback() async {
    String name = _nameController.text.trim();
    String feedback = _feedbackController.text.trim();

    if (name.isNotEmpty && feedback.isNotEmpty) {
      await FirebaseFirestore.instance.collection('feedback').add({
        'name': name,
        'message': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _feedbackController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Recomendación enviada!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendaciones'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'En este espacio, puedes enviarnos tus recomendaciones, reportar errores que hayas encontrado en tu dispositivo y compartir sugerencias para mejorar la aplicación. Tu opinión es fundamental para nosotros y nos ayuda a brindarte una mejor experiencia. ¡Gracias por tu aporte!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Escribe tu comentario',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendFeedback,
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}