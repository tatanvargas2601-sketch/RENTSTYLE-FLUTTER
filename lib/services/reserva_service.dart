import '../core/api/api_client.dart';
import '../models/reserva.dart';

class ReservaService {
  final _client = ApiClient.instance;
  static const _base = '/api/reservas';

  Future<List<Reserva>> getAll({int? idCliente}) => _client.unwrap<List<Reserva>>(
        () => _client.dio.get(_base, queryParameters: {
          if (idCliente != null) 'id_cliente': idCliente,
        }),
        (data) => (data as List).map((e) => Reserva.fromJson(e)).toList(),
      );

  Future<Reserva> getById(int id) => _client.unwrap<Reserva>(
        () => _client.dio.get('$_base/$id'),
        (data) => Reserva.fromJson(data),
      );

  /// Crea una reserva a partir del carrito.
  /// items: lista de {"idInventario": x, "cantidad": y}
  Future<Reserva> create({
    required int idCliente,
    required int idAdministrador,
    required DateTime fechaEvento,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? observaciones,
    required List<Map<String, dynamic>> items,
  }) =>
      _client.unwrap<Reserva>(
        () => _client.dio.post(_base, data: {
          'id_cliente': idCliente,
          'id_administrador': idAdministrador,
          'fecha_evento': fechaEvento.toIso8601String().split('T').first,
          'fecha_inicio': fechaInicio.toIso8601String().split('T').first,
          'fecha_fin': fechaFin.toIso8601String().split('T').first,
          'observaciones': observaciones,
          'detalles': items,
        }),
        (data) => Reserva.fromJson(data),
      );

  Future<Reserva> updateEstado(int id, EstadoReserva estado) => _client.unwrap<Reserva>(
        () => _client.dio.put('$_base/$id', data: {
          'estado': estado.name[0].toUpperCase() + estado.name.substring(1),
        }),
        (data) => Reserva.fromJson(data),
      );

  Future<void> delete(int id) => _client.unwrap<void>(
        () => _client.dio.delete('$_base/$id'),
        (_) {},
      );
}
