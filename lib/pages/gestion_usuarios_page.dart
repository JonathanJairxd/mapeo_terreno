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
  List<dynamic> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final data = await supabase
        .from('usuarios')
        .select()
        .order('nombre', ascending: true);

    setState(() {
      usuarios = data;
    });
  }

  Future<void> actualizarEstado(String id, bool nuevoEstado) async {
    await supabase
        .from('usuarios')
        .update({'activo': nuevoEstado})
        .eq('id', id);
    cargarUsuarios();
  }

  Future<void> eliminarUsuario(String id) async {
    await supabase.from('usuarios').delete().eq('id', id);
    cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: usuarios.isEmpty
          ? const Center(child: Text("No hay usuarios registrados"))
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final u = usuarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(u['nombre']),
                    subtitle: Text("Rol: ${u['rol']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: u['activo'] ?? false,
                          onChanged: (val) => actualizarEstado(u['id'], val),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eliminarUsuario(u['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearUsuarioPage()),
          ).then((_) => cargarUsuarios());
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
