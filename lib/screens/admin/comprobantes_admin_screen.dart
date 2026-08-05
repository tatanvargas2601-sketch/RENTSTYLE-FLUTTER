import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/comprobante_service.dart';

final comprobanteServiceProvider = Provider((ref) => ComprobanteService());
final comprobantesAdminProvider = FutureProvider.autoDispose((ref) {
  return ref.read(comprobanteServiceProvider).getAll();
});

class ComprobantesAdminScreen extends ConsumerWidget {
  const ComprobantesAdminScreen({super.key});

  Color _colorForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagado':
        return Colors.green;
      case 'anulado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comprobantesAsync = ref.watch(comprobantesAdminProvider);

    return Scaffold(
      body: comprobantesAsync.when(
        data: (comprobantes) => comprobantes.isEmpty
            ? const Center(child: Text('No hay comprobantes registrados'))
            : ListView.builder(
                itemCount: comprobantes.length,
                itemBuilder: (context, i) {
                  final c = comprobantes[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: _colorForEstado(c.estado)),
                      title: Text(c.numeroComprobante),
                      subtitle: Text(
                        '${c.tipoComprobante} · Reserva #${c.idReserva}'
                        '${c.descripcion != null ? '\n${c.descripcion}' : ''}',
                      ),
                      isThreeLine: c.descripcion != null,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('S/ ${c.montoTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(c.estado, style: Theme.of(context).textTheme.bodyMedium),
                        ],
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