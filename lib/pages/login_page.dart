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
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  final supabase = Supabase.instance.client;

  bool cargando = false;
  String mensaje = '';

  Future<void> login() async {
    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      final correo = correoController.text.trim();
      final contrasena = contrasenaController.text.trim();

      final data = await supabase
          .from('usuarios')
          .select()
          .eq('email', correo)
          .eq('contrasena', contrasena)
          .eq('activo', true)
          .maybeSingle();

      if (data == null) {
        setState(() {
          mensaje = 'Credenciales incorrectas o usuario inactivo.';
        });
        return;
      }

      usuarioIdGlobal = data['id'].toString();
      rolGlobal = data['rol'].toString();
      nombreUsuarioGlobal = data['nombre'].toString();

      if (rolGlobal == 'topografo') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MapaTopografoPage()),
        );
      } else if (rolGlobal == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MapaAdminPage()),
        );
      } else {
        setState(() {
          mensaje = 'Rol no reconocido.';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al iniciar sesión: $e';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: correoController,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: contrasenaController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (mensaje.isNotEmpty)
              Text(mensaje, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            cargando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: login,
                    child: const Text('Ingresar'),
                  ),
          ],
        ),
      ),
    );
  }
}
