import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:riverpod_statemanagement/core/exception/exception.dart';

/// Reusable HTTP client service handling requests, timeouts, and error parsing
class HttpService {
  final http.Client _client;
  final Duration timeoutDuration;

  HttpService({
    http.Client? client,
    this.timeoutDuration = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  /// Performs a GET request to the given [url]
  Future<dynamic> get(Uri url, {Map<String, String>? headers}) async {
    try {
      final response = await _client
          .get(url, headers: headers)
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw HttpTimeoutException();
    } on FormatException {
      throw AppException('Invalid response format received from server.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Unexpected error occurred: $e');
    }
  }

  /// Evaluates the HTTP response: parses JSON, extracts error messages on failure
  dynamic _processResponse(http.Response response) {
    dynamic responseBody;
    try {
      if (response.body.isNotEmpty) {
        responseBody = jsonDecode(response.body);
      }
    } catch (_) {
      throw AppException('Invalid response format received from server.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }

    // Extract error message from API response payload (e.g. {"message": "..."})
    String errorMessage = 'Request failed with status: ${response.statusCode}';
    if (responseBody is Map<String, dynamic>) {
      if (responseBody['message'] is String &&
          (responseBody['message'] as String).isNotEmpty) {
        errorMessage = responseBody['message'];
      } else if (responseBody['error'] is String &&
          (responseBody['error'] as String).isNotEmpty) {
        errorMessage = responseBody['error'];
      }
    }

    throw ApiException(message: errorMessage, statusCode: response.statusCode);
  }
}
