import 'dart:math';

import 'package:redis/redis.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'device_id_creator.dart';
import 'package:upstash_redis/upstash_redis.dart';


final List<String> weatherTypes = [
  'Sunny',
  'Rainy',
  'Cloudy',
  'Snowy',
  'Dusty',
  'Foggy',
  'Thunder',
  'HeavyRain'
];

class RedisClient {
  String? previousKey;
  final String url = "https://vocal-dragon-43557.upstash.io";
  final String token = "AaolAAIncDFkN2NkODRhMmFiNmM0NDg1OTBhMzY3M2NlOTI5M2EzNXAxNDM1NTc";

  Future<void> saveUserLocation(double latitude, double longitude, String deviceId) async {
    try{
      final conn = Redis(url: url, token: token);
      String roundedLat = latitude.toStringAsFixed(5);
      String roundedLong = longitude.toStringAsFixed(5);
      String presentKey = "$roundedLat,$roundedLong";
      String deviceIdStr = deviceId;
      try{
        if(previousKey != null){
          await conn.lrem(previousKey!, 0, deviceIdStr);
          print('[Redis] Previous location removed from Redis: $previousKey -> $deviceIdStr');
        }
        await conn.rpush(presentKey, [deviceIdStr]);
        print('[Redis] User location saved to Redis: $presentKey -> $deviceIdStr');
        previousKey = presentKey;
      } catch(e){
        print('[Redis Error] Failed to update to Redis: $e');
      }
      finally{
        conn.close();
        print('[Redis] Redis connection closed');
      }
    }catch(e){
      print('[Redis Error] Failed to connect to Redis: $e');
    }
  }
  Future<void> saveLocalWeather(double latitude, double longitude, String weatherString) async{
    try{
      final conn = Redis(url: url, token: token);
      String roundedLat = latitude.toStringAsFixed(2);
      String roundedLong = longitude.toStringAsFixed(2);
      String presentKey = "$roundedLat,$roundedLong";
      try{
        // 기본 값 설정
        final Map<String, int> weatherVotes = {};
        for (String weather in weatherTypes) {
          weatherVotes[weather] = 0;
        }
        final exists = await conn.exists(["weather:$presentKey"]);
        if(exists == 0){
          for(String weather in weatherTypes){
            await conn.hset('weather:$presentKey', {weather, 0} as Map<String, int>);
          }
        }
        await conn.hincrby('weather:$presentKey', weatherString, 1);
      }catch(e){
        print("[Redis Error, Weather] Failed to update to Redis: $e");
      }
      finally{
        conn.close();
        print("[Redis Weather] Redis connection closed");
      }
    }catch(e){
      print("[Redis Error, Weather] Failed to connect to Redis");
    }
  }
  Future<String> getTopWeather(double latitude, double longitude) async{
    var topWeather = "Sunny";
    try{
      final conn = Redis(url: url, token: token);
      String roundedLat = latitude.toStringAsFixed(2);
      String roundedLong = longitude.toStringAsFixed(2);
      String presentKey = "$roundedLat,$roundedLong";
      try{
        final exists = await conn.exists(["weather:$presentKey"]);
        if(exists == 0){
          // 기본 값 설정
          final Map<String, int> weatherVotes = {};
          for (String weather in weatherTypes) {
            weatherVotes[weather] = 0;
          }
          for(String weather in weatherTypes){
            await conn.hset('weather:$presentKey', {weather : 0});
          }
        }
        var result = await conn.hgetall("weather:$presentKey");
        if(result == null || result.isEmpty){
          throw Exception("No weather data found for key: $presentKey");
        }
        Map<String, int> weatherVotes = result.map((key, value) => MapEntry(key, int.parse(value.toString())));

        topWeather = weatherVotes.keys.first;
        var maxVotes = weatherVotes[topWeather] ?? 0;
        // print("first maxVotes: $maxVotes");
        weatherVotes.forEach((key, value) {
          if(value > maxVotes){
            topWeather = key;
            maxVotes = value;
          }
        });
        // print("final maxVotes: $topWeather");
      }catch(e){
        print("[Redis Error, Weather] Failed to receive from Redis: $e");
      }
      finally{
        conn.close();
        print("[Redis Weather] Redis connection closed");
      }
    }catch(e){
      print("[Redis Error, Weather] Failed to connect to Redis");
    }
    return topWeather;
  }
}