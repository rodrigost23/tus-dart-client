import 'dart:io';

abstract class TusUploaderBase {
  final File file;

  Future<void> upload();

  TusUploaderBase({required this.file});
}
