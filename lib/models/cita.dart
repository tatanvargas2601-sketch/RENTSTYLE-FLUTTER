enum EstadoCita { pendiente, atendida, cancelada }

EstadoCita estadoCitaFromString(String? value) {
  switch (value) {
    case 'Atendida':
      return EstadoCita.atendida;
    case 'Cancelada':
      return EstadoCita.cancelada;
    default:
      return EstadoCita.pendiente;
  }
}

class Cita {
  final int idCita;
  final int idAdministrador;
  final int idCliente;
  final int? idReserva;
  final DateTime fechaCita;
  final String? motivo;
  final EstadoCita estado;

  Cita({
    required this.idCita,
    required this.idAdministrador,
    required this.idCliente,
    this.idReserva,
    required this.fechaCita,
    this.motivo,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
        idCita: json['idCita'],
        idAdministrador: json['id_administrador'],
        idCliente: json['id_cliente'],
        idReserva: json['id_reserva'],
        fechaCita: DateTime.parse(json['fecha_cita']),
        motivo: json['motivo'],
        estado: estadoCitaFromString(json['estado']),
      );

  Map<String, dynamic> toJson() => {
        'id_administrador': idAdministrador,
        'id_cliente': idCliente,
        if (idReserva != null) 'id_reserva': idReserva,
        'fecha_cita': fechaCita.toIso8601String(),
        'motivo': motivo,
      };
}
