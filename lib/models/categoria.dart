class Categoria {
  final int idCategoria;
  final String nombre;

  Categoria({required this.idCategoria, required this.nombre});

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        idCategoria: json['idCategoria'],
        nombre: json['nombre'],
      );

  Map<String, dynamic> toJson() => {'nombre': nombre};
}
