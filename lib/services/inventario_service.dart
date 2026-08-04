import '../core/api/api_client.dart';
import '../models/inventario.dart';

class InventarioService {
  final _client = ApiClient.instance;
  static const _base = '/api/inventario';

  Future<List<Inventario>> getAll({int? idPrenda}) => _client.unwrap<List<Inventario>>(
        () => _client.dio.get(_base, queryParameters: {
          if (idPrenda != null) 'idPrenda': idPrenda,
        }),
        (data) => (data as List).map((e) => Inventario.fromJson(e)).toList(),
      );

  Future<Inventario> create({
    required int idPrenda,
    int? idLote,
    required String codigoInterno,
    String? talla,
  }) =>
      _client.unwrap<Inventario>(
        () => _client.dio.post(_base, data: {
          'idPrenda': idPrenda,
          if (idLote != null) 'idLote': idLote,
          'codigo_interno': codigoInterno,
          'talla': talla,
        }),
        (data) => Inventario.fromJson(data),
      );

  Future<Inventario> updateEstado(int id, EstadoInventario estado) => _client.unwrap<Inventario>(
        () => _client.dio.put('$_base/$id', data: {
          'estado': estadoInventarioToBackend(estado),
        }),
        (data) => Inventario.fromJson(data),
      );

  Future<void> delete(int id) => _client.unwrap<void>(
        () => _client.dio.delete('$_base/$id'),
        (_) {},
      );
}
