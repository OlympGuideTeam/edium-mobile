class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiException(this.message, {this.code, this.statusCode, this.details});

  @override
  String toString() => message;
}
