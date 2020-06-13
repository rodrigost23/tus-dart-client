import 'dart:convert';
import 'dart:io';

abstract class TusUploader {
  static const DEFAULT_HEADERS = {'Tus-Resumable': '1.0.0'};
  final File file;
  final Map<String, String> metadata;
  final Map<String, String> headers = {}..addAll(DEFAULT_HEADERS);
  Uri? _url;

  Uri? get url => _url;

  set url(Uri? url) {
    _url = url;
  }

  TusUploader({
    required this.file,
    Uri? url,
    this.metadata = const <String, String>{},
    Map<String, String> headers = const <String, String>{},
  }) {
    this.headers.addAll(headers);
    _url = url;
  }

  String get encodedMetadata {
    if (metadata.isEmpty) {
      return '';
    }

    var encodedList = [''];
    for (var entry in metadata.entries) {
      encodedList.add((entry.key + ' ') + base64Encode(utf8.encode(entry.value)));
    }

    return encodedList.join(',');
  }

  Future<void> upload();
}
