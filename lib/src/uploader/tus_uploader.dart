import 'package:tus_client/src/tus_client_base.dart';

import 'tus_uploader_base.dart';

class TusUploader extends TusUploaderBase {
  TusClient _client;

  TusUploader({
    required TusClient client,
    required file,
  })   : _client = client,
        super(
          file: file,
        );

  @override
  Future<void> upload() {
    // TODO: implement upload
    throw UnimplementedError();
  }
}
