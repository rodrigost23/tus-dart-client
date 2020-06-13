import 'dart:io';

import 'package:tus_client/src/tus_client_base.dart';

import 'tus_uploader_base.dart';

class TusClientUploader extends TusUploader {
  final TusClient _client;

  TusClientUploader._({
    required TusClient client,
    required file,
  })   : _client = client,
        super(
          file: file,
          headers: client.headers,
        );

  /// Creates an uploader instance
  static Future<TusClientUploader> create({
    required TusClient client,
    required file,
  }) async {
    var uploader = TusClientUploader._(client: client, file: file);

    await uploader.createUrl();

    return uploader;
  }

  Future<Uri> createUrl() async {
    var request = await HttpClient().postUrl(_client.endpoint)
      ..headers.set('Upload-Length', (await file.length()).toString());

    var metadata = encodedMetadata;
    if (metadata.isNotEmpty) {
      request.headers.set('Upload-Metadata', metadata);
    }

    for (var header in headers.entries) {
      request.headers.set(header.key, header.value);
    }

    var response = await request.close();

    var responseCode = response.statusCode;
    if (responseCode < 200 || responseCode >= 300) {
      // TODO: use a more specific Exception
      throw Exception('unexpected status code ($responseCode) while creating upload');
    }

    String? urlStr = response.headers.value('Location');

    if (urlStr?.isEmpty ?? false) {
      // TODO: use a more specific Exception
      throw Exception('missing upload URL in response for creating upload');
    }

    var url = _client.endpoint.resolve(urlStr);

    if (_client.resumingEnabled) {
      // TODO: get fingerprint correctly
      _client.urlStore?.set('1234', url);
    }

    return url;
  }

  @override
  Future<void> upload() {
    // TODO: implement upload
    throw UnimplementedError();
  }
}
