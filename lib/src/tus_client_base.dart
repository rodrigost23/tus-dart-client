import 'dart:io';

import 'store/tus_store.dart';
import 'uploader/tus_uploader_client.dart';
import 'uploader/tus_uploader_base.dart';

///
typedef OnProgressCallback = void Function(
    int bytesWritten, int bytesTotal, double progress, TusClient tusClient);

/// This class is used for creating or resuming uploads.
class TusClient {
  /// Version of the tus protocol used by the client.
  static final String TUS_VERSION = '1.0.0';

  /// The endpoint url
  final Uri endpoint;

  /// This can be used to set the server specific headers. These headers would
  /// be sent along with every request made by the client to the server. This
  /// may be used to set authentication headers. These headers should not
  /// include headers required by tus protocol. If not set this defaults to an
  /// empty dictionary.
  Map<String, String> headers;

  OnProgressCallback? onProgress;

  /// The store in which to save files to resume later. If set to null,
  /// disables resuming.
  TusStore? store;

  int? chunkSize;

  bool get resumingEnabled => store != null;

  /// Disables upload resuming.
  void disableResuming() => store = null;

  /// Creates a new [TusClient] instance with [endpoint] as the server url.
  /// If [store] is defined, then resuming is enabled (see [resumingEnabled]).
  ///
  /// ```dart
  /// var client = TusClient(Uri.http('localhost:1080', '/files'));
  /// ```
  TusClient(
    this.endpoint, {
    this.headers = const <String, String>{},
    this.store,
    this.chunkSize,
  });

  /// Gets an upload URL from the [endpoint] and creates a new uploader.
  Future<TusUploader> createUploader({
    required File file,
  }) async =>
      await TusClientUploader.create(
        client: this,
        file: file,
      );
}
