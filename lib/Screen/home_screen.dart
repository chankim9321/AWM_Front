import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:typed_data';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_marker.dart';
import 'package:mapdesign_flutter/APIs/UserAPIs/user_profile.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/Screen/home_drawer/home_drawer.dart';
import 'package:mapdesign_flutter/Screen/location_category.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/components/MapMarker/custom_marker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';

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
  List<CircleMarker> circles = [];
  double zoom = 15.0;
  List<MarkerModel> markerList = [];
  List<double> radius = [0, 200, 400, 600, 800, 1000];
  int radiusIndex = 2;
  List<Uint8List> profileImage = [];
  String? token;
  String imagePath = "asset/img/default_profile.jpeg";

  Future<void> _saveProfileImage() async {
    if(_isTokenAvailable()){
      try{
        if (token != null){
          var data = await UserProfile.getUserProfile();
          profileImage = data['profile'];

          imagePath = "asset/img/user_profile.png";
          File imageFile = File(imagePath);
          await imageFile.writeAsBytes(profileImage[0]);
        }
      }catch(e){
        profileImage = [];
      }
    }
  }
  Future<void> _initializeAsync() async {
    await _setToken(); // _setToken()이 완료될 때까지 기다림
    await _saveProfileImage();
  }

  Future<void> _setToken() async {
    token = await SecureStorage().readSecureData('token');
  }
  bool _isTokenAvailable() {
    if(token != null){
      return true;
    }
    return false;
  }
  void increaseRadiusIndex(){
    setState(() {
      if(radiusIndex < radius.length - 1){
        radiusIndex++;
        loadMarkerList();
      }
    });
  }
  void decreaseRadiusIndex(){
    setState(() {
      if(radiusIndex > 2){
        radiusIndex--;
        markerList.clear();
        loadMarkerList();
      }
    });
  }

  late final mapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
    _initializeAsync();
  }
  void setFocusOnCurrentLocation(){
    mapController.animateTo(dest: currentLocation!);
    setState(() {
      highlightMarker = true; // 마커를 강조
    });
    // getMarkerInfoFromServer();
  }
  Future<void> getCurrentLocation() async{
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
    });
    setFocusOnCurrentLocation();
  }
  void setShowAimPoint(){
    setState(() {
      toggleAimPoint = !toggleAimPoint;
    });
  }
  getCoordinates() {
    var center = mapController.mapController.camera.center; // 지도의 중앙 위치 가져오기
    print(center.latitude);
    print(center.longitude);
  }
  void loadMarkerList() async{
    try{
      markerList = await MarkerModel.fetchMarkers(
          currentLocation!.latitude,
          currentLocation!.longitude,
          radius[radiusIndex],
          radius[radiusIndex-2],
      );
    }catch(e){
      // CustomDialog.showCustomDialog(context, "위치 불러오기", "위치정보를 불러오는데 실패했습니다! 네트워크 상태를 확인해주세요.");
    }
    for (var element in markerList) {
      print(element.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 마커 요청
    loadMarkerList();
    // 바인딩 할 마커 리스트 변수
    var markers = <Marker>[];
    if(currentLocation != null){
      markers.add(
        // current position
        Marker(
            point: currentLocation!,
            width: 60,
            height: 60,
            child: CustomMarkerIcon(
              longitude: currentLocation!.longitude,
              latitude: currentLocation!.latitude,
              isPlace: false,
              imagePath: imagePath,
              size: Size(400.0, 400.0),
            ),
        ),
      );
      for (var element in markerList) {
        markers.add(
          Marker(
            point: latLng.LatLng(element.latitude, element.longitude),
            width: 60,
            height: 60,
            child: CustomMarkerIcon(
              latitude: element.latitude,
              longitude: element.longitude,
              category: element.category,
              isPlace: true,
              imagePath: LocationCategoryPath.categoryPath[element.category]!,
              size: Size(400, 400),
            )
          )
        );
      }

    }
    var appBar = AppBar(
      title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5)
        ),
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
              initialCenter: currentLocation ?? latLng.LatLng(51.509364, -0.128928),
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
             onPressed: () {
               setShowAimPoint();
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
                   return LocationCategory(
                       latitude: mapController.mapController.camera.center.latitude,
                       longitude: mapController.mapController.camera.center.longitude,
                   ); // Your custom widget
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
             onPressed: () {
               mapController.animatedZoomOut();
               increaseRadiusIndex();
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
             onPressed: () {
               mapController.animatedZoomIn();
               decreaseRadiusIndex();
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

