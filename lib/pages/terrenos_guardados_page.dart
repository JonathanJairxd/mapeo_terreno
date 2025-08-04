import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../globals.dart';
import 'ver_terreno_page.dart';

class TerrenosGuardadosPage extends StatefulWidget {
  const TerrenosGuardadosPage({super.key});

  @override
  State<TerrenosGuardadosPage> createState() => _TerrenosGuardadosPageState();
}

class _TerrenosGuardadosPageState extends State<TerrenosGuardadosPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> terrenos = [];

  @override
  void initState() {
    super.initState();
    cargarTerrenos();
  }

  Future<void> cargarTerrenos() async {
    if (usuarioIdGlobal == null) return;

    final response = await supabase
        .from('terrenos')
        .select()
        .eq('user_id', usuarioIdGlobal!)
        .order('timestamp', ascending: false);

    setState(() {
      terrenos = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terrenos Guardados')),
      body: terrenos.isEmpty
          ? const Center(
              child: Text(
                "No tienes terrenos registrados",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: terrenos.length,
              itemBuilder: (context, index) {
                final terreno = terrenos[index];
                final nombre = terreno['nombre'] ?? 'Sin nombre';
                final area = terreno['area']?.toStringAsFixed(2) ?? '0.0';
                final descripcion = terreno['descripcion']?.toString().trim();
                final tieneDescripcion =
                    descripcion != null && descripcion.isNotEmpty;

                final fecha = DateTime.parse(terreno['timestamp']).toLocal();
                final formatoFecha = DateFormat('dd/MM/yyyy – hh:mm a').format(fecha);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: const Icon(Icons.landscape, color: Colors.green),
                    title: Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Área: $area m²"),
                        Text("Fecha: $formatoFecha"),
                        if (tieneDescripcion)
                          Text("Descripción: $descripcion"),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VerTerrenoPage(terreno: terreno),
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
