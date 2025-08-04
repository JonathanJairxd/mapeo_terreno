import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ver_terreno_page.dart';

class AdminTerrenosPage extends StatefulWidget {
  const AdminTerrenosPage({super.key});

  @override
  State<AdminTerrenosPage> createState() => _AdminTerrenosPageState();
}

class _AdminTerrenosPageState extends State<AdminTerrenosPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _terrenos = [];

  @override
  void initState() {
    super.initState();
    cargarTerrenos();
  }

  Future<void> cargarTerrenos() async {
    final terrenos = await supabase
        .from('terrenos')
        .select('id, nombre, area, timestamp, user_id, puntos, descripcion');

    final usuarios = await supabase
        .from('usuarios')
        .select('id, nombre');

    final lista = terrenos.map<Map<String, dynamic>>((t) {
      final user = usuarios.firstWhere(
        (u) => u['id'] == t['user_id'],
        orElse: () => {'nombre': 'Desconocido'},
      );

      return {
        'nombre': t['nombre'],
        'area': t['area'],
        'fecha': t['timestamp'],
        'usuario': user['nombre'],
        'puntos': t['puntos'],
        'descripcion': t['descripcion'],
      };
    }).toList();

    setState(() {
      _terrenos = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terrenos Registrados')),
      body: _terrenos.isEmpty
          ? const Center(child: Text('No hay terrenos guardados'))
          : ListView.builder(
              itemCount: _terrenos.length,
              itemBuilder: (context, index) {
                final t = _terrenos[index];
                return ListTile(
                  leading: const Icon(Icons.landscape),
                  title: Text(t['nombre']),
                  subtitle: Text(
                    'Área: ${t['area'].toStringAsFixed(2)} m²\n'
                    'Por: ${t['usuario']}\n'
                    'Fecha: ${DateTime.parse(t['fecha']).toLocal()}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VerTerrenoPage(
                          terreno: {
                            'nombre': t['nombre'],
                            'puntos': t['puntos'],
                            'descripcion': t['descripcion'],
                            'area': t['area'],
                            'timestamp': t['fecha'],
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
