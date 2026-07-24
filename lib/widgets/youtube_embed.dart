// En Android/iOS no se usa este widget (la UI llama a YoutubeIframeEmbed
// solo dentro de bloques `if (kIsWeb)`), pero el ARCHIVO igual necesita
// poder importarse en todas las plataformas — por eso el stub. dart:html
// y dart:ui_web solo existen en compilaciones web.
export 'youtube_embed_stub.dart' if (dart.library.html) 'youtube_embed_web.dart';