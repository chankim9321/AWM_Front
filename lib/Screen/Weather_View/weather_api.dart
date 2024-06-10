import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:mapdesign_flutter/APIs/Notification/redis_connector.dart';

class Weather {
  String? weather;
  double? temp;
  double? tempMax;
  double? tempMin;
  int? humidity;
  double? windSpeed;
  double? feelsLike;

  Weather({
    this.weather,
    this.temp,
    this.tempMax,
    this.tempMin,
    this.humidity,
    this.feelsLike,
  });
}

class OpenWeatherForecast{
  late double latitude;
  late double longitude;
  final String APIKey = "1365a286333e7eeab98565dc94a6eb55";
  final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  static final OpenWeatherForecast _instance = OpenWeatherForecast._insternal();
  factory OpenWeatherForecast() => _instance;
  OpenWeatherForecast._insternal();

  final _redisClient = RedisClient();

  void _setCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude;
    longitude = position.longitude;
  }
  Future<String> getTopWeather() async {
    return _redisClient.getTopWeather(latitude, longitude);
  }
  Future<void> saveLocalWeather(String weather) async{
    _redisClient.saveLocalWeather(latitude, longitude, weather);
  }
  Future getWeatherData() async {
    _setCurrentLocation();
    http.Response response = await http.get(Uri.parse("$baseUrl?lat=$latitude&lon=$longitude&appid=$APIKey&units=metric"));

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }else{
      print("Error${response.statusCode}");
    }
  }
}
class WeatherProvider {
  final Weather _weather = Weather(temp: 20, humidity: 50);
  Weather get weather => _weather;

  final OpenWeatherForecast _openWeatherService = OpenWeatherForecast();

  Future<void> setWeather() async {
    final weatherData = await _openWeatherService.getWeatherData();
    final weatherString = await _openWeatherService.getTopWeather();
    if(weather == null) {
      print("weather string null");
      weather.weather = "sunny";
    }else{
      print("weather string not null");
      weather.weather = weatherString;
      print(weatherString);
    }
    if (weatherData == null) {
      print("weather data null");

      weather.humidity = 0;
      weather.temp = 0.0;
      weather.windSpeed = 0.0;
      weather.feelsLike = 0.0;
    } else {

      weather.humidity = weatherData['main']['humidity'];
      weather.temp = weatherData['main']['temp'];
      weather.temp = (weather.temp! * 10).roundToDouble() / 10;
      weather.feelsLike = weatherData['main']['feels_like'];
      weather.feelsLike = (weather.feelsLike! * 10).roundToDouble() / 10;
      weather.windSpeed = weatherData['wind']['speed'];
    }
  }
}