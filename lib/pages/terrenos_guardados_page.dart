import 'package:flutter/material.dart';
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
    if (usuarioIdGlobal == null) {
      // Puedes manejar esto como prefieras: mostrar mensaje, log, etc.
      print('usuarioIdGlobal es null, no se puede cargar terrenos');
      return;
    }

    final response = await supabase
        .from('terrenos')
        .select()
        .eq(
          'user_id',
          usuarioIdGlobal!,
        ) // el ! es seguro aquí porque lo validamos antes
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
          ? const Center(child: Text("No tienes terrenos registrados"))
          : ListView.builder(
              itemCount: terrenos.length,
              itemBuilder: (context, index) {
                final terreno = terrenos[index];
                final nombre = terreno['nombre'] ?? 'Sin nombre';
                final area = terreno['area']?.toStringAsFixed(2) ?? '0.0';
                final fecha = DateTime.parse(terreno['timestamp']).toLocal();
                final descripcion = terreno['descripcion']?.toString().trim();
                final tieneDescripcion =
                    descripcion != null && descripcion.isNotEmpty;

                return ListTile(
                  leading: const Icon(Icons.landscape),
                  title: Text(nombre),
                  subtitle: Text(
                    'Área: $area m²\nFecha: $fecha${tieneDescripcion ? '\nDescripción: $descripcion' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VerTerrenoPage(terreno: terreno),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
