import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Mcanciones.dart';

class SongRepository {
  SongRepository._();
  static final SongRepository instance = SongRepository._();

  static const _cacheKeyPrefix = 'canciones_cache_'; // + categoria
  static const _lastSyncKeyPrefix = 'canciones_last_sync_'; // + categoria
  static const _newTitlesKeyPrefix = 'canciones_nuevas_'; // + categoria
String _normalizeForSort(String text) {
  const diacritics = {
    'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'U': 'Ú',
    'Ñ': 'N', 
  };
  String normalized = text.toUpperCase();
  diacritics.forEach((key, value) {
    normalized = normalized.replaceAll(key, value);
  });
  return normalized;
}
  /// Lee las canciones guardadas localmente para una categoría
  /// ("adoracion" o "alabanza"). Devuelve lista vacía si nunca se
  /// sincronizó (primera instalación sin internet).
  Future<List<Song>> loadFromCache(String categoria) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKeyPrefix + categoria);
    if (raw == null) return [];
    final List<dynamic> data = jsonDecode(raw);
    final songs = data.map((m) => Song.fromMap(Map<String, dynamic>.from(m))).toList();
    songs.sort((a, b) => _normalizeForSort(a.title).compareTo(_normalizeForSort(b.title)));
    return songs;
  }

  /// Guarda la lista de canciones en el cache local.
  Future<void> _saveToCache(String categoria, List<Song> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final data = songs.map((s) => s.toMap()).toList();
    await prefs.setString(_cacheKeyPrefix + categoria, jsonEncode(data));
  }

  /// Intenta sincronizar con Firestore. Si hay internet, descarga las
  /// canciones de esa categoría, las compara con el cache actual, guarda
  /// las nuevas/actualizadas y devuelve la lista fresca.
  /// Si NO hay internet (o Firestore falla), devuelve null sin lanzar
  /// error — quien llama debe seguir usando el cache existente.
 Future<List<Song>?> syncFromFirestore(String categoria) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('canciones')
          .where('categoria', isEqualTo: categoria)
          .get(const GetOptions(source: Source.server)) // fuerza red, no cache de Firestore
          .timeout(const Duration(seconds: 10));

      final songsFromServer = snapshot.docs
          .map((doc) => Song.fromMap(doc.data()))
          .toList();

      // Orden alfabético por título, sin distinguir mayúsculas/minúsculas.
      songsFromServer.sort((a, b) => _normalizeForSort(a.title).compareTo(_normalizeForSort(b.title)));
      // Detectar cuáles son nuevas respecto al cache anterior
      final cached = await loadFromCache(categoria);
      final cachedTitles = cached.map((s) => s.title.toUpperCase()).toSet();
      final nuevas = songsFromServer
          .where((s) => !cachedTitles.contains(s.title.toUpperCase()))
          .map((s) => s.title)
          .toList();

      await _saveToCache(categoria, songsFromServer);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastSyncKeyPrefix + categoria,
        DateTime.now().toIso8601String(),
      );
      if (nuevas.isNotEmpty) {
        await prefs.setStringList(_newTitlesKeyPrefix + categoria, nuevas);
      }

      return songsFromServer;
    } catch (e) {
      // Sin internet, timeout, o error de Firestore: no pasa nada,
      // la app sigue funcionando con lo que ya había en cache.
      return null;
    }
  }

  /// Punto de entrada recomendado para la UI: devuelve el cache de
  /// inmediato (para pintar la pantalla ya) y dispara la sincronización
  /// en segundo plano, avisando por [onUpdated] si trajo cambios.
  Future<List<Song>> getSongs(
    String categoria, {
    void Function(List<Song> songsActualizadas)? onUpdated,
  }) async {
    final cached = await loadFromCache(categoria);

    // Sincroniza en segundo plano sin bloquear el arranque de la pantalla
    syncFromFirestore(categoria).then((fresh) {
      if (fresh != null && onUpdated != null) {
        onUpdated(fresh);
      }
    });

    return cached;
  }

  /// Últimos títulos marcados como "nuevos" en la sincronización más
  /// reciente para esa categoría (para un futuro apartado "Canciones
  /// nuevas" en la UI).
  Future<List<String>> getNewTitles(String categoria) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_newTitlesKeyPrefix + categoria) ?? [];
  }

  /// Limpia el listado de "nuevas" (ej. cuando el usuario ya las vio).
  Future<void> clearNewTitles(String categoria) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_newTitlesKeyPrefix + categoria);
  }

  Future<DateTime?> getLastSync(String categoria) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKeyPrefix + categoria);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}