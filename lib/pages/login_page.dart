import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mapa_topografo_page.dart'; // La ruta puede cambiar luego
import 'mapa_admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool cargando = false;
  String error = '';

  Future<void> login() async {
    setState(() {
      cargando = true;
      error = '';
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        // Buscamos el rol del usuario autenticado
        final userId = response.user!.id;
        final datos = await supabase
            .from('usuarios')
            .select('rol, activo')
            .eq('id', userId)
            .single();

        if (datos['activo'] != true) {
          setState(() {
            error = 'Usuario desactivado';
          });
          return;
        }

        final rol = datos['rol'];

        if (rol == 'admin') {
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
      } else {
        setState(() {
          error = 'Login incorrecto';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
            cargando
                ? const CircularProgressIndicator()
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
