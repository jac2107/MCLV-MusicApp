import 'package:flutter/material.dart';

class ParaMejorarPage extends StatelessWidget {
  const ParaMejorarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Para Mejorar'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Contenido de Para Mejorar'),
      ),
    );
  }
}