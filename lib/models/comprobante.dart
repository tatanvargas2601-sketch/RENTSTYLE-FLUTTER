class Comprobante {
  final int idComprobante;
  final int idReserva;
  final String numeroComprobante;
  final String tipoComprobante;
  final double montoTotal;
  final String estado;
  final String? descripcion;

  Comprobante({
    required this.idComprobante,
    required this.idReserva,
    required this.numeroComprobante,
    required this.tipoComprobante,
    required this.montoTotal,
    required this.estado,
    this.descripcion,
  });

  factory Comprobante.fromJson(Map<String, dynamic> json) => Comprobante(
        idComprobante: json['idComprobante'],
        idReserva: json['idReserva'],
        numeroComprobante: json['numero_comprobante'],
        tipoComprobante: json['tipo_comprobante'],
        montoTotal: double.tryParse(json['monto_total'].toString()) ?? 0,
        estado: json['estado'],
        descripcion: json['descripcion'],
      );
}
