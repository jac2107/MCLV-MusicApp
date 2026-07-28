import 'dart:js_interop';

@JS('descargarApkDesdeZip')
external JSPromise _descargarApkDesdeZip(JSString zipUrl, JSString apkFileName);

Future<void> descargarApkWeb(String zipUrl, String apkFileName) async {
  await _descargarApkDesdeZip(zipUrl.toJS, apkFileName.toJS).toDart;
}