import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final usuario = auth.usuario;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: usuario == null
          ? const Center(child: Text('No hay datos de usuario'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      usuario.avatarUrl != null ? NetworkImage(usuario.avatarUrl!) : null,
                  child: usuario.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(height: 16),
                ListTile(title: const Text('Nombre'), subtitle: Text(usuario.nombre)),
                ListTile(title: const Text('Correo'), subtitle: Text(usuario.correo)),
                ListTile(title: const Text('Documento'), subtitle: Text(usuario.documento)),
                if (usuario.telefono != null)
                  ListTile(title: const Text('Teléfono'), subtitle: Text(usuario.telefono!)),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
    );
  }
}
