// Iframe de YouTube embebido para la versión web, usando el mecanismo
// nativo de Flutter Web para incrustar HTML (HtmlElementView +
// platformViewRegistry). No depende de ningún paquete extra: dart:html y
// dart:ui_web vienen incluidos con el SDK de Flutter para web.
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class YoutubeIframeEmbed extends StatelessWidget {
  final String videoId;
  const YoutubeIframeEmbed({super.key, required this.videoId});

  // Cada videoId se registra una sola vez como "view factory". Si dos
  // canciones distintas usan el mismo videoId (raro, pero posible en
  // multitrack vs. video normal) no pasa nada: registrar dos veces el
  // mismo viewType tira error, por eso el chequeo con _registered.
  static final Set<String> _registered = {};

  @override
  Widget build(BuildContext context) {
    final String viewType = 'youtube-iframe-$videoId';

    if (!_registered.contains(viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final html.IFrameElement iframe = html.IFrameElement()
          ..src = 'https://www.youtube.com/embed/$videoId?rel=0'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        iframe.setAttribute(
          'allow',
          'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture',
        );
        return iframe;
      });
      _registered.add(viewType);
    }

    return HtmlElementView(viewType: viewType);
  }
}