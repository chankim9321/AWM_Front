import 'package:uuid/uuid.dart';

class DeviceIDCreator{
  final Uuid _uuid = Uuid();

  String getDeviceId(){
    return _uuid.v4();
  }
}