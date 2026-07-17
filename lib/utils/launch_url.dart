import 'package:url_launcher/url_launcher.dart';

/// Abre una URL externa (redes sociales, YouTube, etc.) en el navegador o
/// app correspondiente. Centralizado aquí porque lo usan varias páginas
/// (HomePage, _BouncingIconsRow, notificaciones) y así se evita duplicarlo.
Future<void> launchExternalUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'No se pudo abrir $url';
  }
}