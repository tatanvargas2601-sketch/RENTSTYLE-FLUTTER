import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prenda.dart';

class CartItem {
  final Prenda prenda;
  final int idInventario; // unidad específica reservada del inventario
  int cantidad;

  CartItem({required this.prenda, required this.idInventario, this.cantidad = 1});

  double get subtotal => prenda.precioAlquiler * cantidad;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(Prenda prenda, int idInventario) {
    final index = state.indexWhere((i) => i.idInventario == idInventario);
    if (index >= 0) {
      state[index].cantidad += 1;
      state = [...state];
    } else {
      state = [...state, CartItem(prenda: prenda, idInventario: idInventario)];
    }
  }

  void remove(int idInventario) {
    state = state.where((i) => i.idInventario != idInventario).toList();
  }

  void clear() => state = [];

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
