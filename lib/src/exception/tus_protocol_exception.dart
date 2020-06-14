import 'dart:convert';
import 'dart:io';

class TusProtocolException implements Exception {
  final int code;
  final String error;

  TusProtocolException({required this.code, this.error = 'an error ocurred in the communication'});

  static Future<TusProtocolException> fromResponse(HttpClientResponse response) async => TusProtocolException(
        code: response.statusCode,
        error: await response.transform(ascii.decoder).single,
      );
}
