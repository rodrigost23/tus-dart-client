import 'dart:convert';
import 'dart:io';

class TusProtocolException implements Exception {
  final int code;
  final String? error;

  TusProtocolException({required this.code, this.error});

  /// Asyncronously create an exception from the provided [response].
  static Future<TusProtocolException> fromResponse(HttpClientResponse response) async {
    var error = await response.transform(ascii.decoder).single.catchError((_) => null);

    return TusProtocolException(
      code: response.statusCode,
      error: error,
    );
  }

  @override
  String toString() {
    if (error == null) return 'TusProtocolException ($code)';
    return 'TusProtocolException: ($code) $error';
  }
}
