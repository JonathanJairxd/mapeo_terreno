import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrearUsuarioPage extends StatefulWidget {
  const CrearUsuarioPage({super.key});

  @override
  State<CrearUsuarioPage> createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final supabase = Supabase.instance.client;

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();

  String rol = 'topografo';
  bool guardando = false;
  String mensaje = '';

  Future<void> guardarUsuario() async {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (nombre.isEmpty || correo.isEmpty || contrasena.isEmpty) {
      setState(() {
        mensaje = 'Todos los campos son obligatorios.';
      });
      return;
    }

    setState(() {
      guardando = true;
      mensaje = '';
    });

    try {
      final existe = await supabase
          .from('usuarios')
          .select()
          .eq('email', correo)
          .maybeSingle();

      if (existe != null) {
        setState(() {
          mensaje = 'Ya existe un usuario con ese correo.';
          guardando = false;
        });
        return;
      }

      await supabase.from('usuarios').insert({
        'nombre': nombre,
        'email': correo,
        'contrasena': contrasena,
        'rol': rol,
        'activo': true,
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error: $e';
        guardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Icon(Icons.person_add, size: 60, color: Colors.blueGrey),
            const SizedBox(height: 15),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
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
            DropdownButtonFormField<String>(
              value: rol,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(value: 'topografo', child: Text('Topógrafo')),
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
              ],
              onChanged: (val) {
                setState(() {
                  rol = val ?? 'topografo';
                });
              },
            ),
            const SizedBox(height: 15),
            if (mensaje.isNotEmpty)
              Text(mensaje, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            guardando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: guardarUsuario,
                    label: const Text('Crear usuario'),
                  ),
          ],
        ),
      ),
    );
  }
}
