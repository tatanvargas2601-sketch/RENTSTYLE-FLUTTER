import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isAdmin = auth.role == AppRole.admin;
    final base = isAdmin ? '/admin' : '/empleado';
    final location = GoRouterState.of(context).matchedLocation;

    final items = [
      (icon: Icons.dashboard, label: 'Dashboard', path: base),
      (icon: Icons.checkroom, label: 'Productos', path: '$base/productos'),
      (icon: Icons.inventory_2, label: 'Inventario', path: '$base/inventario'),
      (icon: Icons.event_note, label: 'Reservas', path: '$base/reservas'),
      if (isAdmin) (icon: Icons.people, label: 'Usuarios', path: '$base/usuarios'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'Panel Admin' : 'Panel Empleado')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(auth.usuario?.nombre ?? (isAdmin ? 'Administrador' : 'Empleado')),
            ),
            for (final item in items)
              ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                selected: location == item.path,
                onTap: () {
                  Navigator.pop(context);
                  context.go(item.path);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
