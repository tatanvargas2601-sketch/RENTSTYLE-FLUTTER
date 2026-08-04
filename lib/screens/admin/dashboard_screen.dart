import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final base = auth.role == AppRole.admin ? '/admin' : '/empleado';

    final cards = [
      (icon: Icons.checkroom, label: 'Productos', path: '$base/productos'),
      (icon: Icons.inventory_2, label: 'Inventario', path: '$base/inventario'),
      (icon: Icons.event_note, label: 'Reservas', path: '$base/reservas'),
      if (auth.role == AppRole.admin)
        (icon: Icons.people, label: 'Usuarios', path: '$base/usuarios'),
    ];

    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: cards
          .map((c) => Card(
                child: InkWell(
                  onTap: () => context.go(c.path),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(c.icon, size: 40),
                      const SizedBox(height: 12),
                      Text(c.label, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
