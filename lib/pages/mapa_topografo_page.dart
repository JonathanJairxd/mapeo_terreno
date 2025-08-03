import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapaTopografoPage extends StatefulWidget {
  const MapaTopografoPage({super.key});

  @override
  State<MapaTopografoPage> createState() => _MapaTopografoPageState();
}

class _MapaTopografoPageState extends State<MapaTopografoPage> {
  Position? _posicionActual;

  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa del topógrafo")),
      body: _posicionActual == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                    _posicionActual!.latitude, _posicionActual!.longitude),
                initialZoom: 17.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.mapeo_terreno',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_posicionActual!.latitude,
                          _posicionActual!.longitude),
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
    );
  }
}
