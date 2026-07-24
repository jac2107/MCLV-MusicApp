// lib/pages/song_picker_page.dart
//
// Permite elegir una o varias canciones (mezclando Adoración y Alabanza)
// para armar un "medley/repertorio compartido": un PDF con portada +
// todas las canciones separadas por categoría y ordenadas alfabéticamente,
// o el texto plano equivalente vía share_plus.
//
// Cada canción seleccionada puede transponerse individualmente SOLO para
// esta exportación (PDF/texto) — el ajuste vive únicamente en esta
// pantalla (_transposiciones) y nunca toca el Song original en caché ni en
// Firestore. Al salir de esta pantalla, el ajuste se pierde, que es la
// intención: es una transposición "de una sola vez" para compartir.

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/Mcanciones.dart';
import '../models/song_repository.dart';
import '../utils/app_theme.dart';
import '../utils/song_pdf_generator.dart';
import '../utils/chord_transposer.dart';

class SongPickerPage extends StatefulWidget {
  /// Canciones que llegan ya marcadas al abrir la pantalla (ej. cuando el
  /// usuario venía de "Elegir varias" desde una canción individual).
  final List<Song> preseleccionadas;

  const SongPickerPage({super.key, this.preseleccionadas = const []});

  @override
  State<SongPickerPage> createState() => _SongPickerPageState();
}

