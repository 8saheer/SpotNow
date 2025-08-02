import 'dart:io';

class AppConfig {
  static String get baseUrl {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://192.168.2.25:5000/api/';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'https://localhost:5001/api/';
    }
    throw UnsupportedError("Unsupported platform");
  }
}
