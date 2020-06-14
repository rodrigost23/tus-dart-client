import 'dart:io';

import 'package:tus_client/tus_client.dart';
import 'package:test/test.dart';

void main() {
  late TusClient client;
  late TusUploader uploader;

  setUp(() async {
    client = TusClient(Uri.parse('http://master.tus.io/files/'));
    uploader = await client.createUploader(file: File('./LICENSE'));
  });

  test('Get uploader URL', () async {
    expect(uploader.url.toString(), startsWith(client.endpoint.toString()));
  });
}
