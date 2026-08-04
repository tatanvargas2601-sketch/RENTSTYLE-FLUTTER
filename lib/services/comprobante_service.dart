import '../core/api/api_client.dart';
import '../models/comprobante.dart';

class ComprobanteService {
  final _client = ApiClient.instance;
  static const _base = '/api/comprobantes';

  Future<List<Comprobante>> getAll({int? idReserva}) => _client.unwrap<List<Comprobante>>(
        () => _client.dio.get(_base, queryParameters: {
          if (idReserva != null) 'idReserva': idReserva,
        }),
        (data) => (data as List).map((e) => Comprobante.fromJson(e)).toList(),
      );

  Future<Comprobante> getById(int id) => _client.unwrap<Comprobante>(
        () => _client.dio.get('$_base/$id'),
        (data) => Comprobante.fromJson(data),
      );
}
