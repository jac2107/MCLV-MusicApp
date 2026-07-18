import 'package:flutter/material.dart';
import '../models/Mcanciones.dart';
import '../models/song_repository.dart';
import '../models/favorites_repository.dart';
import '../views/Vcanciones.dart';

/// Pantalla con dos pestañas:
///  - Favoritos: canciones marcadas con ❤️ por el usuario.
///  - Más usadas: canciones ordenadas por cantidad de veces abiertas.
///
/// Busca la canción completa combinando el cache de ambas categorías
/// (adoracion + alabanza), ya que un favorito puede venir de cualquiera
/// de las dos.
class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _cargando = true;
  List<Song> _favoritas = [];
  List<MapEntry<Song, int>> _masUsadas = []; // canción + veces abierta

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    // Junta canciones de ambas categorías (cache local; si está vacío usa
    // el fallback estático de Mcanciones.dart).
    final cacheAdoracion = await SongRepository.instance.loadFromCache('adoracion');
    final cacheAlabanza = await SongRepository.instance.loadFromCache('alabanza');

    final List<Song> todas = [
      ...(cacheAdoracion.isNotEmpty ? cacheAdoracion : cancionesCompletas),
      ...(cacheAlabanza.isNotEmpty ? cacheAlabanza : cancionesCompletas1),
    ];

    // Por si alguna canción quedó repetida entre cache y fallback.
    final Map<String, Song> porTitulo = {
      for (final s in todas) s.title.toUpperCase(): s,
    };

    final favTitles = await FavoritesRepository.instance.getFavoriteTitles();
    final usageCounts = await FavoritesRepository.instance.getUsageCounts();

    final favoritas = favTitles
        .map((t) => porTitulo[t])
        .whereType<Song>()
        .toList()
      ..sort((a, b) => a.title.toUpperCase().compareTo(b.title.toUpperCase()));

    final masUsadas = usageCounts.entries
        .map((e) {
          final song = porTitulo[e.key];
          if (song == null) return null;
          return MapEntry(song, e.value);
        })
        .whereType<MapEntry<Song, int>>()
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // mayor a menor uso

    if (!mounted) return;
    setState(() {
      _favoritas = favoritas;
      _masUsadas = masUsadas.take(50).toList(); // límite razonable
      _cargando = false;
    });
  }

  Future<void> _abrirCancion(Song song) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Vcanciones(cancion: song)),
    );
    // Al volver, recarga por si se agregó/quitó de favoritos desde adentro.
    _cargarDatos();
  }

  Future<void> _quitarFavorito(Song song) async {
    await FavoritesRepository.instance.toggleFavorite(song.title);
    _cargarDatos();
  }

  Widget _buildListaFavoritos() {
    if (_favoritas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Todavía no tienes canciones favoritas.\nToca el ❤️ dentro de una canción para agregarla aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _favoritas.length,
      itemBuilder: (context, index) {
        final song = _favoritas[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(song.title),
            subtitle: Text(song.tonalidad),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _quitarFavorito(song),
              tooltip: 'Quitar de favoritos',
            ),
            onTap: () => _abrirCancion(song),
          ),
        );
      },
    );
  }

  Widget _buildListaMasUsadas() {
    if (_masUsadas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Todavía no hay historial de uso.\nLas canciones que abras aquí van a aparecer.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _masUsadas.length,
      itemBuilder: (context, index) {
        final entry = _masUsadas[index];
        final song = entry.key;
        final veces = entry.value;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2F4858),
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Text(song.title),
            subtitle: Text('${song.tonalidad} · usada $veces ${veces == 1 ? "vez" : "veces"}'),
            onTap: () => _abrirCancion(song),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos y más usadas'),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            Tab(icon: Icon(Icons.trending_up), text: 'Más usadas'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListaFavoritos(),
                _buildListaMasUsadas(),
              ],
            ),
    );
  }
}