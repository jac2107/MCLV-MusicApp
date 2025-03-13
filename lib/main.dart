import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:diacritic/diacritic.dart'; // Importa la biblioteca diacritic
import 'package:musicapp/firebase_options.dart';
import 'models/Mcanciones.dart'; // Asegúrate de que la ruta sea correcta
import 'views/Vcanciones.dart'; // Asegúrate de que la ruta sea correcta

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MclvMusicApp());
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
//ESTRELLAS
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
//PANTALLA PRINCIPAL
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: -0),
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
              _buildPhysicsButton(context, 'Adoraciones', Icons.music_note, const AdoracionesPage(), _adoracionesHoverNotifier),
              const SizedBox(height: 15),
              _buildPhysicsButton(context, 'Alabanzas', Icons.headset, const AlabanzasPage(), _alabanzasHoverNotifier),
              const SizedBox(height: 15),
              _buildPhysicsButton(context, 'Para mejorar', Icons.favorite, const ParaMejorarPage(), _paraMejorarHoverNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhysicsButton(BuildContext context, String title, IconData icon, Widget page, ValueNotifier<bool> hoverNotifier) {
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
  if (page is AdoracionesPage) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
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


  // Notifiers para cada botón
  static final ValueNotifier<bool> _adoracionesHoverNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> _alabanzasHoverNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> _paraMejorarHoverNotifier = ValueNotifier(false);
}

class AdoracionesPage extends StatefulWidget {
  const AdoracionesPage({super.key});

  @override

  _AdoracionesPageState createState() => _AdoracionesPageState();
}

class _AdoracionesPageState extends State<AdoracionesPage> {
  double _opacity = 0.0;
  final TextEditingController _searchController = TextEditingController();
  List<Song> _filteredSongs = [];
  String? _selectedTonalidad; // null significa sin filtro
  bool _showFilterPanel = false; // Controla si se muestra el panel de filtros

  @override
  void initState() {
    super.initState();
    _filteredSongs = cancionesSimplificadas; // Inicialmente, todas las canciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0; // Inicia la transición (fade-in)
      });
    });
  }

  // Filtra las canciones combinando búsqueda y tonalidad seleccionada
  void _filterSongs(String query) {
    String normalizedQuery = removeDiacritics(query.toLowerCase());
    List<Song> tempSongs = cancionesSimplificadas;

    if (normalizedQuery.isNotEmpty) {
      tempSongs = tempSongs.where((song) {
        String normalizedTitle = removeDiacritics(song.title.toLowerCase());
        String normalizedText = removeDiacritics(song.text.toLowerCase());
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

  // Establece la tonalidad seleccionada y oculta el panel
  void _setTonalidad(String tonalidad) {
    setState(() {
      _selectedTonalidad = tonalidad;
      _showFilterPanel = false;
    });
    _filterSongs(_searchController.text);
  }

  // Alterna la visibilidad del panel de filtros
  void _toggleFilterPanel() {
    setState(() {
      _showFilterPanel = !_showFilterPanel;
    });
  }

  // Limpia la tonalidad seleccionada
  void _clearTonalidad() {
    setState(() {
      _selectedTonalidad = null;
    });
    _filterSongs(_searchController.text);
  }

  // Panel de filtros con dos columnas (mayores y menores)
  Widget _buildFilterPanel() {
    final List<String> majorChords = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
    final List<String> minorChords = majorChords.map((chord) => chord + "m").toList();

    Widget buildFilterButton(String chord) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ElevatedButton(
          onPressed: () => _setTonalidad(chord),
          style: ElevatedButton.styleFrom(
            backgroundColor: (_selectedTonalidad == chord) ? Colors.orangeAccent : const Color(0xFF1B263B),
            foregroundColor: Colors.white,
          ),
          child: Text(chord),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          // Columna de acordes mayores
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Mayores",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ...majorChords.map((chord) => buildFilterButton(chord)).toList(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Columna de acordes menores
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Menores",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ...minorChords.map((chord) => buildFilterButton(chord)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construye el botón para cada canción
  Widget _buildSongButton(Song song) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: song.status == 1 ? const Color(0xFF1B263B) : const Color(0xFFF4F4F4),
          foregroundColor: song.status == 1 ? Colors.white : const Color(0xFF1B263B),
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: () {
          Song fullSong = cancionesCompletas.firstWhere((s) => s.title == song.title);
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
        title: const Text("Adoraciones"),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
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
                // Fila con la barra de búsqueda y el botón de filtro
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterSongs,
                        decoration: InputDecoration(
                          hintText: "Buscar...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _toggleFilterPanel,
                      icon: const Icon(Icons.filter_list, color: Colors.white, size: 18),
                      label: _selectedTonalidad == null ? const SizedBox.shrink() : Text(_selectedTonalidad!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B263B),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_selectedTonalidad != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearTonalidad,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // Panel de filtros: se muestra solo si _showFilterPanel es true
                if (_showFilterPanel) _buildFilterPanel(),
                const SizedBox(height: 20),
                // Lista de canciones filtradas o mensaje si no hay resultados
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

class AlabanzasPage extends StatelessWidget {
  const AlabanzasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alabanzas'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: const Text('Contenido de Alabanzas'),
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
      body: Center(
        child: const Text('Contenido de Para Mejorar'),
      ),
    );
  }
}