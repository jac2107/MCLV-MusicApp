import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart' as diacritic_pkg;
import '../models/Mcanciones.dart';
import '../utils/app_theme.dart';
import '../utils/chord_transposer.dart';
import '../utils/song_pdf_generator.dart';
import 'package:printing/printing.dart';
import 'categoria_page.dart';

// ====================== Medley (modelo) ======================
class Medley {
  final String name;
  final List<String> canciones;
  final bool isCustom;
  // Tonalidad elegida por canción AL CREAR el medley, en semitonos respecto
  // a la tonalidad original de cada canción (0 = sin cambio). Se guarda
  // junto con el resto del medley, así que persiste en el teléfono como
  // cualquier otro dato del medley.
  final Map<String, int> transposiciones;

  Medley({
    required this.name,
    required this.canciones,
    this.isCustom = false,
    this.transposiciones = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'canciones': canciones,
      'isCustom': isCustom,
      'transposiciones': transposiciones,
    };
  }

  factory Medley.fromMap(Map<String, dynamic> map) {
    return Medley(
      name: map['name'] as String,
      canciones: List<String>.from(map['canciones'] as List),
      isCustom: map['isCustom'] as bool,
      // Medleys guardados ANTES de este cambio no tienen este campo — usar
      // {} como default evita romper la carga de medleys viejos.
      transposiciones: map['transposiciones'] != null
          ? Map<String, int>.from(
              (map['transposiciones'] as Map).map((k, v) => MapEntry(k as String, (v as num).toInt())))
          : {},
    );
  }
}

// ====================== CrearMedleyPage ======================
// Sin cambios: sigue guardando el medley (nombre + lista de títulos) tal
// cual lo hacía antes. La transposición para compartir vive en
// MedleyDetailPage y nunca toca este modelo ni lo guardado en el teléfono.
class CrearMedleyPage extends StatefulWidget {
  final CategoriaConfig config;
  final Medley? medley;
  final List<Song>? canciones;
  const CrearMedleyPage({Key? key, required this.config, this.medley, this.canciones})
      : super(key: key);
  @override
  _CrearMedleyPageState createState() => _CrearMedleyPageState();
}

