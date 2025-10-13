import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  static const _s = FlutterSecureStorage();
  static Future<void> saveToken(String t) => _s.write(key: 'token', value: t);
  static Future<String?> get token => _s.read(key: 'token');
  static Future<void> clear() => _s.deleteAll();
}
