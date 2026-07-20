// lib/utils/song_id.dart
//
// Convierte el título de una canción en un ID de documento de Firestore
// válido y estable. Debe coincidir EXACTAMENTE con la lógica usada en
// tool/migrate_to_firestore.dart al subir los documentos, o las
// búsquedas por ID no van a encontrar nada.

String slugifySongTitle(String title) {
  return title.trim().toUpperCase().replaceAll('/', '-');
}