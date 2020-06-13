import 'dart:io';

import 'store/tus_store.dart';
import 'uploader/tus_uploader.dart';
import 'uploader/tus_uploader_base.dart';

///
typedef OnProgressCallback = void Function(
    int bytesWritten, int bytesTotal, double progress, TusClient tusClient);

/// This class is used for creating or resuming uploads.
class TusClient {
  /// Version of the tus protocol used by the client.
  /// The remote server needs to support this version, too
  static final String TUS_VERSION = '1.0.0';

  /// The endpoint url
  final Uri endpointUrl;

  /// Headers which will be added to every HTTP requests made by this TusClient
  /// instance.
  ///
  /// These may to overwrite tus-specific headers, which can be identified by
  /// their Tus-* prefix, and can cause unexpected behavior.
  Map<String, String> headers;

  OnProgressCallback? onProgress;

  /// The store in which to save files to resume later. If set to null,
  /// disables resuming.
  TusStore? urlStore;

  bool get resumingEnabled => urlStore != null;

  /// Disables upload resuming.
  void disableResuming() => urlStore = null;

  /// Creates a new [TusClient] instance with [endpointUrl] as the server url.
  /// If [urlStore] is defined, then resuming is enabled (see [resumingEnabled]).
  ///
  /// ```dart
  /// var client = TusClient(Uri.http('localhost:1080', '/files'));
  /// ```
  TusClient(
    this.endpointUrl, {
    this.headers = const <String, String>{},
    this.urlStore,
  });

  TusUploaderBase createUploader({
    required File file,
  }) =>
      TusUploader(
        client: this,
        file: file,
      );
}
