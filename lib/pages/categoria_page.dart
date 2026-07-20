import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:diacritic/diacritic.dart' as diacritic_pkg;
import '../models/Mcanciones.dart';
import '../views/Vcanciones.dart';
import '../utils/app_theme.dart';
import 'medley.dart';
import '../models/song_repository.dart';
import '../utils/background_painters.dart';
import 'dart:ui';

class CategoriaConfig {
  final String appBarTitle;
  final Color primaryColor;
  final Color foregroundColor;
  final Gradient gradient;
  final String storageKey;
  final String categoriaKey;
  final List<Song> cancionesCompletas;
  final List<Song> cancionesSimplificadas;
  final List<Medley> medleysPredeterminados;

  const CategoriaConfig({
    required this.appBarTitle,
    required this.primaryColor,
    required this.foregroundColor,
    required this.gradient,
    required this.storageKey,
    required this.categoriaKey,
    required this.cancionesCompletas,
    required this.cancionesSimplificadas,
    required this.medleysPredeterminados,
  });
}

final CategoriaConfig categoriaAdoracion = CategoriaConfig(
  appBarTitle: "Adoraciones",
  primaryColor: AppColors.steelBlue,
  foregroundColor: Colors.white,
  gradient: AppColors.blueGradient,
  storageKey: "custom_medleys",
  categoriaKey: "adoracion",
  cancionesCompletas: cancionesCompletas,
  cancionesSimplificadas: cancionesSimplificadas,
  medleysPredeterminados: [
    Medley(name: "Dm", canciones: ["EL PODER DE TU GLORIA", "ME DISTE TODO", "FUENTE DE VIDA", "RESTAURARÉ"]),
    Medley(name: "D", canciones: ["VEN ESPÍRITU VEN", "DE GLORIA EN GLORIA", "VINE ALABAR", "RENUÉVAME", "PERDÓN"]),
    Medley(name: "E", canciones: ["NO HAY LUGAR MÁS ALTO", "NADIE COMO TÚ"]),
    Medley(name: "G", canciones: ["TEMPRANO YO TE BUSCARÉ", "ESCUCHARTE HABLAR", "NO HAY NADIE COMO TÚ", "NO BASTA"]),
  ],
);

