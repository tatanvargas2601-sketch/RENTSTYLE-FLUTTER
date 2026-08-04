class PrendaImagen {
  final int idImagen;
  final int idPrenda;

  /// El backend ya devuelve la URL completa de Cloudinary resuelta
  /// (ver _image_url en prendas_bp.py), no el public_id crudo.
  final String url;

  PrendaImagen({required this.idImagen, required this.idPrenda, required this.url});

  factory PrendaImagen.fromJson(Map<String, dynamic> json) => PrendaImagen(
        idImagen: json['idImagen'] ?? 0,
        idPrenda: json['idPrenda'] ?? 0,
        url: json['url'] ?? json['filename'] ?? '',
      );
}
