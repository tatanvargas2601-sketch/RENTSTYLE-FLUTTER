import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/loading_error_view.dart';
import '../../widgets/prenda_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final prendasAsync = ref.watch(prendasProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final categoriaSel = ref.watch(categoriaFiltroProvider);
    final cartCount = ref.watch(cartProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RentStyle'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => context.push('/cart'),
          ),
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push('/profile'),
            )
          else
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Iniciar sesión'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Hero, equivalente a la sección .hero de Inicio.jsx
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ELEGANCIA BAJO DEMANDA',
                    style: TextStyle(
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Text('RentStyle', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Alquila atuendos cuidadosamente seleccionados para cada ocasión.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Filtro de categorías, equivalente al selector en Inicio.jsx
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
