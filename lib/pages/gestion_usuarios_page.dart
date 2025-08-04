import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'crear_usuario_page.dart';


class GestionUsuariosPage extends StatefulWidget {
  const GestionUsuariosPage({super.key});

  @override
  State<GestionUsuariosPage> createState() => _GestionUsuariosPageState();
}

class _GestionUsuariosPageState extends State<GestionUsuariosPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> usuarios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final data = await supabase
        .from('usuarios')
        .select('id, correo, rol, activo')
        .order('correo');

    setState(() {
      usuarios = List<Map<String, dynamic>>.from(data);
      cargando = false;
    });
  }

  Future<void> actualizarEstado(String id, bool activo) async {
    await supabase.from('usuarios').update({'activo': activo}).eq('id', id);
    await cargarUsuarios();
  }

  Future<void> cambiarRol(String id, String nuevoRol) async {
    await supabase.from('usuarios').update({'rol': nuevoRol}).eq('id', id);
    await cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrearUsuarioPage()),
              );
            },
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return Card(
                  child: ListTile(
                    title: Text(usuario['correo'] ?? 'Sin correo'),
                    subtitle: Text('Rol: ${usuario['rol']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: usuario['activo'] ?? false,
                          onChanged: (val) =>
                              actualizarEstado(usuario['id'], val),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (valor) =>
                              cambiarRol(usuario['id'], valor),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'topografo',
                              child: Text('Topógrafo'),
                            ),
                            PopupMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          child: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
