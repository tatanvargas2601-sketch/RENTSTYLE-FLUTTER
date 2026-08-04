/// Tu backend Flask siempre responde con la forma:
/// { "success": bool, "message": str, "data": ... }
/// (ver app/utils/response.py -> response_success / response_error)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromData,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: rawData != null && fromData != null ? fromData(rawData) : rawData,
    );
  }
}

/// Excepción unificada para errores de red o de negocio (400/401/404/500)
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
