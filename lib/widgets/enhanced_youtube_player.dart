// lib/widgets/enhanced_youtube_player.dart
//
// Envuelve YoutubePlayerController con controles propios sobre
// YoutubePlayerBuilder — es IMPORTANTE usar YoutubePlayerBuilder y no
// construir un YoutubePlayer(controller) manual por segunda vez para
// fullscreen: youtube_player_flutter ata 1 WebView por cada YoutubePlayer
// que se construye con un controller. Si se arma una pantalla completa
// aparte con su propio YoutubePlayer(controller: mismoController), quedan
// DOS WebViews vivos con el mismo controller al mismo tiempo — eso es lo
// que causaba el video "congelado" en fullscreen con el audio sonando de
// fondo (el audio salía del WebView viejo, oculto detrás) y el play/pause
// desincronizado.
//
// YoutubePlayerBuilder soluciona esto: administra una sola instancia real
// del reproductor y la reubica a pantalla completa cuando
// controller.toggleFullScreenMode() se activa, incluyendo el forzado de
// orientación horizontal al entrar y vertical al salir — que es
// exactamente el comportamiento que se quiere aquí.
//
// Uso:
//   EnhancedYoutubePlayer(controller: _youtubeController!)
//
// El controller debe crearse con `hideControls: true` y `enableCaption:
// false` en sus flags (ver _getOrCreateYoutubeController en Vcanciones.dart).
//
// NOTA SOBRE SUBTÍTULOS: `enableCaption: false` le pide a YouTube que no
// active captions por defecto (manda cc_load_policy=0 al iframe). En la
// gran mayoría de videos esto los apaga. PERO si el video específico tiene
// subtítulos "forzados" por el creador/YouTube (común en video oficiales
// con letras incrustadas como parte del video, o en algunos países por
// regulación), no hay flag de youtube_player_flutter que pueda quitarlos
// — están renderizados por YouTube del lado del iframe, fuera de nuestro
// control. Si ves que persisten SOLO en ciertos videos, es casi seguro
// este caso; en otros videos del mismo tipo debería funcionar bien.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EnhancedYoutubePlayer extends StatefulWidget {
  final YoutubePlayerController controller;

  const EnhancedYoutubePlayer({super.key, required this.controller});

  @override
  State<EnhancedYoutubePlayer> createState() => _EnhancedYoutubePlayerState();
}

class _EnhancedYoutubePlayerState extends State<EnhancedYoutubePlayer> {
  bool _controlsVisible = true;
  Timer? _hideTimer;

  String? _seekFeedbackText;
  Timer? _seekFeedbackTimer;

  static const List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double _currentSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _scheduleAutoHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _seekFeedbackTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleAutoHide();
  }

  void _showSeekFeedback(String text) {
    _seekFeedbackTimer?.cancel();
    setState(() => _seekFeedbackText = text);
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _seekFeedbackText = null);
    });
  }

  void _seek(int seconds) {
    final current = widget.controller.value.position;
    var target = current + Duration(seconds: seconds);
    final duration = widget.controller.value.metaData.duration;
    if (target < Duration.zero) target = Duration.zero;
    if (duration > Duration.zero && target > duration) target = duration;
    widget.controller.seekTo(target);
    _showSeekFeedback(seconds > 0 ? '+${seconds}s' : '${seconds}s');
    _scheduleAutoHide();
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    _scheduleAutoHide();
  }

  void _setSpeed(double speed) {
    widget.controller.setPlaybackRate(speed);
    setState(() => _currentSpeed = speed);
    _scheduleAutoHide();
  }

  String _formatSpeed(double s) => s == s.roundToDouble() ? '${s.toInt()}x' : '${s}x';

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // YoutubePlayerBuilder es la única instancia real del reproductor —
    // tanto en modo normal como en fullscreen usa el MISMO widget interno,
    // sin duplicar WebViews. El forzado de orientación (horizontal al
    // entrar a fullscreen, vertical al salir) lo maneja el propio paquete.
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: widget.controller,
        showVideoProgressIndicator: false,
      ),
      builder: (context, player) {
        return GestureDetector(
          onTap: _toggleControls,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                player,

                AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.45),
                          ],
                          stops: const [0.0, 0.25, 0.7, 1.0],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PopupMenuButton<double>(
                                initialValue: _currentSpeed,
                                onSelected: _setSpeed,
                                color: Colors.black87,
                                itemBuilder: (context) => _speeds
                                    .map((s) => PopupMenuItem(
                                          value: s,
                                          child: Text(
                                            _formatSpeed(s),
                                            style: TextStyle(
                                              color: s == _currentSpeed ? Colors.redAccent : Colors.white,
                                              fontWeight: s == _currentSpeed ? FontWeight.w700 : FontWeight.normal,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text(
                                    _formatSpeed(_currentSpeed),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: widget.controller,
                                builder: (context, YoutubePlayerValue value, child) {
                                  return IconButton(
                                    icon: Icon(
                                      value.isFullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: () {
                                      widget.controller.toggleFullScreenMode();
                                      _scheduleAutoHide();
                                    },
                                    tooltip: 'Pantalla completa',
                                  );
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 32),
                                onPressed: () => _seek(-10),
                              ),
                              const SizedBox(width: 12),
                              ValueListenableBuilder(
                                valueListenable: widget.controller,
                                builder: (context, YoutubePlayerValue value, child) {
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                    child: IconButton(
                                      key: ValueKey(value.isPlaying),
                                      icon: Icon(
                                        value.isPlaying
                                            ? Icons.pause_circle_filled_rounded
                                            : Icons.play_circle_filled_rounded,
                                        color: Colors.white,
                                        size: 52,
                                      ),
                                      onPressed: _togglePlayPause,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 32),
                                onPressed: () => _seek(10),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ValueListenableBuilder(
                              valueListenable: widget.controller,
                              builder: (context, YoutubePlayerValue value, child) {
                                final duration = value.metaData.duration;
                                final position = value.position;
                                final maxSeconds = duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
                                final currentSeconds = position.inSeconds.toDouble().clamp(0.0, maxSeconds);

                                return Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 2.5,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                        activeTrackColor: Colors.redAccent,
                                        inactiveTrackColor: Colors.white30,
                                        thumbColor: Colors.redAccent,
                                      ),
                                      child: Slider(
                                        value: currentSeconds,
                                        min: 0,
                                        max: maxSeconds,
                                        onChanged: (v) {
                                          widget.controller.seekTo(Duration(seconds: v.toInt()));
                                          _scheduleAutoHide();
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_formatDuration(position),
                                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          Text(_formatDuration(duration),
                                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(anim), child: child),
                    ),
                    child: _seekFeedbackText == null
                        ? const SizedBox.shrink(key: ValueKey('empty'))
                        : Center(
                            key: ValueKey(_seekFeedbackText),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                _seekFeedbackText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}