class _CrearMedleyPageState extends State<CrearMedleyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedSongs = [];
  // Semitonos elegidos por canción ANTES de guardar el medley — esto es lo
  // que se persiste en Medley.transposiciones al presionar Guardar.
  final Map<String, int> _transposiciones = {};
  final ScrollController _scrollController = ScrollController();

  bool _showNameError = false;

  List<Song> _todas = [];
  List<Song> _filtradas = [];

  @override
  void initState() {
    super.initState();
    if (widget.medley != null) {
      _nameController.text = widget.medley!.name;
      _selectedSongs.addAll(widget.medley!.canciones);
      _transposiciones.addAll(widget.medley!.transposiciones);
    }
    _todas = widget.canciones ?? widget.config.cancionesCompletas;
    _filtradas = _todas;
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

  // Mismo patrón de búsqueda ya usado en CategoriaPage: normaliza tildes
  // para que buscar "cancion" encuentre "canción".
  void _filterSongs(String query) {
    final normalizedQuery = diacritic_pkg.removeDiacritics(query.toLowerCase());
    if (normalizedQuery.isEmpty) {
      setState(() => _filtradas = _todas);
      return;
    }
    setState(() {
      _filtradas = _todas.where((song) {
        final normalizedTitle = diacritic_pkg.removeDiacritics(song.title.toLowerCase());
        return normalizedTitle.contains(normalizedQuery);
      }).toList();
    });
  }

  void _toggleSong(Song song) {
    final key = song.title.toUpperCase();
    setState(() {
      if (_selectedSongs.contains(key)) {
        _selectedSongs.remove(key);
        _transposiciones.remove(song.title);
      } else {
        _selectedSongs.add(key);
      }
    });
  }

  void _ajustarTransposicion(Song song, int delta) {
    setState(() {
      final actual = _transposiciones[song.title] ?? 0;
      _transposiciones[song.title] = actual + delta;
    });
  }

  void _resetTransposicion(Song song) {
    setState(() {
      _transposiciones.remove(song.title);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppThemeData.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(widget.medley == null ? "Crear Medley" : "Editar Medley"),
        backgroundColor: widget.config.primaryColor,
        foregroundColor: widget.config.foregroundColor,
      ),
      body: Column(
        children: [
          // Nombre del medley + buscador viven fijos arriba (no se van con
          // el scroll de la lista), así siempre están a mano mientras el
          // usuario revisa canciones.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: t.textPrimary),
                  decoration: InputDecoration(
                    labelText: "Nombre del Medley",
                    labelStyle: TextStyle(color: t.textSecondary),
                    filled: true,
                    fillColor: t.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                      borderSide: BorderSide(
                        color: _showNameError ? Colors.redAccent : Colors.transparent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                      borderSide: BorderSide(
                        color: _showNameError ? Colors.redAccent : Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                      borderSide: BorderSide(
                        color: _showNameError ? Colors.redAccent : widget.config.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && _showNameError) {
                      setState(() => _showNameError = false);
                    }
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  "Selecciona las canciones (el orden en que las toques será el orden del medley):",
                  style: TextStyle(fontSize: 14, color: t.textSecondary),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: t.textPrimary),
                  onChanged: _filterSongs,
                  decoration: InputDecoration(
                    hintText: 'Buscar canción...',
                    hintStyle: TextStyle(color: t.textSecondary.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search_rounded, color: widget.config.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: t.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _filterSongs('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: t.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          // Contador de seleccionadas, visible siempre que haya al menos una.
          if (_selectedSongs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.config.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppShapes.radiusSm),
                  ),
                  child: Text(
                    '${_selectedSongs.length} seleccionada${_selectedSongs.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.config.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: _filtradas.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron canciones.',
                      style: TextStyle(color: t.textSecondary),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: _filtradas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final song = _filtradas[index];
                      final selected = _selectedSongs.contains(song.title.toUpperCase());
                      final semitones = _transposiciones[song.title] ?? 0;
                      return _MedleySongTile(
                        song: song,
                        selected: selected,
                        semitones: semitones,
                        themeData: t,
                        accentColor: widget.config.primaryColor,
                        onTap: () => _toggleSong(song),
                        onTransposeUp: () => _ajustarTransposicion(song, 1),
                        onTransposeDown: () => _ajustarTransposicion(song, -1),
                        onTransposeReset: () => _resetTransposicion(song),
                      );
                    },
                  ),
          ),
        ],
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
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
                // Solo guardamos transposiciones de canciones que siguen
                // seleccionadas — evita arrastrar entradas huérfanas si el
                // usuario quitó una canción después de ajustarla.
                transposiciones: {
                  for (final entry in _transposiciones.entries)
                    if (_selectedSongs.contains(entry.key.toUpperCase())) entry.key: entry.value,
                },
              );
              Navigator.pop(context, nuevoMedley);
            },
            style: FilledButton.styleFrom(
              backgroundColor: widget.config.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusMd)),
            ),
            child: Text(widget.medley == null ? "Guardar" : "Actualizar"),
          ),
        )
      ],
    );
  }
}

/// Tarjeta de canción para la selección de medley — mismo lenguaje visual
/// que _SongPickTile en song_picker_page.dart, pero con `accentColor`
/// parametrizable (usa el color de la categoría: azul para Adoración,
/// dorado para Alabanza) en vez de siempre dorado.
class _MedleySongTile extends StatelessWidget {
  final Song song;
  final bool selected;
  final int semitones;
  final AppThemeData themeData;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onTransposeUp;
  final VoidCallback onTransposeDown;
  final VoidCallback onTransposeReset;

