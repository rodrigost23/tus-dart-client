import 'dart:convert';
import 'dart:io';

import 'package:tus_client/src/tus_client_base.dart';

abstract class TusUploader {
  static final DEFAULT_HEADERS = {'Tus-Resumable': TusClient.TUS_VERSION};
  final File file;
  final Map<String, String> metadata;
  final Map<String, String> headers = {}..addAll(DEFAULT_HEADERS);
  late final Uri url;
  int chunkSize;
  int _offset;

  /// Creates an uploader for [file]. The [url] must be defined before it any
  /// method of this class is called.
  TusUploader({
    required this.file,
    Uri? url,
    this.metadata = const <String, String>{},
    Map<String, String> headers = const <String, String>{},
    this.chunkSize = 2 * 1024 * 1024,
    int offset = 0,
  }) : _offset = offset {
    this.headers.addAll(headers);
    if (url != null) {
      this.url = url;
    }
  }

  /// The metadata encoded as the tus protocol requires.
  String get encodedMetadata {
    //TODO: check if key contains only valid characters
    if (metadata.isEmpty) {
      return '';
    }

    var encodedList = [''];
    for (var entry in metadata.entries) {
      encodedList.add((entry.key + ' ') + base64Encode(utf8.encode(entry.value)));
    }

    return encodedList.join(',');
  }

  Future<void> uploadChunk() async {
    var request = await HttpClient().patchUrl(url)
      ..headers.set('Content-Type', 'application/offset+octet-stream')
      ..headers.set('Upload-Offset', _offset);

    for (var header in headers.entries) {
      request.headers.set(header.key, header.value);
    }

    await request.addStream(file.openRead(_offset, chunkSize));

    var response = await request.close();

    if (response.statusCode != 204) {
      // TODO: throw a more specific exception
      throw Exception(await response.transform(ascii.decoder).single);
    }
  }
}
