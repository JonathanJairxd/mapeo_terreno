import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    final usuarios = await supabase.from('usuarios').select('id, nombre');

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
          ? const Center(
              child: Text(
                'No hay terrenos guardados',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _terrenos.length,
              itemBuilder: (context, index) {
                final t = _terrenos[index];
                final fecha = DateTime.parse(t['fecha']).toLocal();
                final fechaFormateada =
                    DateFormat('dd/MM/yyyy – hh:mm a').format(fecha);
                final descripcion = t['descripcion']?.toString().trim();
                final tieneDescripcion =
                    descripcion != null && descripcion.isNotEmpty;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: const Icon(Icons.map, color: Colors.teal),
                    title: Text(
                      t['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Área: ${t['area'].toStringAsFixed(2)} m²"),
                        Text("Usuario: ${t['usuario']}"),
                        Text("Fecha: $fechaFormateada"),
                        if (tieneDescripcion)
                          Text("Descripción: $descripcion"),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
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
                  ),
                );
              },
            ),
    );
  }
}
