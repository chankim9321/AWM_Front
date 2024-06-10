import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mapdesign_flutter/APIs/Notification/redis_connector.dart';
import 'package:mapdesign_flutter/Screen/Weather_View/weather_api.dart';
import 'package:mapdesign_flutter/Screen/Weather_View/weather_decorated_icon.dart';

class WeatherBackgroundPage extends StatefulWidget {
  const WeatherBackgroundPage({super.key});

  @override
  State<WeatherBackgroundPage> createState() => _WeatherBackgroundPageState();
}

class _WeatherBackgroundPageState extends State<WeatherBackgroundPage> with TickerProviderStateMixin {
  final WeatherProvider _weatherProvider = WeatherProvider();
  late Future<void> _weatherFuture;
  late AnimationController _controller;
  late Animation<double> _animation;

  // 날씨 아이콘
  Map<String, Widget> weatherIcon = {
    'rainy': DecoratedRainyIcon(icon: FontAwesomeIcons.cloudRain, size: 120),
    'rainynight': DecoratedRainyIcon(icon: FontAwesomeIcons.cloudRain, size: 120),
    'sunny': DecoratedSunnyIcon(icon: Icons.sunny, size: 120),
    'sunnynight' : DecoratedMoonIcon(icon: FontAwesomeIcons.moon, size: 120),
    'cloudy': DecoratedCloudIcon(icon: FontAwesomeIcons.cloud, size: 120),
    'cloudnight': DecoratedCloudIcon(icon: FontAwesomeIcons.cloud, size: 120),
    'snowy': DecoratedSnowflakeIcon(icon: FontAwesomeIcons.snowflake, size: 120),
    'snowynight': DecoratedSnowflakeIcon(icon: FontAwesomeIcons.snowflake, size: 120),
    'dusty': DecoratedDustyIcon(icon: FontAwesomeIcons.industry, size: 120),
    'dustynight': DecoratedDustyIcon(icon: FontAwesomeIcons.industry, size: 120),
    'foggy': DecoratedSmogIcon(icon: FontAwesomeIcons.smog, size: 120),
    'foggynight': DecoratedSmogIcon(icon: FontAwesomeIcons.smog, size: 120),
    'thunder': DecoratedThunderIcon(icon: FontAwesomeIcons.cloudBolt, size: 120),
    'thundernight': DecoratedThunderIcon(icon: FontAwesomeIcons.cloudBolt, size: 120),
    'heavyrain': DecoratedCloudShowerHeavyIcon(icon: FontAwesomeIcons.cloudShowersHeavy, size: 120),
    'heavyrainnight': DecoratedCloudShowerHeavyIcon(icon: FontAwesomeIcons.cloudShowersHeavy, size: 120),
  };

  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherProvider.setWeather();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isNight() {
    final now = TimeOfDay.now();
    return now.hour >= 18 || now.hour < 6;
  }

  WeatherType getWeatherType(String weather, bool isNight) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return isNight ? WeatherType.sunnyNight : WeatherType.sunny;
      case 'rainy':
        return WeatherType.lightRainy;
      case 'cloudy':
        return isNight ? WeatherType.cloudyNight : WeatherType.overcast;
      case 'snowy':
        return WeatherType.middleSnow;
      case 'dusty':
        return WeatherType.dusty;
      case 'foggy':
        return WeatherType.foggy;
      case 'thunder':
        return WeatherType.thunder;
      case 'heavyrain':
        return WeatherType.heavyRainy;
      default:
        throw Exception('Unknown weather type: $weather');
    }
  }
  Widget buildWeatherInfoBox(String title, String value, IconData icon) {
    return Container(
      width: 80,
      height: 80,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 50),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'PretendardThin'),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'PretendardThin'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FutureBuilder<void>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print("[Weather View] Error: ${snapshot.error}");
                  return Center(child: Text('Error loading weather'));
                } else {
                  _controller.forward();
                  return FadeTransition(
                    opacity: _animation,
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: WeatherBg(
                            weatherType: getWeatherType(_weatherProvider.weather.weather!, isNight()),
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'WEATHER',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontFamily: 'PretendardExtraLight',
                              ),
                            ),
                            SizedBox(height: 20),
                            isNight() ?
                            weatherIcon["${_weatherProvider.weather.weather!.toLowerCase()}night"] ?? SizedBox() :
                            weatherIcon[_weatherProvider.weather.weather!.toLowerCase()] ?? SizedBox(),
                            SizedBox(height: 20),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              padding: EdgeInsets.all(20.0),
                              children: [
                                buildWeatherInfoBox('기온', '${_weatherProvider.weather.temp}°C', FontAwesomeIcons.temperatureHalf),
                                buildWeatherInfoBox('체감', '${_weatherProvider.weather.feelsLike}°C', FontAwesomeIcons.temperatureFull),
                                buildWeatherInfoBox('습도', '${_weatherProvider.weather.humidity}%', FontAwesomeIcons.droplet),
                                buildWeatherInfoBox('바람', '${_weatherProvider.weather.windSpeed?.toInt()} m/s', FontAwesomeIcons.wind),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