  const _MedleySongTile({
    required this.song,
    required this.selected,
    required this.semitones,
    required this.themeData,
    required this.accentColor,
    required this.onTap,
    required this.onTransposeUp,
    required this.onTransposeDown,
    required this.onTransposeReset,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeData;
    final String tonalidadMostrada =
        semitones == 0 ? song.tonalidad : transposeKeyName(song.tonalidad, semitones);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(AppShapes.radiusMd),
            border: Border.all(
              color: selected ? accentColor : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: t.isDark ? Colors.black.withOpacity(0.35) : AppColors.charcoal.withOpacity(0.06),
                blurRadius: t.isDark ? 10 : 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? accentColor : Colors.transparent,
                      border: Border.all(
                        color: selected ? accentColor : t.textSecondary.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              tonalidadMostrada,
                              style: TextStyle(
                                fontSize: 13,
                                color: semitones == 0 ? t.textSecondary : accentColor,
                                fontWeight: semitones == 0 ? FontWeight.normal : FontWeight.w700,
                              ),
                            ),
                            if (semitones != 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(original ${song.tonalidad})',
                                style: TextStyle(fontSize: 11, color: t.textSecondary.withOpacity(0.7)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Los controles de tonalidad solo tienen sentido si la
              // canción ya está en el medley — por eso solo se muestran
              // cuando `selected` es true.
              if (selected) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _TransposeMiniButton(icon: Icons.remove, color: accentColor, onTap: onTransposeDown),
                    Container(
                      constraints: const BoxConstraints(minWidth: 34),
                      alignment: Alignment.center,
                      child: Text(
                        semitones == 0 ? '±0' : (semitones > 0 ? '+$semitones' : '$semitones'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: semitones == 0 ? t.textSecondary : accentColor,
                        ),
                      ),
                    ),
                    _TransposeMiniButton(icon: Icons.add, color: accentColor, onTap: onTransposeUp),
                    if (semitones != 0) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onTransposeReset,
                        child: Text(
                          'restablecer',
                          style: TextStyle(
                            fontSize: 12,
                            color: t.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== MedleyDetailPage ======================
// Pantalla para VER un medley ya guardado. El medley en sí (nombre + lista
// de títulos) sigue viviendo exactamente igual en el teléfono — nada de
// esta pantalla lo modifica.
//
// Lo nuevo: cada canción del medley puede transponerse SOLO en esta
// sesión de pantalla (para verla/compartirla en otra tonalidad), usando la
// misma lógica correcta de chord_transposer.dart que ya usa
// Vcanciones.dart y song_picker_page.dart — se reemplazó el
// parseLyrics/transposeChord viejo de este archivo, que no transponía
// nada en absoluto. El ajuste vive solo en memoria (_transposiciones) y
// se pierde al salir de la pantalla; el medley guardado no se toca.
class MedleyDetailPage extends StatefulWidget {
  final CategoriaConfig config;
  final Medley medley;
  final List<Song>? canciones;
  const MedleyDetailPage({
    Key? key,
    required this.config,
    required this.medley,
    this.canciones,
  }) : super(key: key);

  @override
  State<MedleyDetailPage> createState() => _MedleyDetailPageState();
}

class _MedleyDetailPageState extends State<MedleyDetailPage> {
  // Semitonos de transposición por título de canción para ESTA pantalla.
  // Arranca con lo que quedó guardado en el medley (elegido al crearlo);
  // cualquier ajuste extra aquí es solo para esta sesión de compartir y
  // NO se vuelve a guardar en el medley.
  late final Map<String, int> _transposiciones;

  @override
  void initState() {
    super.initState();
    _transposiciones = Map<String, int>.from(widget.medley.transposiciones);
  }

  List<Song> _getSongsForMedley() {
    List<Song> medleySongs = [];
    final fuente = widget.canciones ?? widget.config.cancionesCompletas;
    for (var title in widget.medley.canciones) {
      try {
        Song song = fuente.firstWhere(
          (s) => s.title.toUpperCase() == title.toUpperCase(),
        );
        medleySongs.add(song);
      } catch (e) {}
    }
    return medleySongs;
  }

  final Color primaryColor = const Color.fromARGB(255, 0, 0, 0);
  final Color secondaryColor = const Color.fromARGB(255, 161, 119, 69);
  final Color accentColor = const Color.fromARGB(255, 96, 139, 151);

  void _ajustarTransposicion(Song song, int delta) {
    setState(() {
      final actual = _transposiciones[song.title] ?? 0;
      _transposiciones[song.title] = actual + delta;
    });
  }

  void _resetTransposicion(Song song) {
    setState(() {
      _transposiciones.remove(song.title);
    });
  }

  /// Igual que _conTransposicionAplicada() en song_picker_page.dart: copia
  /// la canción con el texto/tonalidad ya transpuestos, sin tocar el
  /// objeto original.
  Song _conTransposicionAplicada(Song song) {
    final semitones = _transposiciones[song.title] ?? 0;
    if (semitones == 0) return song;

    return Song(
      title: song.title,
      text: transposeSongText(song.text, semitones),
      tonalidad: transposeKeyName(song.tonalidad, semitones),
      tiempo: song.tiempo,
      status: song.status,
      instrument: song.instrument,
      multitrackLink: song.multitrackLink,
      youtubeLink: song.youtubeLink,
      guitarLink: song.guitarLink,
      pianoLink: song.pianoLink,
      bassLink: song.bassLink,
      drumsLink: song.drumsLink,
      voicesLinks: song.voicesLinks,
      textPlano: song.textPlano,
      categoria: song.categoria,
    );
  }

  Future<void> _compartirComoPdf() async {
    final songs = _getSongsForMedley().map(_conTransposicionAplicada).toList();
    if (songs.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Todas las canciones del medley van juntas en una sola lista; el
      // generador solo necesita separarlas en adoracion/alabanza para el
      // índice de portada, así que las mandamos todas como "alabanza" si
      // no tienen categoria, o agrupadas por su categoria real si la
      // tienen.
      // songs ya está en el orden del medley (widget.medley.canciones),
      // con la transposición de cada una ya aplicada.
      final bytes = await SongPdfGenerator.generate(
        canciones: songs,
        categoriaDe: (song) => song.categoria,
        tituloRepertorio: widget.medley.name,
      );
      if (!mounted) return;
      Navigator.pop(context);

      final nombreArchivo =
          '${widget.medley.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').replaceAll(' ', '_')}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: nombreArchivo);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo generar el PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Song> medleySongs = _getSongsForMedley();
    final t = AppThemeData.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(widget.medley.name),
        backgroundColor: widget.config.primaryColor,
        foregroundColor: widget.config.foregroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Compartir como PDF',
            onPressed: _compartirComoPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: widget.config.primaryColor.withOpacity(0.08),
            child: Text(
              '🎚 Este medley ya usa las tonalidades que elegiste al crearlo. '
              'Puedes ajustar +/- aquí solo para esta vez; el medley guardado no cambia.',
              style: TextStyle(fontSize: 12, color: t.textSecondary),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: medleySongs.map((song) {
                  final semitones = _transposiciones[song.title] ?? 0;
                  final tonalidadMostrada = semitones == 0
                      ? song.tonalidad
                      : transposeKeyName(song.tonalidad, semitones);
                  final textoTranspuesto = transposeSongText(song.text, semitones);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: t.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        tonalidadMostrada,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: semitones == 0 ? FontWeight.normal : FontWeight.w700,
                                          color: semitones == 0
                                              ? t.textSecondary
                                              : widget.config.primaryColor,
                                        ),
                                      ),
                                      if (semitones != 0) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          '(original ${song.tonalidad})',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: t.textSecondary.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _TransposeMiniButton(
                              icon: Icons.remove,
                              color: widget.config.primaryColor,
                              onTap: () => _ajustarTransposicion(song, -1),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 30),
                              alignment: Alignment.center,
                              child: Text(
                                semitones == 0 ? '±0' : (semitones > 0 ? '+$semitones' : '$semitones'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: semitones == 0 ? t.textSecondary : widget.config.primaryColor,
                                ),
                              ),
                            ),
                            _TransposeMiniButton(
                              icon: Icons.add,
                              color: widget.config.primaryColor,
                              onTap: () => _ajustarTransposicion(song, 1),
                            ),
                            if (semitones != 0)
                              IconButton(
                                icon: const Icon(Icons.replay_rounded, size: 18),
                                tooltip: 'Restablecer tonalidad',
                                onPressed: () => _resetTransposicion(song),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 16, fontFamily: 'RobotoMono', color: t.textPrimary),
                              children: _parseLyrics(textoTranspuesto),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mismo regex de acordes/keywords que Vcanciones.dart — el texto que
  // llega aquí YA viene transpuesto por transposeSongText(), así que este
  // parser solo se encarga de colorear, no de transponer.
  List<TextSpan> _parseLyrics(String text) {
    final String suffix = r'(?:maj7|maj|min|dim7|dim|aug|sus\d*|add\d*|m7|m9|m6|m|[°+])?';
    final String bassPart = r'(?:\/[A-G][#b]?' + suffix + r'\d*)*';
    final String chordUnit = r'[A-G][#b]?' + suffix + r'\d*' + bassPart;

    final chordRegex = RegExp(
      r'(?:(?<=^)|(?<=\s))' + '(?:$chordUnit)' + '(?:-(?:$chordUnit))*' + r'(?:(?=$)|(?=[\s/]))',
    );

    final keywordRegex = RegExp(
      r'\b(?:CANCIÓN|TONALIDAD|TIEMPO|INTRO|VERSO(?: \d+)?|PRE-CORO|CORO 1 Y 2|CORO(?: \d+)?|INSTRUMENTAL|FINAL|ESTROFA|SOLO|PUENTE(?: \d+)?|BAJO|SALIDA(?: \d+)?)\b',
    );

    List<TextSpan> spans = [];

    for (var line in text.split('\n')) {
      final matches = <RegExpMatch>[
        ...keywordRegex.allMatches(line),
        ...chordRegex.allMatches(line),
      ]..sort((a, b) => a.start.compareTo(b.start));

      int currentIndex = 0;
      for (var match in matches) {
        if (match.start > currentIndex) {
          spans.add(TextSpan(text: line.substring(currentIndex, match.start)));
        }
        final token = match.group(0)!;
        final isChord = chordRegex.hasMatch(token);
        spans.add(TextSpan(
          text: token,
          style: TextStyle(
            color: isChord ? secondaryColor : accentColor,
            fontWeight: FontWeight.bold,
          ),
        ));
        currentIndex = match.end;
      }
      if (currentIndex < line.length) {
        spans.add(TextSpan(text: line.substring(currentIndex)));
      }
      spans.add(const TextSpan(text: '\n'));
    }

    return spans;
  }
}

class _TransposeMiniButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TransposeMiniButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}