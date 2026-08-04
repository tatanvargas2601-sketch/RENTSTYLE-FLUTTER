import 'prenda_imagen.dart';

class Prenda {
  final int idPrenda;
  final int idCategoria;
  final String? categoriaNombre;
  final String nombrePrenda;
  final String? descripcion;
  final String? color;
  final double precioAlquiler;
  final List<PrendaImagen> imagenes;

  // Viene de _stock_summary() en prendas_bp.py
  final int stockTotal;
  final int stockDisponible;

  Prenda({
    required this.idPrenda,
    required this.idCategoria,
    this.categoriaNombre,
    required this.nombrePrenda,
    this.descripcion,
    this.color,
    required this.precioAlquiler,
    this.imagenes = const [],
    this.stockTotal = 0,
    this.stockDisponible = 0,
  });

  String get imagenPrincipal => imagenes.isNotEmpty ? imagenes.first.url : '';

  factory Prenda.fromJson(Map<String, dynamic> json) => Prenda(
        idPrenda: json['idPrenda'],
        idCategoria: json['idCategoria'],
        categoriaNombre: json['categoria_nombre'],
        nombrePrenda: json['nombre_prenda'],
        descripcion: json['descripcion'],
        color: json['color'],
        precioAlquiler: double.tryParse(json['precio_alquiler'].toString()) ?? 0,
        imagenes: (json['imagenes'] as List? ?? [])
            .map((e) => PrendaImagen.fromJson(e))
            .toList(),
        stockTotal: json['stock_total'] ?? 0,
        stockDisponible: json['stock_disponible'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'idCategoria': idCategoria,
        'nombre_prenda': nombrePrenda,
        'descripcion': descripcion,
        'color': color,
        'precio_alquiler': precioAlquiler,
      };
}
