import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/ubicacion_service.dart';

class MapaTopografoPage extends StatefulWidget {
  const MapaTopografoPage({super.key});

  @override
  State<MapaTopografoPage> createState() => _MapaTopografoPageState();
}

class _MapaTopografoPageState extends State<MapaTopografoPage> {
  Position? _posicionActual;
  Timer? _timerUbicacion;
  bool _enviarUbicacion = false; // Estado del switch

  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

  /// Pide permisos y obtiene la posición actual
  Future<void> obtenerUbicacion() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }

    final posicion = await Geolocator.getCurrentPosition();
    setState(() {
      _posicionActual = posicion;
    });
  }

  /// Inicia el timer de envío
  void iniciarEnvioUbicacion() {
    _timerUbicacion = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await UbicacionService.obtenerYGuardar();

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

  /// Detiene el timer
  void detenerEnvioUbicacion() {
    _timerUbicacion?.cancel();
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
        title: const Text("Mapa del topógrafo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              detenerEnvioUbicacion();
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: _posicionActual == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SwitchListTile(
                  title: const Text("Enviar ubicación cada 10 segundos"),
                  value: _enviarUbicacion,
                  onChanged: (bool value) {
                    setState(() {
                      _enviarUbicacion = value;
                      if (_enviarUbicacion) {
                        iniciarEnvioUbicacion();
                      } else {
                        detenerEnvioUbicacion();
                      }
                    });
                  },
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        _posicionActual!.latitude,
                        _posicionActual!.longitude,
                      ),
                      initialZoom: 17.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.mapeo_terreno',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              _posicionActual!.latitude,
                              _posicionActual!.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
