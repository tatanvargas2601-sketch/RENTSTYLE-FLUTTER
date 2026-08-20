import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/categoria.dart';
import '../models/prenda.dart';
import '../services/categoria_service.dart';
import '../services/prenda_service.dart';

final categoriaServiceProvider = Provider((ref) => CategoriaService());

final prendaServiceProvider = Provider((ref) => PrendaService());

final categoriasProvider = FutureProvider<List<Categoria>>((ref) {
  return ref.read(categoriaServiceProvider).getAll();
});

/// Filtro de categoria seleccionado en el catalogo (null = todas).
/// Persiste en disco: si cerras la app con "Vestidos" seleccionado,
/// al volver a abrirla sigue filtrado por "Vestidos".
class CategoriaFiltroNotifier extends StateNotifier<int?> {
  CategoriaFiltroNotifier() : super(null) {
    _restore();
  }

  static const _storageKey = 'categoria_filtro_v1';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_storageKey);
    if (saved != null) state = saved;
  }

  Future<void> set(int? idCategoria) async {
    state = idCategoria;
    final prefs = await SharedPreferences.getInstance();
    if (idCategoria == null) {
      await prefs.remove(_storageKey);
    } else {
      await prefs.setInt(_storageKey, idCategoria);
    }
  }
}

final categoriaFiltroProvider =
    StateNotifierProvider<CategoriaFiltroNotifier, int?>((ref) {
  return CategoriaFiltroNotifier();
});

final prendasProvider = FutureProvider<List<Prenda>>((ref) {
  final idCategoria = ref.watch(categoriaFiltroProvider);
  return ref.read(prendaServiceProvider).getAll(idCategoria: idCategoria);
});