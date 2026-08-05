import '../core/api/api_client.dart';
import '../models/lote.dart';

class LoteService {
  final _client = ApiClient.instance;
  static const _base = '/api/lotes';

  Future<List<Lote>> getAll({int? idPrenda}) => _client.unwrap<List<Lote>>(
        () => _client.dio.get(_base, queryParameters: {
          if (idPrenda != null) 'idPrenda': idPrenda,
        }),
        (data) => (data as List).map((e) => Lote.fromJson(e)).toList(),
      );

  Future<Lote> create({
    required int idPrenda,
    required String nombreLote,
    String? descripcionLote,
    required int cantidadPrendas,
  }) =>
      _client.unwrap<Lote>(
        () => _client.dio.post(_base, data: {
          'idPrenda': idPrenda,
          'nombre_lote': nombreLote,
          'descripcion_lote': descripcionLote,
          'cantidad_prendas': cantidadPrendas,
        }),
        (data) => Lote.fromJson(data),
      );

  Future<Lote> update(
    int id, {
    String? nombreLote,
    String? descripcionLote,
    int? cantidadPrendas,
  }) =>
      _client.unwrap<Lote>(
        () => _client.dio.put('$_base/$id', data: {
          if (nombreLote != null) 'nombre_lote': nombreLote,
          if (descripcionLote != null) 'descripcion_lote': descripcionLote,
          if (cantidadPrendas != null) 'cantidad_prendas': cantidadPrendas,
        }),
        (data) => Lote.fromJson(data),
      );

  Future<void> delete(int id) => _client.unwrap<void>(
        () => _client.dio.delete('$_base/$id'),
        (_) {},
      );
}