import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/Mcanciones.dart'; // Asegúrate de que la ruta sea correcta
import 'views/Vcanciones.dart';
import 'notifications_handler.dart';
import 'notifications_page.dart'; // Archivo de notificaciones
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:diacritic/diacritic.dart' as diacritic_pkg;

// Variable global para evitar duplicados
String? lastHandledNotificationId;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    print("Mensaje en background: ${message.messageId}");
    await saveMessage(message);
  } catch (e, s) {
    print("Error en background handler: $e");
    print(s);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['url'] != null && message.data['url']!.isNotEmpty) {
      if (lastHandledNotificationId == message.messageId) return;
      lastHandledNotificationId = message.messageId;
      _handleNotification(message);
    }
  });

  runApp(const MclvMusicApp());
}

Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'No se pudo abrir $url';
  }
}

void _handleNotification(RemoteMessage message) {
  if (message.data['url'] != null && message.data['url']!.isNotEmpty) {
    if (lastHandledNotificationId == message.messageId) return;
    lastHandledNotificationId = message.messageId;
    _launchURL(message.data['url']!);
  }
}

class MclvMusicApp extends StatelessWidget {
  const MclvMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MCLV MusicApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class NotificationHistoryManager {
  static const MethodChannel _channel =
      MethodChannel('com.example.musicapp/notifications');

  static void initialize(void Function(Map<String, dynamic>) onNotificationReceived) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "onNotificationPosted") {
        final Map<String, dynamic> notificationData =
            Map<String, dynamic>.from(call.arguments);
        onNotificationReceived(notificationData);
      }
    });
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  Future<void> _sendFeedback() async {
    String name = _nameController.text.trim();
    String feedback = _feedbackController.text.trim();

    if (name.isNotEmpty && feedback.isNotEmpty) {
      await FirebaseFirestore.instance.collection('feedback').add({
        'name': name,
        'message': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Recomendación enviada!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendaciones'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'En este espacio, puedes enviarnos tus recomendaciones, reportar errores que hayas encontrado en tu dispositivo y compartir sugerencias para mejorar la aplicación. Tu opinión es fundamental para nosotros y nos ayuda a brindarte una mejor experiencia. ¡Gracias por tu aporte!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Escribe tu comentario',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendFeedback,
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _starAnimation;

  @override
  void initState() {
    super.initState();
    NotificationHistoryManager.initialize((notificationData) {
      print("Notificación recibida desde el servicio nativo: $notificationData");
    });
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _starAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _starAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: StarPainter(_starAnimation.value),
                child: Container(),
              );
            },
          ),
          Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: const Text(
                'MusicApp\nM.C.L.V',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cinzel',
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final double offsetY;

  StarPainter(this.offsetY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final Random random = Random();
    for (int i = 0; i < 10; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = (random.nextDouble() * size.height) + offsetY;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

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
      onTap: () => _launchURL(url),
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

// ====================== NÚCLEO UNIFICADO ======================
// Antes: Medley/Medley1, CrearMedleyPage/CrearMedleyPage1,
// MedleyDetailPage/MedleyDetailPage1, AdoracionesPage/AlabanzasPage.
// Ahora: una sola versión de cada uno, parametrizada por CategoriaConfig.

class Medley {
  final String name;
  final List<String> canciones;
  final bool isCustom;

  Medley({required this.name, required this.canciones, this.isCustom = false});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'canciones': canciones,
      'isCustom': isCustom,
    };
  }

  factory Medley.fromMap(Map<String, dynamic> map) {
    return Medley(
      name: map['name'] as String,
      canciones: List<String>.from(map['canciones'] as List),
      isCustom: map['isCustom'] as bool,
    );
  }
}

// Configuración de cada categoría: colores, textos, listas de canciones y
// medleys predeterminados. Aquí es donde vive lo que antes eran clases duplicadas.
class CategoriaConfig {
  final String appBarTitle;
  final Color primaryColor;
  final Color foregroundColor;
  final String storageKey; // key en SharedPreferences para medleys custom
  final List<Song> cancionesCompletas;
  final List<Song> cancionesSimplificadas;
  final List<Medley> medleysPredeterminados;

  const CategoriaConfig({
    required this.appBarTitle,
    required this.primaryColor,
    required this.foregroundColor,
    required this.storageKey,
    required this.cancionesCompletas,
    required this.cancionesSimplificadas,
    required this.medleysPredeterminados,
  });
}

final CategoriaConfig categoriaAdoracion = CategoriaConfig(
  appBarTitle: "Adoraciones",
  primaryColor: const Color(0xFF2F4858),
  foregroundColor: Colors.white,
  storageKey: "custom_medleys",
  cancionesCompletas: cancionesCompletas,
  cancionesSimplificadas: cancionesSimplificadas,
  medleysPredeterminados: [
    Medley(
      name: "Dm",
      canciones: ["EL PODER DE TU GLORIA", "ME DISTE TODO", "FUENTE DE VIDA", "RESTAURARÉ"],
    ),
    Medley(
      name: "D",
      canciones: ["VEN ESPÍRITU VEN", "DE GLORIA EN GLORIA", "VINE ALABAR", "RENUÉVAME", "PERDÓN"],
    ),
    Medley(
      name: "E",
      canciones: ["NO HAY LUGAR MÁS ALTO", "NADIE COMO TÚ"],
    ),
    Medley(
      name: "G",
      canciones: ["TEMPRANO YO TE BUSCARÉ", "ESCUCHARTE HABLAR", "NO HAY NADIE COMO TÚ", "NO BASTA"],
    ),
  ],
);

final CategoriaConfig categoriaAlabanza = CategoriaConfig(
  appBarTitle: "Alabanzas",
  primaryColor: const Color(0xFFC49A6C),
  foregroundColor: Colors.white,
  storageKey: "custom_medleys1",
  cancionesCompletas: cancionesCompletas1,
  cancionesSimplificadas: cancionesSimplificadas1,
  medleysPredeterminados: [
    Medley(
      name: "Am",
      canciones: ["LA COSECHA", "MI DIOS ES GRANDE Y FUERTE"],
    ),
    Medley(
      name: "Bm",
      canciones: [
        "HOY ES TIEMPO",
        "REMOLINEANDO",
        "PODEROSO DE ISRAEL",
        "NO PUEDO PARAR",
        "DAVID DAVID",
        "EL SEÑOR MARCHANDO VA"
      ],
    ),
  ],
);

// ====================== CrearMedleyPage (unificada) ======================
class CrearMedleyPage extends StatefulWidget {
  final CategoriaConfig config;
  final Medley? medley;
  const CrearMedleyPage({Key? key, required this.config, this.medley}) : super(key: key);

  @override
  _CrearMedleyPageState createState() => _CrearMedleyPageState();
}

class _CrearMedleyPageState extends State<CrearMedleyPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedSongs = [];
  final ScrollController _scrollController = ScrollController();

  bool _showNameError = false;

  @override
  void initState() {
    super.initState();
    if (widget.medley != null) {
      _nameController.text = widget.medley!.name;
      _selectedSongs.addAll(widget.medley!.canciones);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    setState(() {
      _showNameError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medley == null ? "Crear Medley" : "Editar Medley"),
        backgroundColor: widget.config.primaryColor,
        foregroundColor: widget.config.foregroundColor,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nombre del Medley",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _showNameError ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _showNameError ? Colors.red : Colors.blue,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty && _showNameError) {
                  setState(() {
                    _showNameError = false;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Selecciona las canciones (el orden en que las toques será el orden del medley):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.config.cancionesCompletas.length,
              itemBuilder: (context, index) {
                Song song = widget.config.cancionesCompletas[index];
                bool isSelected = _selectedSongs.contains(song.title.toUpperCase());
                return CheckboxListTile(
                  title: Text(song.title),
                  value: isSelected,
                  onChanged: (bool? newValue) {
                    setState(() {
                      if (newValue == true) {
                        if (!_selectedSongs.contains(song.title.toUpperCase())) {
                          _selectedSongs.add(song.title.toUpperCase());
                        }
                      } else {
                        _selectedSongs.remove(song.title.toUpperCase());
                      }
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isEmpty) {
                _showError("Falta ingresar el nombre del medley.");
                return;
              }
              if (_selectedSongs.isEmpty) {
                _showError("Debes seleccionar al menos una canción.");
                return;
              }
              Medley nuevoMedley = Medley(
                name: _nameController.text,
                canciones: List.from(_selectedSongs),
                isCustom: true,
              );
              Navigator.pop(context, nuevoMedley);
            },
            child: Text(widget.medley == null ? "Guardar" : "Actualizar"),
          ),
        )
      ],
    );
  }
}

// ====================== MedleyDetailPage (unificada) ======================
class MedleyDetailPage extends StatelessWidget {
  final CategoriaConfig config;
  final Medley medley;
  const MedleyDetailPage({Key? key, required this.config, required this.medley}) : super(key: key);

  List<Song> getSongsForMedley() {
    List<Song> medleySongs = [];
    for (var title in medley.canciones) {
      try {
        Song song = config.cancionesCompletas.firstWhere(
          (s) => s.title.toUpperCase() == title.toUpperCase(),
        );
        medleySongs.add(song);
      } catch (e) {
        // Ignorar si no se encuentra.
      }
    }
    return medleySongs;
  }

  final Color primaryColor = const Color.fromARGB(255, 0, 0, 0);
  final Color secondaryColor = const Color.fromARGB(255, 161, 119, 69);
  final Color accentColor = const Color.fromARGB(255, 96, 139, 151);

  // NOTA: igual que en el original, esta función no transpone nada todavía.
  // La dejo tal cual estaba (return chord;) para no cambiar comportamiento
  // sin que me lo pidas explícitamente.
  String transposeChord(String chord) {
    return chord;
  }

  List<TextSpan> parseLyrics(String text) {
    final chordRegex = RegExp(r'\b[A-G][#b]?(m|maj|min|dim|aug|sus\d*|7|m7)?\d*\b');
    final keywordRegex = RegExp(
        r'\b(CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?:\s\d+)?|PRE-CORO|CORO(?:\s\d+)?|INSTRUMENTAL|FINAL|ESTROFA|SOLO|PUENTE(?:\s\d+)?)\b');
    List<TextSpan> spans = [];
    for (final line in text.split('\n')) {
      List<TextSpan> lineSpans = [];
      for (final word in line.split(' ')) {
        String transposedWord = word;
        if (chordRegex.hasMatch(word)) {
          transposedWord = transposeChord(word);
        }
        TextStyle textStyle;
        if (chordRegex.hasMatch(word)) {
          textStyle = TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
          );
        } else if (keywordRegex.hasMatch(word.toUpperCase())) {
          textStyle = TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
          );
        } else {
          textStyle = TextStyle(color: primaryColor);
        }
        lineSpans.add(TextSpan(text: '$transposedWord ', style: textStyle));
      }
      spans.add(const TextSpan(text: '\n'));
      spans.addAll(lineSpans);
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final List<Song> medleySongs = getSongsForMedley();
    return Scaffold(
      appBar: AppBar(
        title: Text(medley.name),
        backgroundColor: config.primaryColor,
        foregroundColor: config.foregroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: medleySongs.map((song) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18),
                      children: parseLyrics(song.text),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ====================== CategoriaPage (unifica AdoracionesPage/AlabanzasPage) ======================
class CategoriaPage extends StatefulWidget {
  final CategoriaConfig config;
  const CategoriaPage({Key? key, required this.config}) : super(key: key);

  @override
  _CategoriaPageState createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  double _opacity = 0.0;
  final TextEditingController _searchController = TextEditingController();
  List<Song> _filteredSongs = [];
  String? _selectedTonalidad;
  late List<Medley> _medleys;

  CategoriaConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _filteredSongs = config.cancionesSimplificadas;
    _medleys = List<Medley>.from(config.medleysPredeterminados);
    _loadCustomMedleys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  Future<void> _loadCustomMedleys() async {
    final prefs = await SharedPreferences.getInstance();
    final String? medleysJson = prefs.getString(config.storageKey);
    if (medleysJson != null) {
      List<dynamic> data = jsonDecode(medleysJson);
      List<Medley> customMedleys = data.map((map) => Medley.fromMap(map)).toList();
      setState(() {
        _medleys.addAll(customMedleys);
      });
    }
  }

  Future<void> _saveCustomMedleys() async {
    final prefs = await SharedPreferences.getInstance();
    List<Medley> customMedleys = _medleys.where((m) => m.isCustom).toList();
    String data = jsonEncode(customMedleys.map((m) => m.toMap()).toList());
    await prefs.setString(config.storageKey, data);
  }

  void _filterSongs(String query) {
    String normalizedQuery = diacritic_pkg.removeDiacritics(query.toLowerCase());
    List<Song> tempSongs = config.cancionesSimplificadas;
    if (normalizedQuery.isNotEmpty) {
      tempSongs = tempSongs.where((song) {
        String normalizedTitle = diacritic_pkg.removeDiacritics(song.title.toLowerCase());
        String normalizedText = diacritic_pkg.removeDiacritics(song.text.toLowerCase());
        return normalizedTitle.contains(normalizedQuery) ||
            normalizedText.contains(normalizedQuery);
      }).toList();
    }
    if (_selectedTonalidad != null) {
      tempSongs = tempSongs.where((song) => song.tonalidad == _selectedTonalidad).toList();
    }
    setState(() {
      _filteredSongs = tempSongs;
    });
  }

  void _clearTonalidad() {
    setState(() {
      _selectedTonalidad = null;
    });
    _filterSongs(_searchController.text);
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Opciones",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text("Filtrar por Tonalidad"),
                onTap: () {
                  Navigator.pop(context);
                  _showTonalidadFilter();
                },
              ),
              ListTile(
                leading: const Icon(Icons.queue_music),
                title: const Text("Ver Medleys"),
                onTap: () {
                  Navigator.pop(context);
                  _showMedleys();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Crear Medley"),
                onTap: () {
                  Navigator.pop(context);
                  _showCrearMedley();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTonalidadFilter() {
    final List<String> majorChords = [
      "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
    ];
    final List<String> minorChords = majorChords.map((chord) => chord + "m").toList();

    Widget buildFilterButton(String chord) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedTonalidad = chord;
            });
            _filterSongs(_searchController.text);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                (_selectedTonalidad == chord) ? Colors.orangeAccent : config.primaryColor,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          child: Text(chord),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 400,
          child: Column(
            children: [
              const Text(
                "Filtrar por Tonalidad",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Mayores"),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              children:
                                  majorChords.map((chord) => buildFilterButton(chord)).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Menores"),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              children:
                                  minorChords.map((chord) => buildFilterButton(chord)).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _clearTonalidad();
                  Navigator.pop(context);
                },
                child: const Text("Limpiar Filtro"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMedleys() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        int? expandedIndex;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _medleys.length,
                itemBuilder: (context, index) {
                  Medley medley = _medleys[index];
                  bool isExpanded = expandedIndex == index;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          medley.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            Navigator.pop(context);
                            _openMedleyDetail(medley);
                          },
                        ),
                        onTap: () {
                          setModalState(() {
                            expandedIndex = isExpanded ? null : index;
                          });
                        },
                        onLongPress: medley.isCustom
                            ? () async {
                                final String? option = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                      title: Text("Opciones para \"${medley.name}\""),
                                      children: [
                                        SimpleDialogOption(
                                          onPressed: () => Navigator.pop(context, "edit"),
                                          child: const Text("Editar"),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () => Navigator.pop(context, "delete"),
                                          child: const Text("Borrar"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (option == "edit") {
                                  Medley? updatedMedley = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CrearMedleyPage(
                                        config: config,
                                        medley: medley,
                                      ),
                                    ),
                                  );
                                  if (updatedMedley != null) {
                                    setState(() {
                                      int index = _medleys.indexOf(medley);
                                      _medleys[index] = updatedMedley;
                                    });
                                    await _saveCustomMedleys();
                                  }
                                } else if (option == "delete") {
                                  final bool confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Confirmar Borrado"),
                                            content: Text(
                                              "El medley \"${medley.name}\" se borrará. ¿Estás seguro?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text("Cancelar"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text("Borrar"),
                                              ),
                                            ],
                                          );
                                        },
                                      ) ??
                                      false;
                                  if (confirmed) {
                                    setState(() {
                                      _medleys.remove(medley);
                                    });
                                    await _saveCustomMedleys();
                                  }
                                }
                              }
                            : null,
                      ),
                      ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: isExpanded
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 4.0),
                                  child: Wrap(
                                    spacing: 8.0,
                                    children: medley.canciones
                                        .map((cancion) => Text("- $cancion"))
                                        .toList(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showCrearMedley() async {
    Medley? newMedley = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearMedleyPage(config: config),
      ),
    );
    if (newMedley != null) {
      setState(() {
        _medleys.add(newMedley);
      });
      await _saveCustomMedleys();
    }
  }

  void _openMedleyDetail(Medley medley) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedleyDetailPage(config: config, medley: medley),
      ),
    );
  }

  Widget _buildSongButton(Song song) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: song.status == 1 ? config.primaryColor : const Color(0xFFEAEAEA),
          foregroundColor: song.status == 1 ? Colors.white : const Color(0xFF404040),
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: () {
          Song fullSong =
              config.cancionesCompletas.firstWhere((s) => s.title == song.title);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Vcanciones(cancion: fullSong)),
          );
        },
        child: Text(song.title, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config.appBarTitle),
        backgroundColor: config.primaryColor,
        foregroundColor: config.foregroundColor,
      ),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _filterSongs(value);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Buscar...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterSongs('');
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: _showFilterOptions,
                      tooltip: 'Filtros',
                    ),
                    if (_selectedTonalidad != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearTonalidad,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _filteredSongs.isEmpty
                    ? const Text("No hay canciones en esa tonalidad")
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredSongs.length,
                        itemBuilder: (context, index) {
                          return _buildSongButton(_filteredSongs[index]);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParaMejorarPage extends StatelessWidget {
  const ParaMejorarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Para Mejorar'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Contenido de Para Mejorar'),
      ),
    );
  }
}