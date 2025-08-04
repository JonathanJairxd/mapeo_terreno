import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../globals.dart';

class NuevoTerrenoPage extends StatefulWidget {
  const NuevoTerrenoPage({super.key});

  @override
  State<NuevoTerrenoPage> createState() => _NuevoTerrenoPageState();
}

class _NuevoTerrenoPageState extends State<NuevoTerrenoPage> {
  final supabase = Supabase.instance.client;

  List<LatLng> puntos = [];
  String nombre = '';
  String descripcion = '';
  double area = 0.0;

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();

  LatLng? posicionInicial;

  @override
  void initState() {
    super.initState();
    obtenerUbicacionInicial();
  }

  Future<void> obtenerUbicacionInicial() async {
    final posicion = await Geolocator.getCurrentPosition();
    setState(() {
      posicionInicial = LatLng(posicion.latitude, posicion.longitude);
    });
  }

  void agregarPuntoGPS() async {
    final posicion = await Geolocator.getCurrentPosition();
    final nuevoPunto = LatLng(posicion.latitude, posicion.longitude);
    setState(() {
      puntos.add(nuevoPunto);
      calcularArea();
    });
  }

  void agregarPuntoManual(LatLng punto) {
    setState(() {
      puntos.add(punto);
      calcularArea();
    });
  }

  void calcularArea() {
    if (puntos.length < 3) {
      area = 0.0;
      return;
    }

    double result = 0.0;
    for (int i = 0; i < puntos.length; i++) {
      final p1 = puntos[i];
      final p2 = puntos[(i + 1) % puntos.length];
      result += (p1.longitude * p2.latitude) - (p2.longitude * p1.latitude);
    }

    result = (result.abs() / 2.0) * 111000 * 111000; // m² aprox
    area = result;
  }

  Future<void> guardarTerreno() async {
    if (puntos.length < 3 || nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mínimo 3 puntos y nombre obligatorio')),
      );
      return;
    }

    final puntosJson = puntos
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList();

    await supabase.from('terrenos').insert({
      'user_id': usuarioIdGlobal,
      'nombre': nombreController.text.trim(),
      'descripcion': descripcionController.text.trim(),
      'puntos': puntosJson,
      'area': area,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terreno guardado correctamente')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Terreno")),
      body: posicionInicial == null
    ? const Center(child: CircularProgressIndicator())
    : Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: posicionInicial!,
                initialZoom: 17,
                onTap: (_, latlng) {
                  agregarPuntoManual(latlng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.topografoapp',
                ),
                if (puntos.isNotEmpty)
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
                      .map(
                        (p) => Marker(
                          point: p,
                          width: 20,
                          height: 20,
                          child: const Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.red,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: agregarPuntoGPS,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Punto GPS"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          puntos.clear();
                          area = 0.0;
                        });
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Borrar puntos"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del terreno',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  "Área: ${area.toStringAsFixed(2)} m²",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  onPressed: guardarTerreno,
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar terreno"),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
