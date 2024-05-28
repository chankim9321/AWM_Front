import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/APIs/backend_server.dart';

class MarkerModel{
  final double latitude;
  final double longitude;
  final String category;
  final int locationId;
  final int visitCount;
  MarkerModel({
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.visitCount,
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json){
    return MarkerModel(
        locationId: json['locationId'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        category: json['category'],
        visitCount: json['visitCount']
    );
  }

  Map<String, dynamic> toJson(){
    return {
        'locationId': locationId,
        'latitude' : latitude,
        'longitude' : longitude,
        'category' : category,
        'visitCount' : visitCount
    };
  }
  // JSON List를 Marker Model리스트로 변환하는 메서드
  static List<MarkerModel> fromJsonList(List<dynamic> jsonList) {
    List<MarkerModel> result = [];
    for (var json in jsonList) {
      result.add(MarkerModel.fromJson(json));
    }
    print("마커갯수: ${result.length} ");
    return result;
  }
  static Future<List<MarkerModel>> fetchMarkers(double latitude, double longitude, double maxRange, double minRange) async {
    print(ServerConf.url);
    final response = await http.get(Uri.parse("http://${ServerConf.url}/location/search/within-range?latitude=$latitude&longitude=$longitude&range=$maxRange&minRange=$minRange"));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      print("marker 리스트를 불러왔습니다.\n");
      return MarkerModel.fromJsonList(jsonData);
    } else {
      throw Exception('Failed to load markers');
    }
  }
}


