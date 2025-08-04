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

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    cargarUbicaciones();

    // Auto-actualiza cada 10 segundos
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) cargarUbicaciones();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> cargarUbicaciones() async {
    try {
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

      if (mounted) {
        setState(() {
          _topografos = lista;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ubicaciones: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Administrador'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.supervised_user_circle),
              tooltip: 'Gestionar usuarios',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GestionUsuariosPage()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Ver terrenos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminTerrenosPage()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
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
