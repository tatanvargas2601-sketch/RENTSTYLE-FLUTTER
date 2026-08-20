import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prenda.dart';
import '../services/prenda_service.dart';

class CartItem {
  final Prenda prenda;
  final int idInventario;
  int cantidad;

  CartItem({
    required this.prenda,
    required this.idInventario,
    this.cantidad = 1,
  });

  double get subtotal => prenda.precioAlquiler * cantidad;
}

/// Carrito con persistencia: guardamos solo los IDs livianos (idPrenda,
/// idInventario, cantidad) en SharedPreferences, y al reabrir la app
/// volvemos a pedir cada Prenda al backend para reconstruir el carrito
/// completo (así siempre se ve el precio/stock actualizado, no uno viejo).
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _restore();
  }

  static const _storageKey = 'cart_items_v1';
  final _prendaService = PrendaService();

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;

      final List decoded = jsonDecode(raw);
      final items = <CartItem>[];

      for (final entry in decoded) {
        try {
          final prenda = await _prendaService.getById(entry['idPrenda'] as int);
          items.add(CartItem(
            prenda: prenda,
            idInventario: entry['idInventario'] as int,
            cantidad: entry['cantidad'] as int,
          ));
        } catch (_) {
          // Prenda ya no existe o falló la carga: se descarta esa línea sola.
        }
      }

      state = items;
    } catch (_) {
      // Sin conexión al abrir la app: dejamos el carrito vacío.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state
        .map((i) => {
              'idPrenda': i.prenda.idPrenda,
              'idInventario': i.idInventario,
              'cantidad': i.cantidad,
            })
        .toList());
    await prefs.setString(_storageKey, encoded);
  }

  void add(Prenda prenda, int idInventario) {
    final index = state.indexWhere((i) => i.idInventario == idInventario);
    if (index >= 0) {
      state[index].cantidad += 1;
      state = [...state];
    } else {
      state = [...state, CartItem(prenda: prenda, idInventario: idInventario)];
    }
    _persist();
  }

  void remove(int idInventario) {
    state = state.where((i) => i.idInventario != idInventario).toList();
    _persist();
  }

  void clear() {
    state = [];
    _persist();
  }

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});