import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/Screen/home_drawer/home_drawer.dart';
import 'package:mapdesign_flutter/Screen/location_category.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/components/MapMarker/custom_marker.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final storage = FlutterSecureStorage();
  latLng.LatLng? currentLocation;
  bool highlightMarker = false;
  bool toggleAimPoint = false;
  late final mapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
  );
  List<CircleMarker> circles = [];

  double zoom = 15.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationData();
  }
  void setFocusOnCurrentLocation(){
    mapController.animateTo(dest: currentLocation!);
    setState(() {
      highlightMarker = true; // 마커를 강조
    });
    getMarkerInfoFromServer();
  }
  Future<void> getLocationData() async{
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // 위치 서비스가 비활성화된 경우 추가 작업을 수행하지 않음
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return; // 권한이 거부된 경우 추가 작업을 수행하지 않음
      }
    }
    final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      currentLocation = latLng.LatLng(position.latitude, position.longitude);
      circles.add(
        CircleMarker(
            point: currentLocation!,
            color: Colors.blue.withOpacity(0.1),
            borderColor: Colors.blue.withOpacity(0.1),
            borderStrokeWidth: 2,
            useRadiusInMeter: true,  // 미터 단위 사용
            radius: 300  //
        ),
      );
    });
    setFocusOnCurrentLocation();
  }
  void setShowAimPoint(){
    setState(() {
      toggleAimPoint = !toggleAimPoint;
    });
  }
  void getCoordinates() {
    var center = mapController.mapController.camera.center; // 지도의 중앙 위치 가져오기
    print(center.latitude);
    print(center.longitude);
  }
  Future<String> getToken() async{
    return await storage.read(key: 'token') ?? '';
  }
  void getMarkerInfoFromServer() async{
    try{
      final latitude = currentLocation!.latitude.toDouble();
      final longitude = currentLocation!.longitude.toDouble();
      print(latitude);
      print(longitude);
      final range = 1000;
      // final token = await getToken();
      final response = await http.get(
          Uri.parse('http://172.20.10.6:8080/location/search/nearby?latitude=$latitude&longitude=$longitude&range=1000'),
          headers: <String, String>{
            'Content-Type' : 'application/json',
          }
      );
      print('성공');
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[];
    if(currentLocation != null){
      // 디버깅 전용 마커
      // if(toggleAimPoint){
      //   markers.add(
      //     Marker(
      //       point: mapController.mapController.camera.center,
      //       width: 60,
      //       height: 60,
      //         child: Icon(
      //           Icons.add_location,
      //           color: AppColors.instance.red,
      //           size: 60,
      //         ),
      //     )
      //   );
      // }
      markers.add(
        // current position
        Marker(
            point: currentLocation!,
            width: 60,
            height: 60,
            child: CustomMarkerIcon(
              isPlace: false,
              imagePath: "asset/img/pepe.webp",
              size: Size(400.0, 400.0),
            ),
        ),
      );
      // test
      markers.add(
        Marker(
            point: latLng.LatLng(35.85836750155731, 128.48694463271696),
            width: 60,
            height: 60,
            child: CustomMarkerIcon(
              isPlace: true,
              imagePath: "asset/img/bombom.jpg",
              size: Size(400.0, 400.0),
            )
        )
      );

      // 이후 API 요청을 하여 주변 근처 위치를 탐색
      // markers.add()
    }
    var appBar = AppBar(
      title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: TextField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.instance.skyBlue,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  /* Clear the search field */
                },
                color: AppColors.instance.skyBlue,
              ),
              hintText: 'Search & Explore',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.instance.skyBlue,
    );
    var appBarHeight = appBar.preferredSize.height;
    final availableHeight = MediaQuery.of(context).size.height - appBarHeight - MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      drawer: HomeDrawer(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController.mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? latLng.LatLng(0,0),
              initialZoom: zoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              CircleLayer(
                circles: circles,
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
          if (toggleAimPoint) // toggleAimPoint 상태에 따라 아이콘 표시 여부 결정
            Positioned(
              top: (availableHeight - 60) / 2, // 아이콘의 높이를 고려하여 중앙 정렬
              left: MediaQuery.of(context).size.width / 2 - 30, // 아이콘의 너비를 고려하여 중앙 정렬
              child: Icon(
                Icons.add_location,
                size: 60,
                color: AppColors.instance.skyBlue,
              ),
            ),
        ],
      ),
      floatingActionButton: Stack(
       children: [
         Positioned(
           bottom: 10.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               setFocusOnCurrentLocation()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.my_location,
               color: AppColors.instance.white,
             ),
           ),
         ),
         Positioned(
           bottom: 80.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               setShowAimPoint()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               toggleAimPoint ? Icons.close : Icons.add,
               color: AppColors.instance.white,
             ),
           ),
         ),
         Positioned(
           bottom: 150.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               showModalBottomSheet(
                 context: context,
                 builder: (BuildContext context) {
                   return LocationCategory(); // Your custom widget
                 },
               )
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.add_location,
               color: AppColors.instance.white,
             ),
           ),
         ),
         Positioned(
           bottom: 220.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               mapController.animatedZoomOut()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.remove,
               color: AppColors.instance.white,
             ),
          ),
         ),
         Positioned(
           bottom: 290.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               mapController.animatedZoomIn()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.add,
               color: AppColors.instance.white,
             ),
           )
         )
       ],
      )
    );
  }
}

