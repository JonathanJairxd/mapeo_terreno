import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/gestion_usuarios_page.dart';
import '../pages/admin_terrenos_page.dart';
import 'dart:async';


class MapaAdminPage extends StatefulWidget {
  const MapaAdminPage({super.key});

  @override
  State<MapaAdminPage> createState() => _MapaAdminPageState();
}

class _MapaAdminPageState extends State<MapaAdminPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _topografos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUbicaciones();

    // Auto-actualiza cada 10 segundos
    Timer.periodic(Duration(seconds: 10), (_) {
      if (mounted) cargarUbicaciones();
    });
  }

  Future<void> cargarUbicaciones() async {
    final ubicaciones = await supabase
        .from('ubicaciones')
        .select('user_id, latitud, longitud, timestamp')
        .order('timestamp', ascending: false);

    final usuarios = await supabase
        .from('usuarios')
        .select('id, nombre')
        .eq('rol', 'topografo')
        .eq('activo', true);

    final lista = <Map<String, dynamic>>[];

    for (final user in usuarios) {
      final userId = user['id'];
      final nombre = user['nombre'];

      Map<String, dynamic>? ultima;
      try {
        ultima = ubicaciones.firstWhere((u) => u['user_id'] == userId);
      } catch (_) {
        ultima = null;
      }

      if (ultima != null) {
        lista.add({
          'nombre': nombre,
          'lat': ultima['latitud'],
          'lng': ultima['longitud'],
        });
      }
    }

    setState(() {
      _topografos = lista;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.supervised_user_circle),
            tooltip: 'Gestionar usuarios',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GestionUsuariosPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Ver terrenos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminTerrenosPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/',
              ); // o usa LoginPage si no usas rutas
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _topografos.isNotEmpty
                    ? LatLng(_topografos[0]['lat'], _topografos[0]['lng'])
                    : LatLng(0, 0),
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.topografoapp',
                ),
                MarkerLayer(
                  markers: _topografos
                      .map(
                        (t) => Marker(
                          point: LatLng(t['lat'], t['lng']),
                          width: 35,
                          height: 35,
                          child: Tooltip(
                            message: t['nombre'],
                            child: const Icon(
                              Icons.person_pin,
                              color: Colors.redAccent,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
