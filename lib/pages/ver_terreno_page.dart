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
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
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
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      if (terreno['descripcion'] != null &&
                          terreno['descripcion'].toString().trim().isNotEmpty)
                        Text(
                          terreno['descripcion'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        "Área: ${terreno['area']?.toStringAsFixed(2) ?? '0.0'} m²",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
