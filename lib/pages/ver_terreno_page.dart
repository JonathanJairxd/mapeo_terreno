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
      appBar: AppBar(title: Text(terreno['nombre'] ?? 'Terreno')),
      body: puntos.isEmpty
          ? const Center(child: Text('Terreno sin puntos'))
          : FlutterMap(
              options: MapOptions(
                initialCenter: puntos.first,
                initialZoom: 17,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.topografoapp',
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
                MarkerLayer(
                  markers: puntos
                      .map((p) => Marker(
                            point: p,
                            width: 25,
                            height: 25,
                            child: const Icon(Icons.circle,
                                size: 10, color: Colors.red),
                          ))
                      .toList(),
                ),
              ],
            ),
    );
  }
}
