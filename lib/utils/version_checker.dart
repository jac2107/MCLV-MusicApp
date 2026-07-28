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

/// Compara "1.2.0" vs "1.1.0" componente por componente. true si `remota`
/// es estrictamente mayor que `instalada`.
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

/// En Android: devuelve info SOLO si hay una versión más nueva que la
/// instalada. En web: devuelve SIEMPRE la última publicada (no hay
/// "versión instalada" con la que comparar -- la web siempre sirve la
/// última build de por sí, pero el botón de descarga de APK debe
/// aparecer siempre para quien todavía no tiene la app).
Future<InfoVersionNueva?> revisarVersionNueva() async {
  try {
    final respuesta = await http
        .get(Uri.parse(kVersionCheckUrl))
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
      // Web: siempre se ofrece la descarga, no hay versión "instalada".
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