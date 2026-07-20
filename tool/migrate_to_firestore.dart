// tool/migrate_to_firestore.dart
//
// Script de USO ÚNICO. Sube las 96 canciones (Adoración + Alabanza) a
// Firestore, fusionando cada par completa+simplificada en un solo
// documento. NO se empaqueta en el APK final — solo se corre una vez
// desde tu máquina y luego puedes borrar este archivo o dejarlo en tool/.
//
// CÓMO CORRERLO (este es un proyecto Flutter, no Dart puro, así que
// `dart run` NO alcanza para inicializar firebase_core/cloud_firestore):
//
//   flutter run -d windows -t tool/migrate_to_firestore.dart
//
// (usa -d windows, -d macos, -d linux, o -d chrome según tu SO —
// cualquier target de escritorio/web sirve, no hace falta celular
// ni emulador). Verás la pantalla con el progreso y el reporte final
// se imprime también en la consola/terminal.
//
// Cuando termine, revisa el reporte. Si algo falta, corrígelo en
// Mcanciones.dart y vuelve a correr el script — es seguro repetirlo:
// usa el título como ID de documento, así que sobreescribe en vez
// de duplicar.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musicapp/firebase_options.dart';
import 'package:musicapp/models/Mcanciones.dart';
import 'package:musicapp/utils/song_id.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MigrationApp());
}

class MigrationApp extends StatelessWidget {
  const MigrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MigrationScreen(),
    );
  }
}

/// Convierte el título en un ID de documento válido y estable.
/// Firestore no permite '/' en el ID; normalizamos a mayúsculas + trim
/// para evitar duplicados por diferencias de espacios.
String slugifySongTitle(String title) {
  return title.trim().toUpperCase().replaceAll('/', '-');
}

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  final List<String> _log = [];
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _runMigration();
  }

  void _addLog(String line) {
    // ignore: avoid_print
    print(line);
    setState(() => _log.add(line));
  }

  Future<void> _runMigration() async {
    final db = FirebaseFirestore.instance;
    final coleccion = db.collection('canciones');

    int subidas = 0;
    final List<String> sinParSimplificada = [];
    final List<String> sinParCompleta = [];

    Future<void> migrarCategoria({
      required String categoria,
      required List<Song> completas,
      required List<Song> simplificadas,
    }) async {
      final Map<String, Song> simplificadasPorTitulo = {
        for (final s in simplificadas) slugifySongTitle(s.title): s,
      };
      final Map<String, Song> completasPorTitulo = {
        for (final c in completas) slugifySongTitle(c.title): c,
      };

      for (final completa in completas) {
        final key = slugifySongTitle(completa.title);
        final simple = simplificadasPorTitulo[key];
        if (simple == null) {
          sinParSimplificada.add('${completa.title} (categoria: $categoria)');
        }

        final data = <String, dynamic>{
          'title': completa.title,
          'text': completa.text,
          'textPlano': simple?.text,
          'tonalidad': completa.tonalidad,
          'tiempo': completa.tiempo,
          'status': simple?.status ?? completa.status,
          'instrument': completa.instrument,
          'categoria': categoria,
          'youtubeLink': completa.youtubeLink,
          'multitrackLink': completa.multitrackLink,
          'guitarLink': completa.guitarLink,
          'pianoLink': completa.pianoLink,
          'bassLink': completa.bassLink,
          'drumsLink': completa.drumsLink,
          'voicesLinks': completa.voicesLinks,
        };
        data.removeWhere((key, value) => value == null);

        await coleccion.doc(key).set(data);
        subidas++;
        _addLog('OK  [$categoria] ${completa.title}');
      }

      for (final simple in simplificadas) {
        final key = slugifySongTitle(simple.title);
        if (!completasPorTitulo.containsKey(key)) {
          sinParCompleta.add('${simple.title} (categoria: $categoria)');
        }
      }
    }

    await migrarCategoria(
      categoria: 'adoracion',
      completas: cancionesCompletas,
      simplificadas: cancionesSimplificadas,
    );

    await migrarCategoria(
      categoria: 'alabanza',
      completas: cancionesCompletas1,
      simplificadas: cancionesSimplificadas1,
    );

    _addLog('');
    _addLog('========== REPORTE FINAL ==========');
    _addLog('Documentos subidos: $subidas');
    _addLog('Completas SIN par simplificada: ${sinParSimplificada.length}');
    for (final t in sinParSimplificada) {
      _addLog('  - $t');
    }
    _addLog('Simplificadas SIN par completa (no se subieron): ${sinParCompleta.length}');
    for (final t in sinParCompleta) {
      _addLog('  - $t');
    }
    _addLog('====================================');

    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_done ? 'Migración completa' : 'Migrando...'),
        backgroundColor: _done ? Colors.green : Colors.orange,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _log.length,
        itemBuilder: (context, i) => Text(
          _log[i],
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}