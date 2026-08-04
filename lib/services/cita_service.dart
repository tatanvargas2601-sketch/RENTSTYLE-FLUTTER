import '../core/api/api_client.dart';
import '../models/cita.dart';

class CitaService {
  final _client = ApiClient.instance;
  static const _base = '/api/citas';

  Future<List<Cita>> getAll({int? idCliente}) => _client.unwrap<List<Cita>>(
        () => _client.dio.get(_base, queryParameters: {
          if (idCliente != null) 'id_cliente': idCliente,
        }),
        (data) => (data as List).map((e) => Cita.fromJson(e)).toList(),
      );

  Future<Cita> create(Cita cita) => _client.unwrap<Cita>(
        () => _client.dio.post(_base, data: cita.toJson()),
        (data) => Cita.fromJson(data),
      );

  Future<Cita> updateEstado(int id, EstadoCita estado) => _client.unwrap<Cita>(
        () => _client.dio.put('$_base/$id', data: {
          'estado': estado.name[0].toUpperCase() + estado.name.substring(1),
        }),
        (data) => Cita.fromJson(data),
      );

  Future<void> delete(int id) => _client.unwrap<void>(
        () => _client.dio.delete('$_base/$id'),
        (_) {},
      );
}
