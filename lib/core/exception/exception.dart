/// Base exception class for application and HTTP errors
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when device has no network or host is unreachable
class NetworkException extends AppException {
  NetworkException([
    super.message = 'No internet connection. Please verify your network.',
  ]);
}

/// Thrown when request takes longer than timeout duration
class HttpTimeoutException extends AppException {
  HttpTimeoutException([
    super.message = 'Connection timed out. Server took too long to respond.',
  ]);
}

/// Thrown when API returns an HTTP error code (4xx, 5xx) with the response message
class ApiException extends AppException {
  ApiException({required String message, int? statusCode})
    : super(message, statusCode: statusCode);
}
