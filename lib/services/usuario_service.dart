import '../core/api/api_client.dart';
import '../models/usuario.dart';

class UsuarioService {
  final _client = ApiClient.instance;
  static const _base = '/api/usuarios';

  Future<List<Usuario>> getAll() => _client.unwrap<List<Usuario>>(
        () => _client.dio.get(_base),
        (data) => (data as List).map((e) => Usuario.fromJson(e)).toList(),
      );

  Future<Usuario> getById(int id) => _client.unwrap<Usuario>(
        () => _client.dio.get('$_base/$id'),
        (data) => Usuario.fromJson(data),
      );

  Future<Usuario> create({
    required int idRol,
    required String nombre,
    required String documento,
    String? telefono,
    required String correo,
    required String contrasena,
  }) =>
      _client.unwrap<Usuario>(
        () => _client.dio.post(_base, data: {
          'idRol': idRol,
          'nombre': nombre,
          'documento': documento,
          'telefono': telefono,
          'correo': correo,
          'Contrasena': contrasena,
        }),
        (data) => Usuario.fromJson(data),
      );

  Future<Usuario> update(int id, Map<String, dynamic> changes) => _client.unwrap<Usuario>(
        () => _client.dio.put('$_base/$id', data: changes),
        (data) => Usuario.fromJson(data),
      );

  Future<void> delete(int id) => _client.unwrap<void>(
        () => _client.dio.delete('$_base/$id'),
        (_) {},
      );
}
