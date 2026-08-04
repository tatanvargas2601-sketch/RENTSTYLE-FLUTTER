import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/cita.dart';
import '../../providers/auth_provider.dart';
import '../../services/cita_service.dart';

final citasProvider = FutureProvider.autoDispose<List<Cita>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.usuario == null) return [];
  return CitaService().getAll(idCliente: auth.usuario!.idUsuario);
});

class CitasScreen extends ConsumerWidget {
  const CitasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citasAsync = ref.watch(citasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis citas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/agendar-cita'),
        icon: const Icon(Icons.add),
        label: const Text('Agendar'),
      ),
      body: citasAsync.when(
        data: (citas) => citas.isEmpty
            ? const Center(child: Text('No tienes citas agendadas'))
            : ListView.builder(
                itemCount: citas.length,
                itemBuilder: (context, i) {
                  final cita = citas[i];
                  return ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(cita.motivo ?? 'Cita'),
                    subtitle: Text(cita.fechaCita.toLocal().toString()),
                    trailing: Chip(label: Text(cita.estado.name)),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
