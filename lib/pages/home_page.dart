import 'package:flutter/material.dart';
import '../utils/launch_url.dart';
import '../notifications_page.dart';
import 'feedback_page.dart';
import 'para_mejorar_page.dart';
import 'categoria_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 0),
                  SizedBox(
                    height: 160,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/image.png'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Misión Cristiana\nLuz de Vida',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildPhysicsButton(
                    context,
                    'Adoraciones',
                    Icons.music_note,
                    CategoriaPage(config: categoriaAdoracion),
                    _adoracionesHoverNotifier,
                  ),
                  const SizedBox(height: 15),
                  _buildPhysicsButton(
                    context,
                    'Alabanzas',
                    Icons.headset,
                    CategoriaPage(config: categoriaAlabanza),
                    _alabanzasHoverNotifier,
                  ),
                  const SizedBox(height: 15),
                  _buildPhysicsButton(
                    context,
                    'Para mejorar',
                    Icons.favorite,
                    const ParaMejorarPage(),
                    _paraMejorarHoverNotifier,
                  ),
                  const SizedBox(height: 30),
                  _BouncingIconsRow(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsPage()),
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.feedback, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeedbackPage()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicsButton(BuildContext context, String title, IconData icon,
      Widget page, ValueNotifier<bool> hoverNotifier) {
    return GestureDetector(
      onTapDown: (_) => hoverNotifier.value = true,
      onTapUp: (_) => hoverNotifier.value = false,
      onTapCancel: () => hoverNotifier.value = false,
      child: ValueListenableBuilder(
        valueListenable: hoverNotifier,
        builder: (context, isHovered, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(isHovered ? 1.08 : 1.0),
            decoration: BoxDecoration(
              color: const Color(0xFFB8860B),
              borderRadius: BorderRadius.circular(9),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: const Size(265, 65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              onPressed: () {
                if (page is CategoriaPage) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) => page,
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                }
              },
              icon: Icon(icon, size: 28),
              label: Text(
                title,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  static final ValueNotifier<bool> _adoracionesHoverNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> _alabanzasHoverNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> _paraMejorarHoverNotifier = ValueNotifier(false);
}

class _BouncingIconsRow extends StatefulWidget {
  const _BouncingIconsRow({super.key});

  @override
  State<_BouncingIconsRow> createState() => _BouncingIconsRowState();
}

class _BouncingIconsRowState extends State<_BouncingIconsRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIcon(String asset, String url) {
    return GestureDetector(
      onTap: () => launchExternalUrl(url),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_animation.value),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Image.asset(
            asset,
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon('assets/Facebook.png', 'https://m.facebook.com/mision.cristiana.luz.de.vida/'),
        _buildIcon('assets/youtube1.png', 'https://www.youtube.com/@misioncristianaluzdevida'),
        _buildIcon('assets/Google.png', 'https://sites.google.com/view/mvcl/p%C3%A1gina-principal'),
      ],
    );
  }
}