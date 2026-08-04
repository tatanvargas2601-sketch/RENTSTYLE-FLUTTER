class Lote {
  final int idLote;
  final int idPrenda;
  final String nombreLote;
  final String? descripcionLote;
  final int cantidadPrendas;

  Lote({
    required this.idLote,
    required this.idPrenda,
    required this.nombreLote,
    this.descripcionLote,
    required this.cantidadPrendas,
  });

  factory Lote.fromJson(Map<String, dynamic> json) => Lote(
        idLote: json['idLote'],
        idPrenda: json['idPrenda'],
        nombreLote: json['nombre_lote'],
        descripcionLote: json['descripcion_lote'],
        cantidadPrendas: json['cantidad_prendas'] ?? 0,
      );
}
