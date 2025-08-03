import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

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
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

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

}


