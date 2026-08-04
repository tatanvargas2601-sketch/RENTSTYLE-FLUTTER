enum AppRole { admin, empleado, user }

AppRole roleFromString(String? value) {
  switch (value) {
    case 'admin':
      return AppRole.admin;
    case 'empleado':
      return AppRole.empleado;
    default:
      return AppRole.user;
  }
}

class Usuario {
  final int idUsuario;
  final int idRol;
  final String? rolNombre;
  final String nombre;
  final String documento;
  final String? telefono;
  final String correo;
  final String? avatarUrl;

  Usuario({
    required this.idUsuario,
    required this.idRol,
    this.rolNombre,
    required this.nombre,
    required this.documento,
    this.telefono,
    required this.correo,
    this.avatarUrl,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        idUsuario: json['idUsuario'],
        idRol: json['idRol'],
        rolNombre: json['rol_nombre'],
        nombre: json['nombre'],
        documento: json['documento'],
        telefono: json['telefono'],
        correo: json['correo'],
        avatarUrl: json['avatar_url'],
      );

  /// El rol "de verdad" para decidir navegación viene del JWT (ver auth_provider),
  /// esto es solo un fallback basado en el nombre de rol crudo del usuario.
  AppRole get roleFallback => roleFromString(rolNombre?.toLowerCase());
}
