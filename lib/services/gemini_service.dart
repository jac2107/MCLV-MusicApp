// lib/services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  Future<List<Color>> fetchColorsFromImage(String imageUrl) async {
    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBSb6JxY4jxd2hq-6wY7ZMUjYzyYBZj5Ho'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [{
          'parts': [{
            'text': 'Analyze the colors in the image: $imageUrl'
          }]
        }]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Respuesta de la API: $data"); // Imprime la respuesta para depuración

      // Aquí puedes ajustar según la estructura de la respuesta de la API
      // Si no hay colores, puedes usar colores predeterminados
      List<Color> colors = [];

      // Verifica si hay un análisis de color en el texto
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        String analysis = data['candidates'][0]['content']['parts'][0]['text'];
        print("Análisis de colores: $analysis");
        // Aquí podrías intentar extraer colores del análisis si lo deseas
      } else {
        print("No se encontraron colores en la respuesta.");
      }

      // Si no se encontraron colores, puedes establecer colores predeterminados
      if (colors.isEmpty) {
        colors = [Colors.blue, Colors.green, Colors.red]; // Colores predeterminados
      }

      return colors;
    } else {
      throw Exception('Failed to load colors: ${response.body}');
    }
  }
}