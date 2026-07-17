import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:diacritic/diacritic.dart' as diacritic_pkg;
import '../models/Mcanciones.dart';
import '../views/Vcanciones.dart';
import 'medley.dart';

// Configuración de cada categoría: colores, textos, listas de canciones y
// medleys predeterminados. Así CategoriaPage sirve tanto para Adoraciones
// como para Alabanzas sin duplicar código.
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

// ====================== CategoriaPage ======================
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
      if (!mounted) return;
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