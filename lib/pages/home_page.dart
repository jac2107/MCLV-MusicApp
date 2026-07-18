import 'package:flutter/material.dart';
import '../utils/launch_url.dart';
import '../utils/app_theme.dart';
import '../notifications_page.dart';
import 'feedback_page.dart';
import 'para_mejorar_page.dart';
import 'categoria_page.dart';
import 'song_picker_page.dart';
import 'favoritos_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // Fondo superior curvo con degradado cálido.
          // Antes: altura fija (340) más CORTA que el contenido real
          // (logo + título + fila de iconos en un Stack por encima), así
          // que el botón de compartir terminaba superpuesto justo sobre el
          // logo. Ahora todo el bloque superior (iconos + logo + título)
          // vive DENTRO de este mismo Container, uno debajo del otro en una
          // Column normal, así el fondo siempre mide lo que su contenido
          // necesita y nada se solapa.
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.warmGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(48),
                bottomRight: Radius.circular(48),
              ),
            ),
            child: SafeArea(
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsPage()),
                          ),
                        ),
                        Row(
                          children: [
                            _RoundIconButton(
                              icon: Icons.ios_share_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SongPickerPage()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _RoundIconButton(
                              icon: Icons.favorite_border_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const FavoritosPage()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _RoundIconButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const FeedbackPage()),
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
                        border: Border.all(color: AppColors.gold, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.3),
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
                    const Text(
                      'Misión Cristiana\nLuz de Vida',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // El resto del contenido (tarjetas + redes sociales) ya no vive en
          // un Stack aparte "adivinando" cuánto espacio dejar: simplemente
          // sigue debajo del fondo curvo dentro de la misma Column.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                children: [
                  _CategoryCard(
                    title: 'Adoraciones',
                    icon: Icons.piano_rounded,
                    gradient: AppColors.blueGradient,
                    page: CategoriaPage(config: categoriaAdoracion),
                  ),
                  const SizedBox(height: 18),
                  _CategoryCard(
                    title: 'Alabanzas',
                    icon: Icons.celebration,
                    // Antes usaba AppColors.goldGradient (dorado), un color
                    // totalmente distinto al resto. Ahora las 3 tarjetas
                    // comparten la misma familia de azules del fondo
                    // (steelBlueLight/softBlueGray), variando solo la
                    // intensidad, para sentirse un mismo set y no 3 botones
                    // de colores sueltos.
                    gradient: const LinearGradient(
                      colors: [AppColors.steelBlueLight, AppColors.softBlueGray],
                    ),
                    page: CategoriaPage(config: categoriaAlabanza),
                  ),
                  const SizedBox(height: 18),
                  _CategoryCard(
                    title: 'Para mejorar',
                    icon: Icons.favorite_rounded,
                    gradient: const LinearGradient(
                      colors: [AppColors.softBlueGray, AppColors.steelBlueLight],
                    ),
                    page: const ParaMejorarPage(),
                  ),
                  const SizedBox(height: 28),
                  const _SocialRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(icon, color: AppColors.cream, size: 24),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final Widget page;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.page,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    // Texto siempre blanco: ahora que las 3 tarjetas comparten la misma
    // familia de azules medio-oscuros, el blanco tiene buen contraste en
    // las 3, así que ya no hace falta la variante darkText de antes.
    const textColor = Colors.white;

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(AppShapes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: textColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.7), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIcon(asset: 'assets/Facebook.png', url: 'https://m.facebook.com/mision.cristiana.luz.de.vida/'),
        const SizedBox(width: 20),
        _SocialIcon(asset: 'assets/youtube1.png', url: 'https://www.youtube.com/@misioncristianaluzdevida'),
        const SizedBox(width: 20),
        _SocialIcon(asset: 'assets/Google.png', url: 'https://sites.google.com/view/mvcl/p%C3%A1gina-principal'),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String asset;
  final String url;
  const _SocialIcon({required this.asset, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchExternalUrl(url),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(asset, width: 26, height: 26),
      ),
    );
  }
}