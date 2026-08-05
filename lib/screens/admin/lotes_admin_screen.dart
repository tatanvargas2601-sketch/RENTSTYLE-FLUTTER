import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/lote.dart';
import '../../models/prenda.dart';
import '../../providers/catalog_provider.dart';
import '../../services/lote_service.dart';

final loteServiceProvider = Provider((ref) => LoteService());
final lotesAdminProvider = FutureProvider.autoDispose<List<Lote>>((ref) {
  return ref.read(loteServiceProvider).getAll();
});

class LotesAdminScreen extends ConsumerWidget {
  const LotesAdminScreen({super.key});

  Future<void> _showForm(BuildContext context, WidgetRef ref, {Lote? existing}) async {
    final prendas = await ref.read(prendaServiceProvider).getAll();
    if (!context.mounted) return;

    int? idPrenda = existing?.idPrenda ?? (prendas.isNotEmpty ? prendas.first.idPrenda : null);
    final nombreCtrl = TextEditingController(text: existing?.nombreLote ?? '');
    final descCtrl = TextEditingController(text: existing?.descripcionLote ?? '');
    final cantidadCtrl =
        TextEditingController(text: existing?.cantidadPrendas.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Nuevo lote' : 'Editar lote'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: idPrenda,
                  decoration: const InputDecoration(labelText: 'Prenda'),
                  items: prendas
                      .map((Prenda p) =>
                          DropdownMenuItem(value: p.idPrenda, child: Text(p.nombrePrenda)))
                      .toList(),
                  onChanged: (v) => setState(() => idPrenda = v),
                ),
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del lote'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: cantidadCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad de prendas'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (idPrenda == null || nombreCtrl.text.isEmpty) return;
                final cantidad = int.tryParse(cantidadCtrl.text) ?? 0;
                final service = ref.read(loteServiceProvider);
                if (existing == null) {
                  await service.create(
                    idPrenda: idPrenda!,
                    nombreLote: nombreCtrl.text.trim(),
                    descripcionLote: descCtrl.text.trim(),
                    cantidadPrendas: cantidad,
                  );
                } else {
                  await service.update(
                    existing.idLote,
                    nombreLote: nombreCtrl.text.trim(),
                    descripcionLote: descCtrl.text.trim(),
                    cantidadPrendas: cantidad,
                  );
                }
                ref.invalidate(lotesAdminProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotesAsync = ref.watch(lotesAdminProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: lotesAsync.when(
        data: (lotes) => lotes.isEmpty
            ? const Center(child: Text('No hay lotes registrados'))
            : ListView.builder(
                itemCount: lotes.length,
                itemBuilder: (context, i) {
                  final l = lotes[i];
                  return ListTile(
                    leading: const Icon(Icons.layers_outlined),
                    title: Text(l.nombreLote),
                    subtitle: Text(
                        '${l.descripcionLote ?? 'Sin descripción'} · ${l.cantidadPrendas} prendas'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showForm(context, ref, existing: l),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref.read(loteServiceProvider).delete(l.idLote);
                            ref.invalidate(lotesAdminProvider);
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