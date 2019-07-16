import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

// minimal class for providing a storage prefix for caches
// if used in flutter for mobile devices
class plattformStorage {
  static Future<String> prefix() async {
    return (await getApplicationDocumentsDirectory()).path;
  }
}