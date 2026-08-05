import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/loading_error_view.dart';
import '../../widgets/prenda_card.dart';

class DashboardUserScreen extends ConsumerWidget {
  const DashboardUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final prendasAsync = ref.watch(prendasProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final categoriaSel = ref.watch(categoriaFiltroProvider);
    final cartCount = ref.watch(cartProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${auth.usuario?.nombre ?? ''}'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => context.push('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.event_available_outlined),
            tooltip: 'Mis citas',
            onPressed: () => context.push('/citas'),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Mis reservas',
            onPressed: () => context.push('/mis-reservas'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de categorías (search/talla/color de tu DashboardUser.jsx
          // se pueden agregar acá siguiendo el mismo patrón cuando los necesites)
          SizedBox(
            height: 48,
            child: AsyncValueView(
              value: categoriasAsync,
              builder: (categorias) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: const Text('Todas'),
                      selected: categoriaSel == null,
                      onSelected: (_) =>
                          ref.read(categoriaFiltroProvider.notifier).state = null,
                    ),
                  ),
                  ...categorias.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(c.nombre),
                          selected: categoriaSel == c.idCategoria,
                          onSelected: (_) => ref
                              .read(categoriaFiltroProvider.notifier)
                              .state = c.idCategoria,
                        ),
                      )),
                ],
              ),
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: prendasAsync,
              builder: (prendas) => prendas.isEmpty
                  ? const Center(child: Text('No hay prendas disponibles'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: prendas.length,
                      itemBuilder: (context, i) {
                        final p = prendas[i];
                        return PrendaCard(
                          prenda: p,
                          onTap: () => context.push('/prenda/${p.idPrenda}'),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}