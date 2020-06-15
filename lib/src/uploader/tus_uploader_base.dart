import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:tus_client/src/exception/tus_protocol_exception.dart';
import 'package:tus_client/src/tus_client_base.dart';

abstract class TusUploader {
  static final DEFAULT_HEADERS = {'Tus-Resumable': TusClient.TUS_VERSION};
  final File file;
  Map<String, String> metadata;
  final Map<String, String> headers = {}..addAll(DEFAULT_HEADERS);
  late final Uri url;
  int chunkSize;
  @protected
  int offset;
  int? _size;
  String? _fingerprint;

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
    int? chunkSize,
    this.offset = 0,
  })  : metadata = metadata ?? {'filename': file.path.split('/').last},
        chunkSize = chunkSize ?? 2 * 1024 * 1024 {
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

  /// The file fingerprint, which is used to store and find the URL for resuming
  /// the upload
  String get fingerprint => _fingerprint ??= (file.absolute.path + size.toString());

  /// The file size
  int get size => _size ??= file.lengthSync();

  /// Uploads all chunks sequentially.
  Future<void> upload() async {
    while (offset <= size) {
      await uploadChunk();
    }
  }

  /// Uploads a chunk based on [chunkSize].
  Future<void> uploadChunk() async {
    var request = await HttpClient().patchUrl(url)
      ..headers.set('Content-Type', 'application/offset+octet-stream')
      ..headers.set('Upload-Offset', offset);

    for (var header in headers.entries) {
      request.headers.set(header.key, header.value);
    }

    await request.addStream(file.openRead(offset, offset + chunkSize));

    var response = await request.close();

    // Wrong offset
    if (response.statusCode == 409) {
      offset = await retrieveOffset();
      return uploadChunk();
    }
    if (response.statusCode != 204) {
      throw TusProtocolException.fromResponse(response);
    }

    offset += chunkSize;
  }

  Future<int> retrieveOffset() async {
    var request = await HttpClient().headUrl(url);

    for (var header in headers.entries) {
      request.headers.set(header.key, header.value);
    }

    var response = await request.close();

    var responseCode = response.statusCode;
    if (responseCode < 200 || responseCode >= 300) {
      throw TusProtocolException.fromResponse(response);
    }

    String? offset = response.headers.value('Upload-Offset');

    if (offset?.isEmpty ?? true) {
      // TODO: use a more specific Exception
      throw Exception('no offset returned from the server');
    } else {
      return int.parse(offset);
    }
  }
}
