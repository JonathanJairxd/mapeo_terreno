import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VerTerrenoPage extends StatelessWidget {
  final Map<String, dynamic> terreno;

  const VerTerrenoPage({super.key, required this.terreno});

  @override
  Widget build(BuildContext context) {
    final puntos = (terreno['puntos'] as List)
        .map((p) => LatLng(p['lat'], p['lng']))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(terreno['nombre']),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: puntos.isNotEmpty ? puntos[0] : LatLng(0, 0),
          initialZoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.mapeo_terreno',
          ),
          PolygonLayer(
            polygons: [
              Polygon(
                points: puntos,
                borderColor: Colors.green,
                borderStrokeWidth: 3,
                color: Colors.green.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
