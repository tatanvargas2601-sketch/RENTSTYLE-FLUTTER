import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:provider/provider.dart';
import '../../legacy_provider/favoritos_notifier.dart';
import '../../models/inventario.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/inventario_service.dart';

class PrendaDetailScreen extends ConsumerWidget {
  final int idPrenda;
  const PrendaDetailScreen({super.key, required this.idPrenda});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prendaAsync = ref.watch(prendaServiceProvider).getById(idPrenda);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: FutureBuilder(
        future: prendaAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final prenda = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: prenda.imagenPrincipal.isNotEmpty
                      ? CachedNetworkImage(imageUrl: prenda.imagenPrincipal, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade200),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prenda.nombrePrenda, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('S/ ${prenda.precioAlquiler.toStringAsFixed(2)} / alquiler',
                              style: Theme.of(context).textTheme.titleMedium),
                          Consumer<FavoritosNotifier>(
                            builder: (context, favoritos, _) {
                              final esFavorito = favoritos.esFavorito(prenda.idPrenda);
                              return IconButton(
                                icon: Icon(
                                  esFavorito ? Icons.favorite : Icons.favorite_border,
                                  color: esFavorito ? Colors.red : null,
                                ),
                                onPressed: () => favoritos.toggle(prenda.idPrenda),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (prenda.descripcion != null) Text(prenda.descripcion!),
                      const SizedBox(height: 20),
                      Text('Disponibilidad: ${prenda.stockDisponible} de ${prenda.stockTotal}'),
                      const SizedBox(height: 20),
                      FutureBuilder<List<Inventario>>(
                        future: InventarioService().getAll(idPrenda: idPrenda),
                        builder: (context, invSnapshot) {
                          final disponibles = (invSnapshot.data ?? [])
                              .where((i) => i.estado == EstadoInventario.disponible)
                              .toList();
                          if (disponibles.isEmpty) {
                            return const Text('No hay unidades disponibles ahora mismo.');
                          }
                          return FilledButton.icon(
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Agregar al carrito'),
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .add(prenda, disponibles.first.idInventario);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Agregado al carrito')),
                              );
                            },
                          );
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
    );
  }
}
