import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/prenda.dart';
import '../../providers/catalog_provider.dart';
import 'categorias_admin_screen.dart';
import 'producto_form_screen.dart';

class ProductosAdminScreen extends ConsumerWidget {
  const ProductosAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prendasAsync = ref.watch(prendasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            tooltip: 'Gestionar categorías',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Categorías')),
                body: const CategoriasAdminScreen(),
              ),
            )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const ProductoFormScreen()),
          );
          if (created == true) ref.invalidate(prendasProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: prendasAsync.when(
        data: (prendas) => ListView.builder(
          itemCount: prendas.length,
          itemBuilder: (context, i) {
            final Prenda p = prendas[i];
            return ListTile(
              leading: p.imagenPrincipal.isNotEmpty
                  ? CircleAvatar(backgroundImage: NetworkImage(p.imagenPrincipal))
                  : const CircleAvatar(child: Icon(Icons.checkroom)),
              title: Text(p.nombrePrenda),
              subtitle: Text('S/ ${p.precioAlquiler.toStringAsFixed(2)} · '
                  'Stock: ${p.stockDisponible}/${p.stockTotal}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => ProductoFormScreen(existing: p)),
                      );
                      if (updated == true) ref.invalidate(prendasProvider);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref.read(prendaServiceProvider).delete(p.idPrenda);
                      ref.invalidate(prendasProvider);
                    },
                  ),
                ],
              ),
              onTap: () => context.push('/prenda/${p.idPrenda}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
