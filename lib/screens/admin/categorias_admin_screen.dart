import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/categoria.dart';
import '../../providers/catalog_provider.dart';

/// Este es el patrón de referencia para los demás CRUDs de admin:
/// listar -> AsyncValue, crear/editar -> diálogo simple, eliminar -> confirmación.
class CategoriasAdminScreen extends ConsumerWidget {
  const CategoriasAdminScreen({super.key});

  Future<void> _showForm(BuildContext context, WidgetRef ref, {Categoria? existing}) async {
    final ctrl = TextEditingController(text: existing?.nombre ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Nueva categoría' : 'Editar categoría'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;

    final service = ref.read(categoriaServiceProvider);
    if (existing == null) {
      await service.create(result);
    } else {
      await service.update(existing.idCategoria, result);
    }
    ref.invalidate(categoriasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categoriasAsync.when(
        data: (categorias) => ListView.builder(
          itemCount: categorias.length,
          itemBuilder: (context, i) {
            final c = categorias[i];
            return ListTile(
              title: Text(c.nombre),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showForm(context, ref, existing: c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref.read(categoriaServiceProvider).delete(c.idCategoria);
                      ref.invalidate(categoriasProvider);
                    },
                  ),
                ],
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
