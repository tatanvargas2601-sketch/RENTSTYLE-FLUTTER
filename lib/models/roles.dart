class Rol {
  final int idRol;
  final String nombre;

  Rol({required this.idRol, required this.nombre});

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
        idRol: json['idRol'],
        nombre: json['nombre'],
      );
}
