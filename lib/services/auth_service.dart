import '../core/api/api_client.dart';
import '../models/usuario.dart';

class LoginResult {
  final String token;
  final Usuario usuario;
  final AppRole role;
  LoginResult({required this.token, required this.usuario, required this.role});
}

class AuthService {
  final _client = ApiClient.instance;

  /// POST /api/login  (ver auth_bp.py)
  Future<LoginResult> login({required String correo, required String contrasena}) async {
    final response = await _client.dio.post('/api/login', data: {
      'correo': correo,
      'Contrasena': contrasena,
    });

    final body = response.data as Map<String, dynamic>;
    if (body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Error al iniciar sesión');
    }

    final data = body['data'] as Map<String, dynamic>;
    final usuario = Usuario.fromJson(data['usuario']);
    final role = roleFromString(data['usuario']['role']);

    return LoginResult(token: data['token'], usuario: usuario, role: role);
  }

  /// GET /api/verify-token
  /// El backend devuelve el payload del JWT en `data` (idUsuario, correo, rol, exp),
  /// así que aprovechamos eso para restaurar el rol sin volver a pedir login.
  Future<Map<String, dynamic>?> verifyToken() async {
    try {
      final response = await _client.dio.get('/api/verify-token');
      if (response.data['status'] == 'success') {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}