import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/reserva.dart';
import '../../services/reserva_service.dart';

final reservaServiceProvider = Provider((ref) => ReservaService());
final reservasAdminProvider = FutureProvider.autoDispose<List<Reserva>>((ref) {
  return ref.read(reservaServiceProvider).getAll();
});

class ReservasAdminScreen extends ConsumerWidget {
  const ReservasAdminScreen({super.key});

  Color _colorForEstado(EstadoReserva e) {
    switch (e) {
      case EstadoReserva.pendiente:
        return Colors.orange;
      case EstadoReserva.confirmada:
        return Colors.blue;
      case EstadoReserva.entregada:
        return Colors.purple;
      case EstadoReserva.finalizada:
        return Colors.green;
      case EstadoReserva.cancelada:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservasAsync = ref.watch(reservasAdminProvider);

    return Scaffold(
      body: reservasAsync.when(
        data: (reservas) => reservas.isEmpty
            ? const Center(child: Text('No hay reservas registradas'))
            : ListView.builder(
                itemCount: reservas.length,
                itemBuilder: (context, i) {
                  final r = reservas[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ExpansionTile(
                      leading: CircleAvatar(backgroundColor: _colorForEstado(r.estado)),
                      title: Text('Reserva #${r.idReserva} · Cliente #${r.idCliente}'),
                      subtitle: Text(
                        '${r.fechaInicio.toLocal().toString().split(' ').first} → '
                        '${r.fechaFin.toLocal().toString().split(' ').first}',
                      ),
                      children: [
                        if (r.observaciones != null && r.observaciones!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Obs: ${r.observaciones}'),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              for (final d in r.detalles)
                                Chip(
                                  label: Text(
                                    'Inv #${d.idInventario} x${d.cantidad} · S/ ${d.subtotal.toStringAsFixed(2)}',
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Cambiar estado:'),
                              DropdownButton<EstadoReserva>(
                                value: r.estado,
                                items: EstadoReserva.values
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                                    .toList(),
                                onChanged: (nuevoEstado) async {
                                  if (nuevoEstado == null) return;
                                  await ref
                                      .read(reservaServiceProvider)
                                      .updateEstado(r.idReserva, nuevoEstado);
                                  ref.invalidate(reservasAdminProvider);
                                },
                              ),
                            ],
                          ),
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
