import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
