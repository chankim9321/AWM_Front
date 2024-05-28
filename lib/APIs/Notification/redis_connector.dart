import 'package:redis/redis.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'device_id_creator.dart';

class RedisClient {
  final _redis = RedisConnection();

  final int _redisPort = 27686;
  final deviceId = DeviceIDCreator();

  Future<void> saveUserLocation(String latitude, String longitude) async {

    // 레디스 클라이언트 생성
    final redisConnection = RedisConnection();
    Command redisClient;

    try {
      redisClient = await _redis.connect(_redisAddr, _redisPort);
      print('Connected to Redis');

      // 유저 위치 정보를 Redis에 저장
      final value = deviceId.getDeviceId();
      final key = '$latitude,$longitude';
      await redisClient.send_object(['SET', key, value]);

      print('User location saved to Redis: $key -> $value');
    } catch (e) {
      print('Failed to connect to Redis: $e');
    } finally {
      // Redis 연결 종료
      await redisConnection.close();
    }
  }
}