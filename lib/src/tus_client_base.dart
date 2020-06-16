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

  /// The specific headers to send to the server.
  ///
  /// {@macro headers_description}
  /// See [TusUploader.headers]
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
  ///   Uri.http('localhost:1080', '/files/'),
  ///   store: TusMemoryStore(),
  /// );
  /// ```
  TusClient(
    this.endpoint, {
    this.headers = const <String, String>{},
    this.store,
    this.chunkSize,
  });

  /// Creates a new [TusUploader].
  ///
  /// If resuming is enabled, i.e., the [store] is not null, this method first
  /// searches for the
  Future<TusUploader> createUploader({
    required File file,
  }) async =>
      await TusClientUploader.create(
        client: this,
        file: file,
      );
}
