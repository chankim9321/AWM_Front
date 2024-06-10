import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapdesign_flutter/APIs/Notification/redis_connector.dart';
import 'package:mapdesign_flutter/components/app_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';

class WeatherSelectionScreen extends StatefulWidget {
  @override
  _WeatherSelectionScreenState createState() => _WeatherSelectionScreenState();
}

class _WeatherSelectionScreenState extends State<WeatherSelectionScreen> {
  GoogleMapController? mapController;
  String selectedWeather = "None";
  LatLng? _currentPosition;
  String _currentWeather = "None";
  Map<String, String> weatherData = {
    "맑음": "Sunny",
    "비": "Rainy",
    "흐림": "Cloudy",
    "눈": "Snowy",
    "황사": "Dusty",
    "안개": "Foggy",
    "번개": "Thunder",
    "폭우": "HeavyRain"
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  String _getWeatherDataKeyFromMap(String weatherValue){
    String resultKey = "None";
    weatherData.forEach((key, value) {
      if(value == weatherValue){
        resultKey = key;
      }
    });
    return resultKey;
  }
  void _setCurrentWeather() async {
    if (_currentPosition != null) {
      var redisClient = RedisClient();
      String? weather = await redisClient.getTopWeather(
          _currentPosition!.latitude, _currentPosition!.longitude);
      setState(() {
        _currentWeather = weather ?? "None";
      });
    }
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _setCurrentWeather();
    mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    controller.setMapStyle(
        '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
  }

  void _selectWeather(String weather) {
    setState(() {
      selectedWeather = weather;
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _confirm() {
    if (selectedWeather == "None") {
      CustomDialog.showCustomDialog(context, "날씨 선택", "날씨를 먼저 선택해주세요!");
    } else {
      // Redis에 데이터 갱신
      var _redisClient = RedisClient();
      _redisClient.saveLocalWeather(_currentPosition!.latitude,
          _currentPosition!.longitude, weatherData[selectedWeather]!);
      CustomDialog.showCustomDialog(
          context, "날씨 선택", "날씨 투표가 성공적으로 갱신되었습니다!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double circleLatitude = _currentPosition?.latitude ?? 0;
    double circleLongitude = _currentPosition?.longitude ?? 0;
    circleLatitude = double.parse(circleLatitude.toStringAsFixed(2));
    circleLongitude = double.parse(circleLongitude.toStringAsFixed(2));
    LatLng circlePos = LatLng(circleLatitude, circleLongitude);
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text: "날씨 선택",
          fontSize: 20.0,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              trafficEnabled: true,
              indoorViewEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14.0,
              ),
              circles: {
                Circle(
                  circleId: CircleId("radius_circle"),
                  center: circlePos,
                  radius: 1000,
                  fillColor: Colors.blue.withOpacity(0.2),
                  strokeColor: Colors.blue.withOpacity(0.5),
                  strokeWidth: 2,
                ),
              },
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: _currentWeather == "None"
                ? Center(child: CircularProgressIndicator())
                : Container(
              key: ValueKey<String>(_currentWeather),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "현재날씨는 '${_getWeatherDataKeyFromMap(_currentWeather)}' 추정됩니다.",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'PretendardThin'
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _weatherButton('맑음', FontAwesomeIcons.sun),
                _weatherButton('비', FontAwesomeIcons.cloudRain),
                _weatherButton('흐림', FontAwesomeIcons.cloud),
                _weatherButton('눈', FontAwesomeIcons.snowflake),
                _weatherButton('황사', FontAwesomeIcons.industry),
                _weatherButton('안개', FontAwesomeIcons.smog),
                _weatherButton('번개', FontAwesomeIcons.cloudBolt),
                _weatherButton('폭우', FontAwesomeIcons.cloudShowersHeavy),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: AppText(
                      text: "Confirm",
                      fontSize: 15,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherButton(String weather, IconData icon) {
    return GestureDetector(
      onTap: () => _selectWeather(weather),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 50,
            color: selectedWeather == weather ? Colors.blue : Colors.grey,
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Text(
            weather,
            style: TextStyle(
              color: selectedWeather == weather ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
