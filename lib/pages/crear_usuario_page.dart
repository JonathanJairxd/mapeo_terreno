import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrearUsuarioPage extends StatefulWidget {
  const CrearUsuarioPage({super.key});

  @override
  State<CrearUsuarioPage> createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool cargando = false;
  String mensaje = '';

  Future<void> registrarUsuario() async {
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      setState(() {
        mensaje = 'Completa todos los campos';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensaje = '';
    });

    try {
      // ✅ Paso 1: Crear en Supabase Auth
      final res = await supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: correo,
          password: contrasena,
        ),
      );

      // ✅ Paso 2: Registrar en tabla usuarios
      if (res.user != null) {
        await supabase.from('usuarios').insert({
          'id': res.user!.id,
          'correo': correo,
          'rol': 'topografo',
          'activo': true,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario creado correctamente')),
          );
          Navigator.pop(context); // Regresa a la pantalla anterior
        }
      } else {
        setState(() {
          mensaje = 'No se pudo crear el usuario en Auth';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error: $e';
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
      appBar: AppBar(title: const Text('Crear Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: correoController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: contrasenaController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (mensaje.isNotEmpty)
              Text(mensaje, style: const TextStyle(color: Colors.red)),
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registrarUsuario,
                    child: const Text('Crear usuario'),
                  ),
          ],
        ),
      ),
    );
  }
}
