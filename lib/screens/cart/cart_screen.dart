import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/reserva_service.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  DateTimeRange? _rango;
  bool _loading = false;

  Future<void> _confirmar() async {
    final auth = ref.read(authProvider);
    final cart = ref.read(cartProvider);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Inicia sesión para reservar')));
      return;
    }
    if (_rango == null || cart.isEmpty) return;

    setState(() => _loading = true);
    try {
      // id_administrador: normalmente lo asigna el backend o un empleado;
      // aquí se deja fijo como ejemplo, ajústalo a tu regla de negocio real.
      await ReservaService().create(
        idCliente: auth.usuario!.idUsuario,
        idAdministrador: 1,
        fechaEvento: _rango!.start,
        fechaInicio: _rango!.start,
        fechaFin: _rango!.end,
        items: cart
            .map((i) => {'idInventario': i.idInventario, 'cantidad': i.cantidad})
            .toList(),
      );
      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Reserva creada con éxito')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: cart.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      final item = cart[i];
                      return ListTile(
                        title: Text(item.prenda.nombrePrenda),
                        subtitle: Text('Cantidad: ${item.cantidad}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('S/ ${item.subtotal.toStringAsFixed(2)}'),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .remove(item.idInventario),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Fechas del alquiler'),
                        subtitle: Text(_rango == null
                            ? 'Selecciona fecha de inicio y fin'
                            : '${_rango!.start.toLocal()} → ${_rango!.end.toLocal()}'),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _rango = picked);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('S/ ${total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _confirmar,
                          child: _loading
                              ? const CircularProgressIndicator()
                              : const Text('Confirmar reserva'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
