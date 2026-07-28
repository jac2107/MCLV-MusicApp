import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

const String kVersionCheckUrl = 'https://mclv-musicapp.web.app/version.json';

class InfoVersionNueva {
  final String version;
  final String downloadUrl;
  final String apkFileName;
  final String zipFileName;
  final String notas;

  InfoVersionNueva({
    required this.version,
    required this.downloadUrl,
    required this.apkFileName,
    required this.zipFileName,
    required this.notas,
  });
}

bool esVersionMasNueva(String remota, String instalada) {
  List<int> partes(String v) => v
      .split('+')
      .first
      .split('.')
      .map((p) => int.tryParse(p) ?? 0)
      .toList();

  final r = partes(remota);
  final i = partes(instalada);
  for (var idx = 0; idx < 3; idx++) {
    final rv = idx < r.length ? r[idx] : 0;
    final iv = idx < i.length ? i[idx] : 0;
    if (rv != iv) return rv > iv;
  }
  return false;
}

Future<InfoVersionNueva?> revisarVersionNueva() async {
  try {
    // El parámetro ?t=... rompe cualquier caché intermedio (CDN de
    // Firebase Hosting, proxy del operador móvil, o caché del cliente
    // http) forzando que cada request se trate como una URL distinta.
    final url = '$kVersionCheckUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    final respuesta = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));
    if (respuesta.statusCode != 200) return null;

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    final versionRemota = datos['version'] as String?;
    final downloadUrl = datos['downloadUrl'] as String?;
    final apkFileName = datos['apkFileName'] as String?;
    final zipFileName = datos['zipFileName'] as String?;

    if (versionRemota == null ||
        downloadUrl == null ||
        apkFileName == null ||
        zipFileName == null) {
      return null;
    }

    final info = InfoVersionNueva(
      version: versionRemota,
      downloadUrl: downloadUrl,
      apkFileName: apkFileName,
      zipFileName: zipFileName,
      notas: datos['notas'] as String? ?? '',
    );

    if (kIsWeb) {
      return info;
    }

    if (!Platform.isAndroid) return null;

    final paqueteInfo = await PackageInfo.fromPlatform();
    if (esVersionMasNueva(versionRemota, paqueteInfo.version)) {
      return info;
    }
    return null;
  } catch (_) {
    return null;
  }
}