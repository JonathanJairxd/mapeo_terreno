import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // <- para kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';

import 'dart:async';
import 'package:flutter_background/flutter_background.dart';
import 'package:geolocator/geolocator.dart';
import './services/ubicacion_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pibmeiawsijihynofbrt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpYm1laWF3c2lqaWh5bm9mYnJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyOTc1OTgsImV4cCI6MjA2Mzg3MzU5OH0.LXowIex23igbXXJgUoPIwoZSOQyZ1_sxCOPfE8ADP0M',
  );

  // Solo si no es web
  if (!kIsWeb) {
    // Configuración para Android
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Ubicación activa",
      notificationText: "La app está rastreando tu ubicación.",
      notificationImportance: AndroidNotificationImportance.high,
      enableWifiLock: true,
    );

    final hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
    if (hasPermissions) {
      await FlutterBackground.enableBackgroundExecution();
    }

    // Pedir permisos de ubicación
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
      permiso = await Geolocator.requestPermission();
    }

    // Ejecutar cada 15 minutos
    Timer.periodic(Duration(minutes: 15), (timer) {
      UbicacionService.obtenerYGuardar();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapeo de Terreno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1B4F72), // Azul marino sobrio

        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF5D6D7E), // Gris azulado elegante
        ),

        scaffoldBackgroundColor: Color(0xFFF4F6F7), // Gris neutro claro

        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1B4F72),
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1B4F72),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2C3E50)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF34495E)),
          titleLarge: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      home: const LoginPage(),
    );
  }
}
