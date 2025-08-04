import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

import 'gestion_usuarios_page.dart';


class MapaAdminPage extends StatefulWidget {
  const MapaAdminPage({super.key});

  @override
  State<MapaAdminPage> createState() => _MapaAdminPageState();
}

class _MapaAdminPageState extends State<MapaAdminPage> {
  final supabase = Supabase.instance.client;
  Map<String, List<LatLng>> _rutasPorUsuario = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUbicaciones();
  }

  Future<void> cargarUbicaciones() async {
    final response = await supabase
        .from('ubicaciones')
        .select('user_id, latitud, longitud')
        .order('timestamp');

    final datos = response as List;
    final rutas = <String, List<LatLng>>{};

    for (final fila in datos) {
      final id = fila['user_id'] as String;
      final lat = fila['latitud'] as double;
      final lng = fila['longitud'] as double;

      rutas.putIfAbsent(id, () => []).add(LatLng(lat, lng));
    }

    setState(() {
      _rutasPorUsuario = rutas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa del administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.supervised_user_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GestionUsuariosPage()),
              );
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _rutasPorUsuario.values.isNotEmpty
                    ? _rutasPorUsuario.values.first.first
                    : LatLng(0, 0),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.mapeo_terreno',
                ),
                for (final ruta in _rutasPorUsuario.entries)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: ruta.value,
                        strokeWidth: 4,
                        color:
                            Colors.primaries[ruta.key.hashCode %
                                Colors.primaries.length],
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
