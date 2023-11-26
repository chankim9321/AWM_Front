import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
class SecureStorage{
  SecureStorage._privateContructor();

  static final SecureStorage _instance = SecureStorage._privateContructor();

  factory SecureStorage(){
    return _instance;
  }
  // contructor
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> writeSecureData(String key, String value) async {
    await storage.write(key: key, value: value);
  }
  Future<String?> readSecureData(String key, String value) async {
    return await storage.read(key: key);
  }
  Future<void> deleteSecureData(String key, String value) async{
    await storage.delete(key: key);
  }
}