import 'package:uuid/uuid.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';

class DeviceIDCreator{
  late final Uuid _uuid;
  late final String deviceId;
  DeviceIDCreator(){
    try {
      deviceId = _getDeviceIdFromSecureStorage() as String;
    }
    catch(e) {
      print("[DeviceID] Device ID 새로 생성");
      _uuid = Uuid();
      deviceId = _uuid.v4();
      _setDeviceID();
    }
  }
  String getDeviceId(){
    return deviceId;
  }
  Future<String?> _getDeviceIdFromSecureStorage() async {
    String? _deviceId = await SecureStorage().readSecureData("device_id");
    return _deviceId;
  }
  Future<void> _setDeviceID() async {
    await SecureStorage().writeSecureData("device_id", deviceId);
  }
}