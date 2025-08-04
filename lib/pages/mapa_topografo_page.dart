import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../globals.dart';
import '../services/ubicacion_service.dart';
import 'nuevo_terreno_page.dart';
import 'terrenos_guardados_page.dart';

class MapaTopografoPage extends StatefulWidget {
  const MapaTopografoPage({super.key});

  @override
  State<MapaTopografoPage> createState() => _MapaTopografoPageState();
}

class _MapaTopografoPageState extends State<MapaTopografoPage> {
  final supabase = Supabase.instance.client;
  final mapController = MapController();

  Position? _posicion;
  Timer? _timer;
  bool _enviarUbicacion = false;

  List<Map<String, dynamic>> _topografos = [];

  @override
  void initState() {
    super.initState();
    obtenerUbicacionInicial();
    cargarUbicacionesTopografos();
  }

  Future<void> obtenerUbicacionInicial() async {
    final pos = await UbicacionService.obtenerUbicacionActual();
    setState(() {
      _posicion = pos;
    });
  }

  Future<void> cargarUbicacionesTopografos() async {
    final response = await supabase
        .from('ubicaciones')
        .select('user_id, latitud, longitud, timestamp')
        .order('timestamp', ascending: false);

    final users = await supabase
        .from('usuarios')
        .select('id, nombre')
        .eq('activo', true)
        .eq('rol', 'topografo');

    final topografos = <Map<String, dynamic>>[];

    for (final u in users) {
      final userId = u['id'];
      final nombre = u['nombre'];
      Map<String, dynamic>? ubicacion;
      try {
        ubicacion = response.firstWhere((item) => item['user_id'] == userId);
      } catch (_) {
        ubicacion = null;
      }

      if (ubicacion != null && userId != usuarioIdGlobal) {
        topografos.add({
          'nombre': nombre,
          'lat': ubicacion['latitud'],
          'lng': ubicacion['longitud'],
        });
      }
    }

    setState(() {
      _topografos = topografos;
    });
  }

  void iniciarEnvioUbicacion() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await UbicacionService.obtenerYGuardar();

      // 👇 Esto actualiza tu posición local en el mapa
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _posicion = pos;
      });

      // 👇 Esto centra el mapa
      mapController.move(
        LatLng(pos.latitude, pos.longitude),
        mapController.camera.zoom,
      );

      await cargarUbicacionesTopografos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación enviada a Supabase'),
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  void detenerEnvioUbicacion() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    detenerEnvioUbicacion();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa del Topógrafo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              detenerEnvioUbicacion();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _posicion == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SwitchListTile(
                  title: const Text("Enviar ubicación cada 10 segundos"),
                  value: _enviarUbicacion,
                  onChanged: (value) {
                    setState(() {
                      _enviarUbicacion = value;
                      if (value) {
                        iniciarEnvioUbicacion();
                      } else {
                        detenerEnvioUbicacion();
                      }
                    });
                  },
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        _posicion!.latitude,
                        _posicion!.longitude,
                      ),
                      initialZoom: 17,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.topografoapp',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              _posicion!.latitude,
                              _posicion!.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 35,
                            ),
                          ),
                          for (final t in _topografos)
                            Marker(
                              point: LatLng(t['lat'], t['lng']),
                              width: 30,
                              height: 30,
                              child: Tooltip(
                                message: t['nombre'],
                                child: const Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.orange,
                                  size: 30,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NuevoTerrenoPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_location_alt),
                      label: const Text("Nuevo terreno"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TerrenosGuardadosPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map),
                      label: const Text("Ver terrenos"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }
}
