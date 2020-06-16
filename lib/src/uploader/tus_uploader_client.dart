import 'dart:io';

import 'package:tus_client/src/exception/tus_protocol_exception.dart';
import 'package:tus_client/src/tus_client_base.dart';

import 'tus_uploader_base.dart';

class TusClientUploader extends TusUploader {
  final TusClient _client;
  late Uri _url;

  TusClientUploader._({
    required TusClient client,
    required file,
  })   : _client = client,
        super(
          file: file,
          headers: client.headers,
          chunkSize: client.chunkSize,
        );

  @override
  Uri get url => _url;

  Future<Uri> createUrl() async {
    var request = await HttpClient().postUrl(_client.endpoint)
      ..headers.set('Upload-Length', size.toString());

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
      throw await TusProtocolException.fromResponse(response);
    }

    String? urlStr = response.headers.value('Location');

    if (urlStr?.isEmpty ?? true) {
      // TODO: use a more specific Exception
      throw Exception('missing upload URL in response for creating upload');
    }

    var url = _client.endpoint.resolve(urlStr);

    if (_client.resumingEnabled) {
      _client.store?.set(fingerprint, url);
    }

    return url;
  }

  /// Initializes the url and offset.
  Future<void> init() async {
    // Tries to get the URL from the store
    var url = _client.store?.get(fingerprint);

    if (url != null) {
      _url = url;
      offset = await retrieveOffset();
    } else {
      _url = await createUrl();
    }
  }

  /// Creates an uploader instance
  static Future<TusClientUploader> create({
    required TusClient client,
    required file,
  }) async {
    var uploader = TusClientUploader._(client: client, file: file);

    await uploader.init();

    return uploader;
  }
}
