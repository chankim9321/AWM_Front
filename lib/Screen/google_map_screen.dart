import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_shadow/flutter_icon_shadow.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/user_info.dart';
import 'package:mapdesign_flutter/LocationInfo/marker_clicked.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:animated_icon/animated_icon.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen>{
  final storage = FlutterSecureStorage();
  late Position currentLocation; // 현재 위치
  bool highlightMarker = false; // 마커 하이라이트
  bool toggleAimPoint = false; // 위치 등록 시도시 에임 포인트 존재여부
  double zoom = 15.0;
  NotchBottomBarController _notchBottomBarController = NotchBottomBarController();
  List<MarkerModel> markerList = [];
  List<double> radius = [0, 200, 400, 600, 800, 1000];
  int radiusIndex = 2;
  String? token;
  String imagePath = "asset/img/default_profile.jpeg";
  // 검색창 text controller
  var searchController = TextEditingController();
  Set<Marker> markers = {};
  GoogleMapController? _mapController;
  LatLng? _currentCameraPosition;


  Future<void> _saveProfileImage() async {
    try{
      var data = await UserProfile.getUserProfile();
      UserInfo.userNickname = data['nickName']; // 유저의 닉네임을 가져옴
      UserInfo.profileImage = data['image']; // 유저의 프로필 사진
    }catch(e){ // 존재하지 않을 때
      print("failed to load data");
      UserInfo.userNickname = "익명의 유저";
      UserInfo.profileImage = Uint8List(0);
    }
  }
  Future<void> _setToken() async {
    token = await SecureStorage().readSecureData('token');
  }
  Future<void> _initializeAsync() async {
    await _setToken(); // _setToken()이 완료될 때까지 기다림
    await _saveProfileImage(); // 유저 프로필
    await _goToCurrentLocation();
    await _addUserIcon();
    await _addLocationMarker();
  }
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeAsync();
  }
  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }
  // 맵 초기 설정
  void _onMapCreated(GoogleMapController controller) {
    controller.setMapStyle('[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
    _mapController = controller;
  }
  // 현재 위치로 카메라 이동
  Future<void> _goToCurrentLocation() async {
    var currentPosition = await _determinePosition();
    currentLocation = currentPosition; // 현재 위치 기록
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 17.0,
        ),
      ),
    );
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있다면 사용자에게 활성화 요청
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 사용자가 위치 권한을 거부하면 에러 반환
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // 현재 위치 반환
    return await Geolocator.getCurrentPosition();
  }
  // 현재 카메라 위치 가져오기
  void _onCameraMove(CameraPosition position) {
    // print("camera moved! position zoom: ${position.zoom}, position target: ${position.target}");
    _currentCameraPosition = position.target;
  }
  LatLng? getCurrentCameraPosition() {
    return _currentCameraPosition;
  }
  @override
  void setShowAimPoint(){
    setState(() {
      toggleAimPoint = !toggleAimPoint;
    });
  }
  Future<void> _loadMarkerList() async{
    try{
      markerList = await MarkerModel.fetchMarkers(
        currentLocation!.latitude,
        currentLocation!.longitude,
        radius[radiusIndex],
        radius[radiusIndex-2],
      );
    }catch(e){
       CustomDialog.showCustomDialog(context, "위치 불러오기", "위치정보를 불러오는데 실패했습니다! 네트워크 상태를 확인해주세요.");
    }
  }
  void _loadMarkerListTest() async {
    try{
      markerList = await MarkerModel.fetchMarkers(
        currentLocation!.latitude,
        currentLocation!.longitude,
        radius[radiusIndex],
        radius[radiusIndex-2],
      );
    }catch(e){
      CustomDialog.showCustomDialog(context, "위치 불러오기", "위치정보를 불러오는데 실패했습니다! 네트워크 상태를 확인해주세요.");
    }
  }
  Future<void> _addUserIcon() async{
    BitmapDescriptor icon;
    if(UserInfo.profileImage.isEmpty){
      // 로그인 하지 않았을 때 기본 프로필 사진 설정
      icon = await getMarkerIcon(imagePath, UserInfo.profileImage, Size(180.0,180.0));
    }else{
      // 로그인 했을 때
      icon = await getMarkerIcon("", UserInfo.profileImage, Size(180.0,180.0));
    }
    String markerIdVal = 'marker_${currentLocation.latitude}_${currentLocation.longitude}';
    markers.add(
      Marker(
        markerId: MarkerId(markerIdVal),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        icon: icon,
      ),
    );
    setState(() {

    });
  }
  Future<void> _addLocationMarker() async{
    await _loadMarkerList();
    for (var element in markerList) {
      String markerIdVal = 'marker_${element.latitude}_${element.longitude}';
      BitmapDescriptor icon = await getMarkerIcon(LocationCategoryPath.categoryPath[element.category]!, UserInfo.profileImage, Size(180.0,180.0));
      markers.add(
          Marker(
              markerId: MarkerId(markerIdVal),
              position: LatLng(element.latitude, element.longitude),
              icon: icon,
              onTap: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context){
                      return Container(
                          height: MediaQuery.of(context).size.height,
                          child: MarkerClicked(latitude:element.latitude, longitude: element.longitude, category: element.category)
                      );
                    }
                );
              }
          )
      );
    }
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5)
        ),
        child: Center(
          child: TextField(
            controller: searchController,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10.0), // 상하 패딩 동일하게 설정
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.instance.skyBlue,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  /* Clear the search field */
                  searchController.text = "";
                  // 검색기능 추가 요망
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
            GoogleMap(
              // padding:  EdgeInsets.only(bottom: 100, left: 50),
              trafficEnabled: true,
              indoorViewEnabled: true,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(0.0, 0.0),
                zoom: 20.0,
              ),
              zoomGesturesEnabled: true,
              mapType: MapType.normal,
              // 스타일 적용
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              markers: markers,
            ),
            if (toggleAimPoint) // toggleAimPoint 상태에 따라 아이콘 표시 여부 결정
              Positioned(
                top: (availableHeight - 180) / 2, // 아이콘의 높이를 고려하여 중앙 정렬
                left: MediaQuery.of(context).size.width / 2 - 20, // 아이콘의 너비를 고려하여 중앙 정렬
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: 5.0, // 그림자를 아이콘 발 밑으로 이동
                      child: Container(
                        width: 20, // 아이콘 너비에 맞게 그림자 크기 조정
                        height: 15, // 그림자 높이를 더 작게 설정
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2), // 그림자 색상
                          borderRadius: BorderRadius.circular(50), // 그림자 모양 둥글게 설정
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 60)),
                    Icon(
                      Icons.add_location,
                      size: 40, // 아이콘 크기
                      color: Colors.blue, // 아이콘 색상
                    ),
                  ],
                ),
              )
          ],
        ),
        bottomNavigationBar: AnimatedNotchBottomBar(
          color: AppColors.instance.skyBlue,
          notchColor: AppColors.instance.skyBlue,
          notchGradient: LinearGradient(
            colors: const [Colors.blueAccent, Colors.lightBlueAccent] ,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          notchBottomBarController: _notchBottomBarController,
          onTap: (index) {
            switch(index){
              case 0:
                if(toggleAimPoint){
                  setShowAimPoint();
                }
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return LocationCategory(
                      latitude: _currentCameraPosition!.latitude,
                      longitude: _currentCameraPosition!.longitude,
                    ); // Your custom widget
                  },
                );
              case 1:
                setShowAimPoint();
                print("??");
                break;
              case 2:
                if(toggleAimPoint){
                  setShowAimPoint();
                }
                _goToCurrentLocation();
                _loadMarkerListTest();
                break;
              default:
            }
          },
          kBottomRadius: 40.0,
          kIconSize: 24.0,
          durationInMilliSeconds: 300,
          bottomBarItems: [
            BottomBarItem(
              inActiveItem: Icon(
                Icons.add_location,
                color: Colors.white,
              ),
                activeItem: AnimateIcon(
                  color: Colors.white,
                  animateIcon: AnimateIcons.map,
                  onTap: () {},
                  iconType: IconType.continueAnimation,
                )
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.add,
                color: Colors.white
              ),
              // inActiveItem: AnimateIcon(
              //   color: Colors.black,
              //   animateIcon: AnimateIcons.,
              //   onTap: () {
              //     setShowAimPoint();
              //   },
              //   iconType: IconType.continueAnimation
              // ),
              activeItem: AnimateIcon(
                color: Colors.blueAccent,
                animateIcon: AnimateIcons.add,
                onTap: () {
                  setShowAimPoint();
                },
                iconType: IconType.continueAnimation,
              )
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.location_on,
                color: Colors.white
              ),
              // inActiveItem: AnimateIcon(
              //   color: Colors.white,
              //   animateIcon: AnimateIcons.mapPointer,
              //   onTap: () {
              //     _goToCurrentLocation();
              //   },
              //   iconType: IconType.continueAnimation,
              // ),
              activeItem: AnimateIcon(
                color: Colors.white,
                animateIcon: AnimateIcons.mapPointer,
                onTap: () {
                  _goToCurrentLocation();
                },
                iconType: IconType.continueAnimation,
              )
            ),
          ],
        )
    );
  }
}

