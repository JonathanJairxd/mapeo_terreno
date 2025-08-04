import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../globals.dart';
import 'mapa_topografo_page.dart';
import 'mapa_admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;

  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();

  String mensaje = '';
  bool cargando = false;

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      setState(() => mensaje = 'Completa todos los campos.');
      return;
    }

    setState(() {
      mensaje = '';
      cargando = true;
    });

    try {
      final usuario = await supabase
          .from('usuarios')
          .select()
          .eq('email', correo)
          .eq('contrasena', contrasena)
          .maybeSingle();

      if (usuario == null || usuario['activo'] != true) {
        setState(() {
          mensaje = 'Credenciales inválidas o usuario inactivo.';
          cargando = false;
        });
        return;
      }

      usuarioIdGlobal = usuario['id'];

      if (!mounted) return;

      if (usuario['rol'] == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MapaAdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MapaTopografoPage()),
        );
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error de conexión.';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = Theme.of(context).primaryColor;
    

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 80, color: colorPrimario),
              const SizedBox(height: 20),
              Text(
                'Bienvenido al Sistema de Mapeo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Accede con tu cuenta para comenzar',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                ),
              ),
              const SizedBox(height: 24),
              if (mensaje.isNotEmpty)
                Text(
                  mensaje,
                  style: const TextStyle(color: Colors.red),
                ),
              if (mensaje.isNotEmpty) const SizedBox(height: 10),
              cargando
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
