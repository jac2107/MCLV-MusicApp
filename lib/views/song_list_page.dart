// song_list_page.dart
import 'package:flutter/material.dart';
import '../models/Mcanciones.dart'; // Asegúrate de importar tu modelo
import 'Vcanciones.dart'; // Importa la página de detalles de la canción

class SongListPage extends StatelessWidget {
  const SongListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Canciones"),
      ),
      body: ListView.builder(
        itemCount: cancionesCompletas.length,
        itemBuilder: (context, index) {
          final song = cancionesCompletas[index];
          return ListTile(
            title: Text(song.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Vcanciones(cancion: song), // Pasa la canción seleccionada
                ),
              );
            },
          );
        },
      ),
    );
  }
}