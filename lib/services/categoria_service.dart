import '../core/api/api_client.dart';
import '../models/categoria.dart';

class CategoriaService {
  final _client = ApiClient.instance;
  static const _base = '/api/categorias';

  Future<List<Categoria>> getAll() => _client.unwrap<List<Categoria>>(
        () => _client.dio.get(_base),
        (data) => (data as List).map((e) => Categoria.fromJson(e)).toList(),
      );

  Future<Categoria> create(String nombre) => _client.unwrap<Categoria>(
        () => _client.dio.post(_base, data: {'nombre': nombre}),
        (data) => Categoria.fromJson(data),
      );

  Future<Categoria> update(int id, String nombre) => _client.unwrap<Categoria>(
        () => _client.dio.put('$_base/$id', data: {'nombre': nombre}),
        (data) => Categoria.fromJson(data),
      );

  Future<void> delete(int id) => _client.unwrap<void>(
        () => _client.dio.delete('$_base/$id'),
        (_) {},
      );
}
