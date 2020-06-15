import 'dart:convert';
import 'dart:io';

import 'package:tus_client/src/exception/tus_protocol_exception.dart';
import 'package:tus_client/src/tus_client_base.dart';

abstract class TusUploader {
  static final DEFAULT_HEADERS = {'Tus-Resumable': TusClient.TUS_VERSION};
  final File file;
  Map<String, String> metadata;
  final Map<String, String> headers = {}..addAll(DEFAULT_HEADERS);
  late final Uri url;
  int chunkSize;
  int _offset;

  /// Creates an uploader for [file].
  ///
  /// The [url] must be defined before any method of this class is called.
  /// If [metadata] is not defined, then a `filename` based on [file] will be
  /// set.
  TusUploader({
    required this.file,
    Uri? url,
    Map<String, String>? metadata,
    Map<String, String> headers = const <String, String>{},
    this.chunkSize = 2 * 1024 * 1024,
    int offset = 0,
  })  : _offset = offset,
        metadata = metadata ?? {'filename': file.path.split('/').last} {
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

  /// Uploads all chunks sequentially.
  Future<void> upload() async {
    var size = await file.length();
    while (_offset <= size) {
      await uploadChunk();
    }
  }

  /// Uploads a chunk based on [chunkSize].
  Future<void> uploadChunk() async {
    var request = await HttpClient().patchUrl(url)
      ..headers.set('Content-Type', 'application/offset+octet-stream')
      ..headers.set('Upload-Offset', _offset);

    for (var header in headers.entries) {
      request.headers.set(header.key, header.value);
    }

    await request.addStream(file.openRead(_offset, _offset + chunkSize));

    var response = await request.close();

    if (response.statusCode != 204) {
      throw TusProtocolException.fromResponse(response);
    }

    _offset += chunkSize;
  }
}
