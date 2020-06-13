import 'package:tus_client/tus_client.dart';

void main() {
  var client = TusClient(Uri.parse('http://localhost:1080/files/'));
}
