import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailCacheService {
  static Future<Directory> _cacheDir() async {
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${base.path}/thumbnail_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Devuelve la ruta local si la miniatura ya está cacheada, o null si no.
  static Future<String?> getCachedPath(String cacheKey) async {
    final Directory dir = await _cacheDir();
    final File file = File('${dir.path}/$cacheKey.jpg');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  /// Guarda los bytes descargados en disco y devuelve la ruta local.
  static Future<String> save(String cacheKey, List<int> bytes) async {
    final Directory dir = await _cacheDir();
    final File file = File('${dir.path}/$cacheKey.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<void> deleteCached(String cacheKey) async {
    try {
      final Directory dir = await _cacheDir();
      final File file = File('${dir.path}/$cacheKey.jpg');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // No crítico.
    }
  }

  static bool isLocalPath(String path) {
    return path.isNotEmpty && !path.startsWith('http') && path != 'assets/image.png';
  }

  static Widget imageFromLocalPath(
    String path, {
    required double height,
    required BoxFit fit,
    required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
  }) {
    return Image.file(
      File(path),
      fit: fit,
      height: height,
      width: double.infinity,
      errorBuilder: errorBuilder,
    );
  }

  static ImageProvider imageProviderFromLocalPath(String path) {
    return FileImage(File(path));
  }
}