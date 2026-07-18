import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Maneja dos cosas relacionadas con el uso de canciones, guardadas
/// localmente con SharedPreferences (igual patrón que SongRepository):
///
/// 1) Favoritos: lista de títulos marcados con ❤️ por el usuario.
/// 2) Historial de uso: cuántas veces se abrió cada canción, para el
///    apartado de "Más usadas".
///
/// Se identifica cada canción por su `title` (en mayúsculas, para no
/// duplicar por diferencias de mayúsculas/minúsculas), igual que ya se
/// hace con los nombres de canciones dentro de Medley.
class FavoritesRepository {
  FavoritesRepository._();
  static final FavoritesRepository instance = FavoritesRepository._();

  static const _favoritesKey = 'song_favorites';
  static const _usageCountKey = 'song_usage_counts';

  // ====================== FAVORITOS ======================

  Future<Set<String>> getFavoriteTitles() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  Future<bool> isFavorite(String title) async {
    final favs = await getFavoriteTitles();
    return favs.contains(title.toUpperCase());
  }

  /// Alterna el estado de favorito de una canción y devuelve el nuevo
  /// estado (true = quedó como favorita, false = se quitó).
  Future<bool> toggleFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = (prefs.getStringList(_favoritesKey) ?? []).toSet();
    final key = title.toUpperCase();

    final bool nowFavorite;
    if (favs.contains(key)) {
      favs.remove(key);
      nowFavorite = false;
    } else {
      favs.add(key);
      nowFavorite = true;
    }

    await prefs.setStringList(_favoritesKey, favs.toList());
    return nowFavorite;
  }

  // ====================== HISTORIAL DE USO ======================

  /// Suma 1 al contador de reproducciones/aperturas de esa canción.
  /// Se llama cada vez que se abre Vcanciones para esa canción.
  Future<void> registerSongOpened(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usageCountKey);
    Map<String, dynamic> counts = raw != null ? jsonDecode(raw) : {};

    final key = title.toUpperCase();
    counts[key] = (counts[key] as int? ?? 0) + 1;

    await prefs.setString(_usageCountKey, jsonEncode(counts));
  }

  /// Devuelve un mapa {TITULO_EN_MAYUSCULAS: vecesAbierta}.
  Future<Map<String, int>> getUsageCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usageCountKey);
    if (raw == null) return {};
    final Map<String, dynamic> data = jsonDecode(raw);
    return data.map((key, value) => MapEntry(key, value as int));
  }

  /// Limpia todo el historial de uso (útil si en algún momento quieres
  /// agregar un botón de "Reiniciar estadísticas").
  Future<void> clearUsageCounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usageCountKey);
  }
}