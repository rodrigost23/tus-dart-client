import 'dart:convert';
import 'dart:io';

import 'package:tus_client/tus_client.dart';
import 'package:test/test.dart';

void main() {
  late TusClient client;
  late TusUploader uploader;
  final url = Uri.http('master.tus.io', '/files/');

  group('No resume support', () {
    setUp(() async {
      client = TusClient(url);
      uploader = await client.createUploader(file: File('./LICENSE'));
    });

    test('Get uploader URL', () async {
      expect(uploader.url.toString(), startsWith(client.endpoint.toString()));
    });

    test('Upload whole file', () async {
      await uploader.upload();
    });
  });

  group('With resume support', () {
    late TusUploader uploader2;
    final store = TusMemoryStore();

    setUp(() async {
      client = TusClient(url, store: store, chunkSize: 256);
      uploader = await client.createUploader(file: File('./LICENSE'));
      uploader2 = await client.createUploader(file: File('./LICENSE'));
    });

    test('Store saved the URL', () async {
      expect(store.get(uploader.fingerprint), equals(uploader.url));
    });

    test('Second uploader has the same URL as the first', () async {
      expect(uploader2.url, equals(uploader.url));
    });

    test('Second uploader resumes download from the first', () async {
      await uploader.uploadChunk();
      await uploader2.upload();

      print('Finished upload');

      var request = await HttpClient().getUrl(uploader2.url);
      var response = await request.close();

      print('Finished download');

      var downloaded = await response.transform(utf8.decoder).single;
      expect(downloaded, uploader2.file.readAsStringSync());
    });

    test('Invalid URL from store results in different URL', () async {
      var wrongUrl = url.resolve('123456');

      store.set(uploader.fingerprint, wrongUrl);

      uploader = await client.createUploader(file: File('./LICENSE'));

      expect(uploader.url, isNot(equals(wrongUrl)));
    });
  });
}
