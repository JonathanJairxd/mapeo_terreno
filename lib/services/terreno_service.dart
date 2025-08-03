import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'dart:math';

class TerrenoService {
  static final supabase = Supabase.instance.client;

  /// Calcula el área aproximada usando la fórmula del zapato (Shoelace)
  static double calcularArea(List<LatLng> puntos) {
    if (puntos.length < 3) return 0;

    double area = 0;
    for (int i = 0; i < puntos.length; i++) {
      int j = (i + 1) % puntos.length;
      area += puntos[i].longitude * puntos[j].latitude;
      area -= puntos[j].longitude * puntos[i].latitude;
    }
    area = area.abs() / 2.0;

    return area * 111000 * 111000; // Convertido a m² (aproximado)
  }

  /// Guarda el terreno en Supabase
  static Future<void> guardarTerreno(List<LatLng> puntos) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || puntos.length < 3) return;

    final area = calcularArea(puntos);

    final puntosJson = puntos
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList();

    await supabase.from('terrenos').insert({
      'user_id': userId,
      'nombre': 'Terreno-${DateTime.now().millisecondsSinceEpoch}',
      'puntos': puntosJson,
      'area': area,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
