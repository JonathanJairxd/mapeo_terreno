import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../globals.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class UbicacionService {
  static final supabase = Supabase.instance.client;

  /// Obtiene ubicación actual del dispositivo
  static Future<Position> obtenerUbicacionActual() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Envía ubicación al backend (tabla `ubicaciones`)
  static Future<void> guardarUbicacion(Position posicion) async {
    if (usuarioIdGlobal == null) return;
    final userId = usuarioIdGlobal!;

    await supabase.from('ubicaciones').insert({
      'user_id': userId,
      'latitud': posicion.latitude,
      'longitud': posicion.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Método que combina obtener y guardar
  static Future<void> obtenerYGuardar() async {
    try {
      final posicion = await obtenerUbicacionActual();
      await guardarUbicacion(posicion);
    } catch (e) {
      print('Error al obtener o guardar ubicación: $e');
    }
  }

  /// Consulta todos los puntos del usuario actual
  static Future<List<LatLng>> obtenerPuntosUsuario() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('ubicaciones')
        .select('latitud, longitud')
        .eq('user_id', userId)
        .order('timestamp');

    final datos = response as List;
    return datos
        .map((p) => LatLng(p['latitud'] as double, p['longitud'] as double))
        .toList();
  }

  /// Consulta ubicaciones recientes de otros topógrafos
  static Future<List<Marker>> obtenerUbicacionesDeOtros() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('ubicaciones')
        .select('user_id, latitud, longitud, timestamp, usuarios(nombre)')
        .order('timestamp', ascending: false)
        .limit(100);

    final List datos = response;

    final Set<String> idsVistos = {};
    final List<Marker> markers = [];

    for (var item in datos) {
      final id = item['user_id'];
      if (id == userId || idsVistos.contains(id)) continue;

      idsVistos.add(id);
      final nombre = item['usuarios']['nombre'] ?? 'Topógrafo';

      markers.add(
        Marker(
          point: LatLng(item['latitud'], item['longitud']),
          width: 40,
          height: 40,
          child: Tooltip(
            message: nombre,
            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.orange,
              size: 36,
            ),
          ),
        ),
      );
    }

    return markers;
  }
}
