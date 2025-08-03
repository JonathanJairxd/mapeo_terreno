import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:latlong2/latlong.dart';
import 'ver_terreno_page.dart';

class TerrenoDetallePage extends StatefulWidget {
  const TerrenoDetallePage({super.key});

  @override
  State<TerrenoDetallePage> createState() => _TerrenoDetallePageState();
}

class _TerrenoDetallePageState extends State<TerrenoDetallePage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _terrenos = [];

  @override
  void initState() {
    super.initState();
    cargarTerrenos();
  }

  Future<void> cargarTerrenos() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('terrenos')
        .select('id, nombre, area, timestamp, puntos')
        .eq('user_id', userId)
        .order('timestamp', ascending: false);

    setState(() {
      _terrenos = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis terrenos')),
      body: _terrenos.isEmpty
          ? const Center(child: Text("No tienes terrenos guardados"))
          : ListView.builder(
              itemCount: _terrenos.length,
              itemBuilder: (context, index) {
                final terreno = _terrenos[index];
                return ListTile(
                  title: Text(terreno['nombre']),
                  subtitle: Text(
                      'Área: ${terreno['area'].toStringAsFixed(2)} m²\nFecha: ${DateTime.parse(terreno['timestamp']).toLocal()}'),
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
