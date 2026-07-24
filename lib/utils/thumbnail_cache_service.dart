// Selecciona en tiempo de COMPILACIÓN la implementación del cache de
// miniaturas: en Android/iOS/desktop usa dart:io (File/Directory) para
// guardar en disco; en web dart:io no existe, así que no se cachea nada
// en archivos locales (el navegador ya cachea las imágenes de red por su
// cuenta vía HTTP).
export 'thumbnail_cache_service_io.dart'
    if (dart.library.html) 'thumbnail_cache_service_web.dart';