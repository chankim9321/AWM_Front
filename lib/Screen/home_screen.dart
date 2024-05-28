import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:mapdesign_flutter/user_info.dart';
import 'package:path_provider/path_provider.dart';

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
  double zoom = 15.0;
  List<MarkerModel> markerList = [];
  List<double> radius = [0, 200, 400, 600, 800, 1000];
  int radiusIndex = 2;
  String? token;
  String imagePath = "asset/img/default_profile.jpeg";


  Future<void> _saveProfileImage() async {
    try{
      var data = await UserProfile.getUserProfile();
      UserInfo.userNickname = data['nickName'];
      UserInfo.profileImage = data['image'];
    }catch(e){ // 존재하지 않을 때
      print("failed to load data");
      UserInfo.userNickname = "익명의 유저";
      UserInfo.profileImage = Uint8List(0);
    }
  }
  Future<void> _initializeAsync() async {
    await _setToken(); // _setToken()이 완료될 때까지 기다림
    await _saveProfileImage(); // 유저 프로필
  }
  Future<void> _setToken() async {
    token = await SecureStorage().readSecureData('token');
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
            width: 40,
            height: 40,
            child: CustomMarkerIcon(
              longitude: currentLocation!.longitude,
              latitude: currentLocation!.latitude,
              isPlace: false,
              imagePath: UserInfo.profileImage.isEmpty
                ? imagePath
                : "",
              imageData: UserInfo.profileImage, // 로그인 안하면 빈 배열 반환
              size: Size(400.0, 400.0),
            ),
        ),
      );
      for (var element in markerList) {
        markers.add(
          Marker(
            point: latLng.LatLng(element.latitude, element.longitude),
            width: 40,
            height: 40,
            child: CustomMarkerIcon(
              latitude: element.latitude,
              longitude: element.longitude,
              category: element.category,
              isPlace: true,
              imageData: UserInfo.profileImage,
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
                userAgentPackageName: 'com.example.mapdesign_flutter',
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
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white, // 아이콘 배경색
                  shape: BoxShape.circle, // 원형 아이콘
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // 그림자 색상
                      spreadRadius: 2, // 그림자의 확산 반경
                      blurRadius: 6, // 그림자의 흐림 반경
                      offset: Offset(0, 4), // 그림자의 위치
                    ),
                  ],
                ),
                child: Icon(
                  shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 1.0)],
                  Icons.add_location,
                  size: 40, // 아이콘 크기
                  color: Colors.blue, // 아이콘 색상
                ),
              ),
            )
        ],
      ),
    );
  }
}

