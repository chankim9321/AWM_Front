import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/APIs/backend_server.dart';

class MarkerModel{
  final double latitude;
  final double longitude;
  final String category;

  MarkerModel({
    required this.latitude,
    required this.longitude,
    required this.category
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json){
    return MarkerModel(
        latitude: json['latitude'],
        longitude: json['longitude'],
        category: json['category']
    );
  }

  Map<String, dynamic> toJson(){
    return {
        'latitude' : latitude,
        'longitude' : longitude,
        'category' : category
    };
  }
  // JSON List를 Marker Model리스트로 변환하는 메서드
  static List<MarkerModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MarkerModel.fromJson(json)).toList();
  }

  static Future<List<MarkerModel>> fetchMarkers(double maxRange, double minRange) async {
    final response = await http.get(Uri.parse("${ServerConf.url}API"));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return MarkerModel.fromJsonList(jsonData);
    } else {
      throw Exception('Failed to load markers');
    }
  }
}


