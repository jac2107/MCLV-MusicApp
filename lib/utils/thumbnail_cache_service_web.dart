// En web nunca se guardan miniaturas en disco (no aplica), así que estos
// métodos son no-op / siempre devuelven "no hay cache". El código que los
// llama (_getThumbnailUrl en Vcanciones.dart) ya evita tomar estas rutas en
// web con un chequeo de kIsWeb, así que en la práctica no se usan.
import 'package:flutter/material.dart';

class ThumbnailCacheService {
  static Future<String?> getCachedPath(String cacheKey) async => null;
  static Future<String> save(String cacheKey, List<int> bytes) async => '';
  static Future<void> deleteCached(String cacheKey) async {}
  static bool isLocalPath(String path) => false;

  static Widget imageFromLocalPath(
    String path, {
    required double height,
    required BoxFit fit,
    required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
  }) {
    return const SizedBox.shrink();
  }

  static ImageProvider imageProviderFromLocalPath(String path) {
    return const AssetImage('assets/image.png');
  }
}