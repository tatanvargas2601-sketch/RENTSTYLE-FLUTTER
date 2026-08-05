import '../core/api/api_client.dart';
import '../models/roles.dart';

class RolService {
  final _client = ApiClient.instance;
  static const _base = '/api/roles';

  Future<List<Rol>> getAll() => _client.unwrap<List<Rol>>(
        () => _client.dio.get(_base),
        (data) => (data as List).map((e) => Rol.fromJson(e)).toList(),
      );
}