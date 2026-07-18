// lib/pages/song_picker_page.dart
//
// Permite elegir una o varias canciones (mezclando Adoración y Alabanza)
// para armar un "medley/repertorio compartido": un PDF con portada +
// todas las canciones separadas por categoría y ordenadas alfabéticamente,
// o el texto plano equivalente vía share_plus.

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/Mcanciones.dart';
import '../models/song_repository.dart';
import '../utils/app_theme.dart';
import '../utils/song_pdf_generator.dart';

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
      } else {
        _seleccionadas[song.title] = song;
      }
    });
  }

  /// Divide las canciones seleccionadas en dos listas ya ordenadas
  /// (siguiendo el orden alfabético de _adoracion/_alabanza), para pasarlas
  /// directo al generador de PDF/texto agrupadas por categoría.
  List<Song> _seleccionadasDe(List<Song> categoria) {
    final titulos = _seleccionadas.keys.toSet();
    return categoria.where((s) => titulos.contains(s.title)).toList();
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
      final bytes = await SongPdfGenerator.generate(
        adoracion: adoracionSel,
        alabanza: alabanzaSel,
        tituloRepertorio: titulo.isNotEmpty ? titulo : null,
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
        title: Text(esUnaSola ? 'Título del PDF (opcional)' : 'Nombre del repertorio'),
        content: TextField(
          controller: _tituloController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ej: Servicio Domingo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _tituloController.text.trim()),
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

  Widget _buildLista(List<Song> canciones) {
    if (canciones.isEmpty) {
      return const Center(child: Text('No hay canciones disponibles.'));
    }
    return ListView.builder(
      itemCount: canciones.length,
      itemBuilder: (context, index) {
        final song = canciones[index];
        final seleccionada = _seleccionadas.containsKey(song.title);
        return CheckboxListTile(
          value: seleccionada,
          onChanged: (_) => _toggleSeleccion(song),
          title: Text(song.title),
          subtitle: Text(song.tonalidad),
          activeColor: AppColors.gold,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartir canciones'),
        backgroundColor: AppColors.charcoal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Adoración'),
            Tab(text: 'Alabanza'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLista(_adoracion),
                _buildLista(_alabanza),
              ],
            ),
      bottomNavigationBar: _seleccionadas.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_seleccionadas.length} seleccionada${_seleccionadas.length == 1 ? '' : 's'}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _compartirComoTexto,
                      icon: const Icon(Icons.text_snippet_outlined),
                      label: const Text('Texto'),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: _compartirComoPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}