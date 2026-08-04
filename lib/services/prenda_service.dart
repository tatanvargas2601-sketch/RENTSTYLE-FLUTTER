import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/prenda.dart';

class PrendaService {
  final _client = ApiClient.instance;
  static const _base = '/api/prendas';

  Future<List<Prenda>> getAll({int? idCategoria}) => _client.unwrap<List<Prenda>>(
        () => _client.dio.get(_base, queryParameters: {
          if (idCategoria != null) 'idCategoria': idCategoria,
        }),
        (data) => (data as List).map((e) => Prenda.fromJson(e)).toList(),
      );

  Future<Prenda> getById(int id) => _client.unwrap<Prenda>(
        () => _client.dio.get('$_base/$id'),
        (data) => Prenda.fromJson(data),
      );

  Future<Prenda> create(Prenda prenda) => _client.unwrap<Prenda>(
        () => _client.dio.post(_base, data: prenda.toJson()),
        (data) => Prenda.fromJson(data),
      );

  Future<Prenda> update(int id, Prenda prenda) => _client.unwrap<Prenda>(
        () => _client.dio.put('$_base/$id', data: prenda.toJson()),
        (data) => Prenda.fromJson(data),
      );

  Future<void> delete(int id) => _client.unwrap<void>(
        () => _client.dio.delete('$_base/$id'),
        (_) {},
      );

  /// Sube una imagen para una prenda existente.
  /// Ajusta el endpoint exacto si tu prendas_bp.py usa otra ruta
  /// (revisa @prendas_bp.route('/<int:id>/imagenes', methods=['POST'])).
  Future<void> uploadImagen(int idPrenda, String filePath) async {
    final formData = FormData.fromMap({
      'imagen': await MultipartFile.fromFile(filePath),
    });
    await _client.unwrap<void>(
      () => _client.dio.post('$_base/$idPrenda/imagenes', data: formData),
      (_) {},
    );
  }
}
