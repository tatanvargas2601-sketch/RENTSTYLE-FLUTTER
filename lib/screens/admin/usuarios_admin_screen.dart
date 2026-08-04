import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/usuario_service.dart';

final usuarioServiceProvider = Provider((ref) => UsuarioService());
final usuariosAdminProvider = FutureProvider.autoDispose((ref) {
  return ref.read(usuarioServiceProvider).getAll();
});

class UsuariosAdminScreen extends ConsumerWidget {
  const UsuariosAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosAdminProvider);

    return Scaffold(
      body: usuariosAsync.when(
        data: (usuarios) => ListView.builder(
          itemCount: usuarios.length,
          itemBuilder: (context, i) {
            final u = usuarios[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
                child: u.avatarUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(u.nombre),
              subtitle: Text('${u.correo} · ${u.rolNombre ?? 'sin rol'}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await ref.read(usuarioServiceProvider).delete(u.idUsuario);
                  ref.invalidate(usuariosAdminProvider);
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