final CategoriaConfig categoriaAlabanza = CategoriaConfig(
  appBarTitle: "Alabanzas",
primaryColor: const Color(0xFFC98A6B),
gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFD9A488), Color(0xFFC98A6B)],
),
  foregroundColor: Colors.white,

  storageKey: "custom_medleys1",
  categoriaKey: "alabanza",
  cancionesCompletas: cancionesCompletas1,
  cancionesSimplificadas: cancionesSimplificadas1,
  medleysPredeterminados: [
    Medley(name: "Am", canciones: ["LA COSECHA", "MI DIOS ES GRANDE Y FUERTE"]),
    Medley(name: "Bm", canciones: ["HOY ES TIEMPO", "REMOLINEANDO", "PODEROSO DE ISRAEL", "NO PUEDO PARAR", "DAVID DAVID", "EL SEÑOR MARCHANDO VA"]),
  ],
);

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

  List<Song> _canciones = [];
  bool _cargandoCanciones = true;
  bool _huboActualizacion = false;

  CategoriaConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _medleys = List<Medley>.from(config.medleysPredeterminados);
    _loadCustomMedleys();
    _cargarCanciones();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  Future<void> _cargarCanciones() async {
    final cache = await SongRepository.instance.loadFromCache(config.categoriaKey);

    final fallbackOrdenado = List<Song>.from(config.cancionesCompletas)
      ..sort((a, b) => a.title.toUpperCase().compareTo(b.title.toUpperCase()));

    if (!mounted) return;
    setState(() {
      _canciones = cache.isNotEmpty ? cache : fallbackOrdenado;
      _filteredSongs = _canciones;
      _cargandoCanciones = false;
    });

    SongRepository.instance.syncFromFirestore(config.categoriaKey).then((fresh) {
      if (!mounted || fresh == null) return;
      setState(() {
        _canciones = fresh;
        _huboActualizacion = true;
      });
      _filterSongs(_searchController.text);
    });
  }

  Future<void> _loadCustomMedleys() async {
    final prefs = await SharedPreferences.getInstance();
    final String? medleysJson = prefs.getString(config.storageKey);
    if (medleysJson != null) {
      List<dynamic> data = jsonDecode(medleysJson);
      List<Medley> customMedleys = data.map((map) => Medley.fromMap(map)).toList();
      if (!mounted) return;
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
    List<Song> tempSongs = _canciones;
    if (normalizedQuery.isNotEmpty) {
      tempSongs = tempSongs.where((song) {
        String normalizedTitle = diacritic_pkg.removeDiacritics(song.title.toLowerCase());
        String normalizedText = diacritic_pkg.removeDiacritics((song.textPlano ?? song.text).toLowerCase());
        return normalizedTitle.contains(normalizedQuery) || normalizedText.contains(normalizedQuery);
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
    final t = AppThemeData.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: t.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.radiusLg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.softBlueGray.withOpacity(t.isDark ? 0.3 : 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text("Opciones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: t.textPrimary)),
              const SizedBox(height: 12),
              _ModalOptionTile(
                icon: Icons.music_note_rounded,
                title: "Filtrar por Tonalidad",
                color: config.primaryColor,
                textColor: t.textPrimary,
                onTap: () {
                  Navigator.pop(context);
                  _showTonalidadFilter();
                },
              ),
              _ModalOptionTile(
                icon: Icons.queue_music_rounded,
                title: "Ver Medleys",
                color: config.primaryColor,
                textColor: t.textPrimary,
                onTap: () {
                  Navigator.pop(context);
                  _showMedleys();
                },
              ),
              _ModalOptionTile(
                icon: Icons.add_circle_outline_rounded,
                title: "Crear Medley",
                color: config.primaryColor,
                textColor: t.textPrimary,
                onTap: () {
                  Navigator.pop(context);
                  _showCrearMedley();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showTonalidadFilter() {
    final t = AppThemeData.of(context);
    final List<String> majorChords = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
    final List<String> minorChords = majorChords.map((chord) => chord + "m").toList();

    Widget buildFilterButton(String chord) {
      final bool selected = _selectedTonalidad == chord;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 3.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _selectedTonalidad = chord;
            });
            _filterSongs(_searchController.text);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? config.primaryColor : t.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? config.primaryColor : t.textSecondary.withOpacity(0.3)),
            ),
            child: Text(
              chord,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : t.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          height: 440,
          decoration: BoxDecoration(
            color: t.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.radiusLg)),
          ),
          child: Column(
            children: [
              Text("Filtrar por Tonalidad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: t.textPrimary)),
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text("Mayores", style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Expanded(child: ListView(children: majorChords.map(buildFilterButton).toList())),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: [
                          Text("Menores", style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Expanded(child: ListView(children: minorChords.map(buildFilterButton).toList())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _clearTonalidad();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: t.textPrimary,
                    side: BorderSide(color: t.textSecondary.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Limpiar Filtro"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMedleys() {
    final t = AppThemeData.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int? expandedIndex;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              decoration: BoxDecoration(
                color: t.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.radiusLg)),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _medleys.length,
                itemBuilder: (context, index) {
                  Medley medley = _medleys[index];
                  bool isExpanded = expandedIndex == index;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: AppShapes.softCard(color: t.cardColor, dark: t.isDark),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(medley.name, style: TextStyle(fontWeight: FontWeight.w700, color: t.textPrimary)),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: config.primaryColor),
                          onTap: () {
                            Navigator.pop(context);
                            _openMedleyDetail(medley);
                          },
                          onLongPress: medley.isCustom
                              ? () async {
                                  final String? option = await showDialog<String>(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: Text("Opciones para \"${medley.name}\""),
                                        children: [
                                          SimpleDialogOption(onPressed: () => Navigator.pop(context, "edit"), child: const Text("Editar")),
                                          SimpleDialogOption(onPressed: () => Navigator.pop(context, "delete"), child: const Text("Borrar")),
                                        ],
                                      );
                                    },
                                  );
                                  if (option == "edit") {
                                    Medley? updatedMedley = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CrearMedleyPage(config: config, medley: medley, canciones: _canciones)),
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
                                              content: Text("El medley \"${medley.name}\" se borrará. ¿Estás seguro?"),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Borrar")),
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
                              : () {
                                  setModalState(() {
                                    expandedIndex = isExpanded ? null : index;
                                  });
                                },
                        ),
                        ClipRect(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Wrap(
                                      spacing: 8.0,
                                      children: medley.canciones.map((cancion) => Text("- $cancion", style: TextStyle(color: t.textPrimary))).toList(),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
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
      MaterialPageRoute(builder: (context) => CrearMedleyPage(config: config, canciones: _canciones)),
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
      MaterialPageRoute(builder: (context) => MedleyDetailPage(config: config, medley: medley, canciones: _canciones)),
    );
  }

Widget _buildSongButton(Song song, AppThemeData t) {
  final glassFill = t.isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.35);
  final glassBorder = t.isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.55);

  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Vcanciones(cancion: song)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: song.status == 1
            ? AppShapes.gradientButton(
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    config.gradient.colors.first.withOpacity(0.55),
                    config.gradient.colors.last.withOpacity(0.55),
                  ],
                ),
                radius: AppShapes.radiusMd,
                glowColor: config.primaryColor,
              )
            : BoxDecoration(
                  color: glassFill,
                  borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                  border: Border.all(color: glassBorder, width: 1.2),
                ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  song.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: song.status == 1 ? Colors.white : t.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: song.status == 1 ? Colors.white70 : config.primaryColor,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  @override
Widget build(BuildContext context) {
  final t = AppThemeData.of(context);
  return Scaffold(
    backgroundColor: t.background,
    body: Stack(
      children: [
        Positioned.fill(
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: t.isDark
            ? [AppColors.charcoal, Color.alphaBlend(config.primaryColor.withOpacity(0.25), AppColors.charcoal)]
            : [Color.alphaBlend(config.primaryColor.withOpacity(0.35), AppColors.cream), AppColors.cream],
      ),
    ),
  ),
),
Positioned.fill(
  child: IgnorePointer(
    child: t.isDark ? const StarsPainter() : const SunsetWavesPainter(),
  ),
),
        CustomScrollView(
          slivers: [
          SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: config.primaryColor.withOpacity(0.55),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
                title: Text(config.appBarTitle, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        config.primaryColor.withOpacity(0.45),
                        config.primaryColor.withOpacity(0.15),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
              if (_cargandoCanciones)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                )
              else if (_huboActualizacion)
                const Padding(padding: EdgeInsets.all(12.0), child: Icon(Icons.cloud_done_rounded, color: Colors.white, size: 22)),
            ],
          ),
          SliverToBoxAdapter(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: AppShapes.softCard(color: t.cardColor, radius: AppShapes.radiusMd, dark: t.isDark),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: t.textPrimary),
                              onChanged: (value) {
                                _filterSongs(value);
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: "Buscar canción...",
                                hintStyle: TextStyle(color: t.textSecondary),
                                prefixIcon: Icon(Icons.search_rounded, color: config.primaryColor),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear_rounded, color: t.textSecondary),
                                        onPressed: () {
                                          _searchController.clear();
                                          _filterSongs('');
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: config.primaryColor,
                          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                            onTap: _showFilterOptions,
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(Icons.tune_rounded, color: Colors.white),
                            ),
                          ),
                        ),
                        if (_selectedTonalidad != null) ...[
                          const SizedBox(width: 8),
                          Material(
                            color: t.cardColor,
                            borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                              onTap: _clearTonalidad,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(Icons.close_rounded, color: t.textPrimary),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    _filteredSongs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text("No hay canciones en esa tonalidad", style: TextStyle(color: t.textSecondary)),
                            ),
                          )
                        : Column(
                            children: _filteredSongs.map((s) => _buildSongButton(s, t)).toList(),
                          ),
                  ],
                ),
              ),
            ),
        )],
          ),
        ],
      ),
    );
  }
}

class _ModalOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ModalOptionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      onTap: onTap,
    );
  }
}