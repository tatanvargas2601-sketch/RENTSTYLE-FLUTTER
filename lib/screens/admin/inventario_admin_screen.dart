import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/inventario.dart';
import '../../providers/catalog_provider.dart';
import '../../services/inventario_service.dart';

final inventarioServiceProvider = Provider((ref) => InventarioService());

final inventarioAdminProvider = FutureProvider.autoDispose<List<Inventario>>((ref) {
  return ref.read(inventarioServiceProvider).getAll();
});

class InventarioAdminScreen extends ConsumerWidget {
  const InventarioAdminScreen({super.key});

  Future<void> _crearUnidad(BuildContext context, WidgetRef ref) async {
    final prendas = await ref.read(prendaServiceProvider).getAll();
    if (!context.mounted) return;

    int? idPrenda = prendas.isNotEmpty ? prendas.first.idPrenda : null;
    final codigoCtrl = TextEditingController();
    final tallaCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva unidad de inventario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: idPrenda,
                decoration: const InputDecoration(labelText: 'Prenda'),
                items: prendas
                    .map((p) => DropdownMenuItem(value: p.idPrenda, child: Text(p.nombrePrenda)))
                    .toList(),
                onChanged: (v) => setState(() => idPrenda = v),
              ),
              TextField(
                controller: codigoCtrl,
                decoration: const InputDecoration(labelText: 'Código interno'),
              ),
              TextField(
                controller: tallaCtrl,
                decoration: const InputDecoration(labelText: 'Talla'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (idPrenda == null || codigoCtrl.text.isEmpty) return;
                await ref.read(inventarioServiceProvider).create(
                      idPrenda: idPrenda!,
                      codigoInterno: codigoCtrl.text.trim(),
                      talla: tallaCtrl.text.trim(),
                    );
                ref.invalidate(inventarioAdminProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForEstado(EstadoInventario e) {
    switch (e) {
      case EstadoInventario.disponible:
        return Colors.green;
      case EstadoInventario.reservado:
        return Colors.orange;
      case EstadoInventario.alquilado:
        return Colors.blue;
      case EstadoInventario.reparacion:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventarioAsync = ref.watch(inventarioAdminProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _crearUnidad(context, ref),
        child: const Icon(Icons.add),
      ),
      body: inventarioAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final inv = items[i];
            return ListTile(
              leading: CircleAvatar(backgroundColor: _colorForEstado(inv.estado)),
              title: Text(inv.codigoInterno),
              subtitle: Text('Talla: ${inv.talla ?? '-'}'),
              trailing: DropdownButton<EstadoInventario>(
                value: inv.estado,
                items: EstadoInventario.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (nuevoEstado) async {
                  if (nuevoEstado == null) return;
                  await ref
                      .read(inventarioServiceProvider)
                      .updateEstado(inv.idInventario, nuevoEstado);
                  ref.invalidate(inventarioAdminProvider);
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
