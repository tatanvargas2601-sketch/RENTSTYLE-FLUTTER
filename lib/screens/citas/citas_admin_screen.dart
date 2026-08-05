import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cita.dart';
import '../../services/cita_service.dart';

final citaServiceProvider = Provider((ref) => CitaService());
final citasAdminProvider = FutureProvider.autoDispose<List<Cita>>((ref) {
  return ref.read(citaServiceProvider).getAll();
});

class CitasAdminScreen extends ConsumerWidget {
  const CitasAdminScreen({super.key});

  Color _colorForEstado(EstadoCita e) {
    switch (e) {
      case EstadoCita.pendiente:
        return Colors.orange;
      case EstadoCita.atendida:
        return Colors.green;
      case EstadoCita.cancelada:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citasAsync = ref.watch(citasAdminProvider);

    return Scaffold(
      body: citasAsync.when(
        data: (citas) => citas.isEmpty
            ? const Center(child: Text('No hay citas agendadas'))
            : ListView.builder(
                itemCount: citas.length,
                itemBuilder: (context, i) {
                  final cita = citas[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: _colorForEstado(cita.estado)),
                      title: Text(cita.motivo ?? 'Cita'),
                      subtitle: Text(
                        'Cliente #${cita.idCliente} · '
                        '${cita.fechaCita.toLocal().toString().substring(0, 16)}',
                      ),
                      trailing: DropdownButton<EstadoCita>(
                        value: cita.estado,
                        items: EstadoCita.values
                            .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                            .toList(),
                        onChanged: (nuevoEstado) async {
                          if (nuevoEstado == null) return;
                          await ref
                              .read(citaServiceProvider)
                              .updateEstado(cita.idCita, nuevoEstado);
                          ref.invalidate(citasAdminProvider);
                        },
                      ),
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