import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/categoria.dart';
import '../models/prenda.dart';
import '../services/categoria_service.dart';
import '../services/prenda_service.dart';

final categoriaServiceProvider = Provider((ref) => CategoriaService());
final prendaServiceProvider = Provider((ref) => PrendaService());

final categoriasProvider = FutureProvider<List<Categoria>>((ref) {
  return ref.read(categoriaServiceProvider).getAll();
});

/// Filtro de categoría seleccionado en el catálogo (null = todas)
final categoriaFiltroProvider = StateProvider<int?>((ref) => null);

final prendasProvider = FutureProvider<List<Prenda>>((ref) {
  final idCategoria = ref.watch(categoriaFiltroProvider);
  return ref.read(prendaServiceProvider).getAll(idCategoria: idCategoria);
});
