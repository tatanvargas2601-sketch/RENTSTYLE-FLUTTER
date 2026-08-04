enum EstadoInventario { disponible, reservado, alquilado, reparacion }

EstadoInventario estadoInventarioFromString(String? value) {
  switch (value) {
    case 'Reservado':
      return EstadoInventario.reservado;
    case 'Alquilado':
      return EstadoInventario.alquilado;
    case 'Reparacion':
      return EstadoInventario.reparacion;
    default:
      return EstadoInventario.disponible;
  }
}

String estadoInventarioToBackend(EstadoInventario e) {
  switch (e) {
    case EstadoInventario.reservado:
      return 'Reservado';
    case EstadoInventario.alquilado:
      return 'Alquilado';
    case EstadoInventario.reparacion:
      return 'Reparacion';
    case EstadoInventario.disponible:
      return 'Disponible';
  }
}

class Inventario {
  final int idInventario;
  final int idPrenda;
  final int? idLote;
  final String codigoInterno;
  final String? talla;
  final EstadoInventario estado;

  Inventario({
    required this.idInventario,
    required this.idPrenda,
    this.idLote,
    required this.codigoInterno,
    this.talla,
    required this.estado,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) => Inventario(
        idInventario: json['idInventario'],
        idPrenda: json['idPrenda'],
        idLote: json['idLote'],
        codigoInterno: json['codigo_interno'],
        talla: json['talla'],
        estado: estadoInventarioFromString(json['estado']),
      );
}
