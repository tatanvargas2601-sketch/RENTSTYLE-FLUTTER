import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/reserva.dart';
import '../../providers/auth_provider.dart';
import '../../services/reserva_service.dart';

final misReservasProvider = FutureProvider.autoDispose<List<Reserva>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.usuario == null) return [];
  return ReservaService().getAll(idCliente: auth.usuario!.idUsuario);
});

class MisReservasScreen extends ConsumerWidget {
  const MisReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservasAsync = ref.watch(misReservasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      body: reservasAsync.when(
        data: (reservas) => reservas.isEmpty
            ? const Center(child: Text('Aún no tienes reservas'))
            : ListView.builder(
                itemCount: reservas.length,
                itemBuilder: (context, i) {
                  final r = reservas[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text('Reserva #${r.idReserva}'),
                      subtitle: Text(
                        '${r.fechaInicio.toLocal().toString().split(' ').first} → '
                        '${r.fechaFin.toLocal().toString().split(' ').first}',
                      ),
                      trailing: Chip(label: Text(r.estado.name)),
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
