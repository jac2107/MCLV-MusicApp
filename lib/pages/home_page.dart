import 'package:flutter/material.dart';
import '../utils/launch_url.dart';
import '../utils/app_theme.dart';
import '../utils/theme_controller.dart';
import '../notifications_page.dart';
import 'feedback_page.dart';
import 'para_mejorar_page.dart';
import 'categoria_page.dart';
import 'song_picker_page.dart';
import 'favoritos_page.dart';
import '../utils/background_painters.dart';
import 'package:native_metronome/native_metronome.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // IMPORTANTE: HomePage necesita su PROPIO AnimatedBuilder escuchando a
    // ThemeController. El AnimatedBuilder de main.dart reconstruye
    // MaterialApp cuando cambia el tema, pero eso NO garantiza que los
    // widgets hijos (como HomePage) se reconstruyan también — Flutter no
    // vuelve a bajar por todo el árbol solo porque el theme cambió, a menos
    // que algo en ese árbol esté escuchando el cambio explícitamente. Sin
    // este AnimatedBuilder aquí, `isDark` se calculaba una sola vez al
    // crear la página y nunca se releía, por eso ni el ícono cambiaba.
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDark(context);
        return _HomePageContent(isDark: isDark);
      },
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final bool isDark;
  const _HomePageContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    // t.accent: dorado clásico en modo noche (combina con las estrellas),
    // rosa-dorado en modo día (combina con el nuevo warmGradientLight).
    final t = AppThemeData.of(context);

    // Fondo: noche (carbón -> azul acero) en oscuro, amanecer rosa-dorado
    // en claro.
    final backgroundGradient = isDark ? AppColors.warmGradient : AppColors.warmGradientLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.charcoal : AppColors.cream,
      body: Stack(
        children: [
          // Textura de fondo: capa 1 = degradado, capa 2 = estrellas
          // (noche) u ondas de viento (día), fija detrás de todo el
          // contenido para que no interfiera con los toques.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: backgroundGradient),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: isDark ? const StarsPainter() : const SunsetWavesPainter(),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _RoundIconButton(
                            icon: Icons.notifications_none_rounded,
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsPage()),
                            ),
                          ),
                          Row(
                            children: [
                              _RoundIconButton(
                                icon: Icons.ios_share_rounded,
                                isDark: isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SongPickerPage()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _RoundIconButton(
                                icon: Icons.favorite_border_rounded,
                                isDark: isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FavoritosPage()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _RoundIconButton(
                                icon: Icons.chat_bubble_outline_rounded,
                                isDark: isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Toque simple: fuerza manualmente claro/oscuro.
                              // Presión larga: vuelve al modo automático por
                              // hora (6:00–18:00 claro, resto oscuro).
                              GestureDetector(
                                onLongPress: () async {
                                  await ThemeController.instance.resetToAuto();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Modo automático activado (según la hora del día)'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: _RoundIconButton(
                                  icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                  isDark: isDark,
                                  onTap: () => ThemeController.instance.toggle(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: t.accent, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: t.accent.withOpacity(0.3),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/image.png', fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Misión Cristiana\nLuz de Vida',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          // En modo claro, sobre un fondo dorado/claro el
                          // texto crema casi no se lee — usa carbón ahí.
                          color: isDark ? AppColors.cream : AppColors.charcoal,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  child: Column(
                    children: [
                      _CategoryCard(
                        title: 'Adoraciones',
                        icon: Icons.piano_rounded,
                        accentColor: t.accent,
                        page: CategoriaPage(config: categoriaAdoracion),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),
                      _CategoryCard(
                        title: 'Alabanzas',
                        icon: Icons.celebration,
                        accentColor: t.accent,
                        page: CategoriaPage(config: categoriaAlabanza),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),
                      _CategoryCard(
                        title: 'Para mejorar',
                        icon: Icons.favorite_rounded,
                        accentColor: t.accent,
                        page: const ParaMejorarPage(),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 28),
                      _SocialRow(isDark: isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _RoundIconButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.white.withOpacity(0.15) : AppColors.charcoal.withOpacity(0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(icon, color: isDark ? AppColors.cream : AppColors.charcoal, size: 24),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget page;
  final bool isDark;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.page,
    required this.isDark,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    // La tarjeta ya NO usa el color de categoría como relleno principal —
    // usa el mismo gradiente noche/día que el fondo de toda la pantalla,
    // para que de verdad cambie de "clima" entre modos. El color de acento
    // (widget.accentColor, ahora t.accent) queda en la barra lateral y el
    // círculo del ícono.
    final cardGradient = widget.isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.charcoalSoft, AppColors.charcoal],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.softBlueGray.withOpacity(0.6)],
          );

    final textColor = widget.isDark ? AppColors.cream : AppColors.charcoal;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) => widget.page,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(AppShapes.radiusLg),
            border: Border.all(
              color: widget.isDark ? Colors.white.withOpacity(0.08) : AppColors.charcoal.withOpacity(0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.4 : 0.12),
                blurRadius: widget.isDark ? 14 : 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            // ClipRRect asegura que la barra de acento (que ahora se
            // estira a toda la altura real de la tarjeta) respete las
            // esquinas redondeadas del Container padre, sin importar el
            // alto que termine midiendo el contenido.
            borderRadius: BorderRadius.circular(AppShapes.radiusLg),
            child: IntrinsicHeight(
              // IntrinsicHeight hace que Flutter mida primero el contenido
              // real (ícono + texto) y luego estire la barra lateral a
              // exactamente esa altura con `double.infinity` — así nunca
              // hay que ajustar un número fijo a mano ni queda descuadrada
              // entre modo claro/oscuro.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6,
                    color: widget.accentColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(widget.isDark ? 0.22 : 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(widget.icon, color: widget.accentColor, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.5), size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  final bool isDark;
  const _SocialRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIcon(asset: 'assets/Facebook.png', url: 'https://m.facebook.com/mision.cristiana.luz.de.vida/', isDark: isDark),
        const SizedBox(width: 20),
        _SocialIcon(asset: 'assets/youtube1.png', url: 'https://www.youtube.com/@misioncristianaluzdevida', isDark: isDark),
        const SizedBox(width: 20),
        _SocialIcon(asset: 'assets/Google.png', url: 'https://sites.google.com/view/mvcl/p%C3%A1gina-principal', isDark: isDark),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String asset;
  final String url;
  final bool isDark;
  const _SocialIcon({required this.asset, required this.url, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // t.accent: dorado clásico en modo noche, rosa-dorado en modo día —
    // el dorado fijo (AppColors.gold) que antes se usaba aquí en ambos
    // modos ya solo se conserva para la rama isDark.
    final t = AppThemeData.of(context);

    return GestureDetector(
      onTap: () => launchExternalUrl(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(colors: [AppColors.charcoalSoft, AppColors.charcoal])
              : LinearGradient(colors: [Colors.white, t.accent.withOpacity(0.5)]),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.gold.withOpacity(0.4) : t.accent.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : t.accent.withOpacity(0.25),
              blurRadius: isDark ? 10 : 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(asset, width: 26, height: 26),
      ),
    );
  }
}