class _SongPickerPageState extends State<SongPickerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Song> _adoracion = [];
  List<Song> _alabanza = [];
  bool _cargando = true;

  // Selección por título (para no perderla al cambiar de pestaña)
  final Map<String, Song> _seleccionadas = {};

  // Semitonos de transposición SOLO para esta exportación, por título de
  // canción. 0 = tonalidad original (comportamiento de siempre).
  final Map<String, int> _transposiciones = {};

  final TextEditingController _tituloController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    for (final s in widget.preseleccionadas) {
      _seleccionadas[s.title] = s;
    }
    _cargarCanciones();
  }

  /// Ordena alfabéticamente por título (ignorando acentos/mayúsculas).
  List<Song> _ordenar(List<Song> lista) {
    final copia = List<Song>.from(lista);
    copia.sort((a, b) => a.title.toUpperCase().compareTo(b.title.toUpperCase()));
    return copia;
  }

  Future<void> _cargarCanciones() async {
    final adoracion = await SongRepository.instance.loadFromCache('adoracion');
    final alabanza = await SongRepository.instance.loadFromCache('alabanza');
    if (!mounted) return;
    setState(() {
      _adoracion = _ordenar(adoracion.isNotEmpty ? adoracion : cancionesCompletas);
      _alabanza = _ordenar(alabanza.isNotEmpty ? alabanza : cancionesCompletas1);
      _cargando = false;
    });
  }

  void _toggleSeleccion(Song song) {
    setState(() {
      if (_seleccionadas.containsKey(song.title)) {
        _seleccionadas.remove(song.title);
        _transposiciones.remove(song.title);
      } else {
        _seleccionadas[song.title] = song;
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

  /// Aplica la transposición elegida (si hay) a una canción, devolviendo
  /// una copia nueva con el texto/tonalidad ya ajustados. La canción
  /// original en _adoracion/_alabanza/caché nunca se modifica.
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

  /// Divide las canciones seleccionadas en dos listas ya ordenadas
  /// (siguiendo el orden alfabético de _adoracion/_alabanza), con la
  /// transposición de cada una ya aplicada, listas para el PDF/texto.
  List<Song> _seleccionadasDe(List<Song> categoria) {
    final titulos = _seleccionadas.keys.toSet();
    return categoria
        .where((s) => titulos.contains(s.title))
        .map(_conTransposicionAplicada)
        .toList();
  }

  Future<void> _compartirComoPdf() async {
    if (_seleccionadas.isEmpty) return;
    final adoracionSel = _seleccionadasDe(_adoracion);
    final alabanzaSel = _seleccionadasDe(_alabanza);
    final total = adoracionSel.length + alabanzaSel.length;

    // Siempre preguntamos el título (aunque sea una sola canción), porque
    // el caso de uso típico es "arma el repertorio para tal evento".
    final titulo = await _pedirTitulo(esUnaSola: total == 1);
    if (titulo == null || !mounted) return; // canceló el diálogo

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final todasSeleccionadas = [...adoracionSel, ...alabanzaSel];
      final bytes = await SongPdfGenerator.generate(
        canciones: todasSeleccionadas,
        categoriaDe: (song) => song.categoria,
        tituloRepertorio: titulo,
      );
      if (!mounted) return;
      Navigator.pop(context); // cierra el loading

      final primeraCancion = adoracionSel.isNotEmpty ? adoracionSel.first : alabanzaSel.first;
      final nombreArchivo = titulo.isNotEmpty
          ? '${_slug(titulo)}.pdf'
          : total == 1
              ? '${_slug(primeraCancion.title)}.pdf'
              : '${_slug('repertorio')}.pdf';

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

  Future<void> _compartirComoTexto() async {
    if (_seleccionadas.isEmpty) return;
    final canciones = [..._seleccionadasDe(_adoracion), ..._seleccionadasDe(_alabanza)];

    final buffer = StringBuffer();
    for (final s in canciones) {
      buffer.writeln(s.title);
      buffer.writeln('Tonalidad: ${s.tonalidad}');
      if (s.tiempo > 0) buffer.writeln('Tiempo: ${s.tiempo} bpm');
      buffer.writeln();
      buffer.writeln(s.text.trim());
      buffer.writeln('\n${'—' * 20}\n');
    }

    await Share.share(buffer.toString());
  }

  Future<String?> _pedirTitulo({required bool esUnaSola}) async {
    _tituloController.clear();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusMd)),
        title: Text(esUnaSola ? 'Título del PDF (opcional)' : 'Nombre del repertorio'),
        content: TextField(
          controller: _tituloController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ej: Servicio Domingo',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppShapes.radiusSm)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _tituloController.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  String _slug(String s) {
    return s
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9áéíóúñ ]', caseSensitive: false), '')
        .replaceAll(' ', '_');
  }

  Widget _buildLista(List<Song> canciones, AppThemeData t) {
    if (canciones.isEmpty) {
      return Center(
        child: Text(
          'No hay canciones disponibles.',
          style: TextStyle(color: t.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: canciones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final song = canciones[index];
        final seleccionada = _seleccionadas.containsKey(song.title);
        final semitones = _transposiciones[song.title] ?? 0;
        return _SongPickTile(
          song: song,
          selected: seleccionada,
          semitones: semitones,
          themeData: t,
          onTap: () => _toggleSeleccion(song),
          onTransposeUp: () => _ajustarTransposicion(song, 1),
          onTransposeDown: () => _ajustarTransposicion(song, -1),
          onTransposeReset: () => _resetTransposicion(song),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppThemeData.of(context);
    final int count = _seleccionadas.length;

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: const Text('Compartir canciones'),
        backgroundColor: t.appBarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Adoración'),
            Tab(text: 'Alabanza'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (count > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.gold.withOpacity(0.08),
                    child: Text(
                      '🎚 Toca +/- junto a una canción para transponerla SOLO en este PDF/texto. '
                      'No afecta la canción en la app.',
                      style: TextStyle(fontSize: 12, color: t.textSecondary),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLista(_adoracion, t),
                      _buildLista(_alabanza, t),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: count == 0
          ? null
          : SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: AppShapes.softCard(
                  color: t.cardColor,
                  radius: AppShapes.radiusMd,
                  dark: t.isDark,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppShapes.radiusSm),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        count == 1 ? 'canción seleccionada' : 'canciones seleccionadas',
                        style: TextStyle(fontWeight: FontWeight.w500, color: t.textPrimary),
                      ),
                    ),
                    IconButton(
                      onPressed: _compartirComoTexto,
                      icon: Icon(Icons.text_snippet_outlined, color: t.textSecondary),
                      tooltip: 'Compartir como texto',
                    ),
                    FilledButton.icon(
                      onPressed: _compartirComoPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('PDF'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.radiusSm)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Tarjeta de canción seleccionable: reemplaza al CheckboxListTile genérico
/// por algo con el mismo lenguaje visual que el resto de la app (softCard +
/// borde dorado cuando está seleccionada), simple y sin adornos de más.
///
/// Cuando está seleccionada, muestra además un control +/- para transponer
/// SOLO en esta exportación, con la tonalidad resultante como referencia.
class _SongPickTile extends StatelessWidget {
  final Song song;
  final bool selected;
  final int semitones;
  final AppThemeData themeData;
  final VoidCallback onTap;
  final VoidCallback onTransposeUp;
  final VoidCallback onTransposeDown;
  final VoidCallback onTransposeReset;

  const _SongPickTile({
    required this.song,
    required this.selected,
    required this.semitones,
    required this.themeData,
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
              color: selected ? AppColors.gold : Colors.transparent,
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
                      color: selected ? AppColors.gold : Colors.transparent,
                      border: Border.all(
                        color: selected ? AppColors.gold : t.textSecondary.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
                                color: semitones == 0 ? t.textSecondary : AppColors.gold,
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
              if (selected) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _TransposeMiniButton(icon: Icons.remove, onTap: onTransposeDown),
                    Container(
                      constraints: const BoxConstraints(minWidth: 34),
                      alignment: Alignment.center,
                      child: Text(
                        semitones == 0 ? '±0' : (semitones > 0 ? '+$semitones' : '$semitones'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: semitones == 0 ? t.textSecondary : AppColors.gold,
                        ),
                      ),
                    ),
                    _TransposeMiniButton(icon: Icons.add, onTap: onTransposeUp),
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

class _TransposeMiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TransposeMiniButton({required this.icon, required this.onTap});

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
          color: AppColors.gold.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppColors.gold),
      ),
    );
  }
}