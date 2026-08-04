import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/prenda.dart';

class PrendaCard extends StatelessWidget {
  final Prenda prenda;
  final VoidCallback onTap;

  const PrendaCard({super.key, required this.prenda, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: prenda.imagenPrincipal.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: prenda.imagenPrincipal,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                    )
                  : Container(color: Colors.grey.shade200, child: const Icon(Icons.checkroom)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prenda.nombrePrenda,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text('S/ ${prenda.precioAlquiler.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  if (prenda.stockDisponible == 0)
                    const Text('Sin stock', style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
