import 'tus_store.dart';

class TusMemoryStore extends TusStore {
  Map<String, Uri> store = <String, Uri>{};

  @override
  void set(String fingerprint, Uri url) => store[fingerprint] = url;

  @override
  Uri get(String fingerprint) => store[fingerprint];

  @override
  void remove(String fingerprint) => store.remove(fingerprint);
}
