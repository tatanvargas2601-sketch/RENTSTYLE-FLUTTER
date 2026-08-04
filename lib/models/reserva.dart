import 'detalle_reserva.dart';

enum EstadoReserva { pendiente, confirmada, entregada, finalizada, cancelada }

EstadoReserva estadoReservaFromString(String? value) {
  switch (value) {
    case 'Confirmada':
      return EstadoReserva.confirmada;
    case 'Entregada':
      return EstadoReserva.entregada;
    case 'Finalizada':
      return EstadoReserva.finalizada;
    case 'Cancelada':
      return EstadoReserva.cancelada;
    default:
      return EstadoReserva.pendiente;
  }
}

class Reserva {
  final int idReserva;
  final int idCliente;
  final int idAdministrador;
  final DateTime fechaReserva;
  final DateTime fechaEvento;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime? fechaDevolucion;
  final EstadoReserva estado;
  final String? observaciones;
  final List<DetalleReserva> detalles;

  Reserva({
    required this.idReserva,
    required this.idCliente,
    required this.idAdministrador,
    required this.fechaReserva,
    required this.fechaEvento,
    required this.fechaInicio,
    required this.fechaFin,
    this.fechaDevolucion,
    required this.estado,
    this.observaciones,
    this.detalles = const [],
  });

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
        idReserva: json['idReserva'],
        idCliente: json['id_cliente'],
        idAdministrador: json['id_administrador'],
        fechaReserva: DateTime.parse(json['fecha_reserva']),
        fechaEvento: DateTime.parse(json['fecha_evento']),
        fechaInicio: DateTime.parse(json['fecha_inicio']),
        fechaFin: DateTime.parse(json['fecha_fin']),
        fechaDevolucion: json['fecha_devolucion'] != null
            ? DateTime.parse(json['fecha_devolucion'])
            : null,
        estado: estadoReservaFromString(json['estado']),
        observaciones: json['observaciones'],
        detalles: (json['detalles_reserva'] as List? ?? [])
            .map((e) => DetalleReserva.fromJson(e))
            .toList(),
      );
}
