import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
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
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen>{
  final storage = FlutterSecureStorage();
  late Position currentLocation;
  bool highlightMarker = false;
  bool toggleAimPoint = false;
  double zoom = 15.0;
  List<MarkerModel> markerList = [];
  List<double> radius = [0, 200, 400, 600, 800, 1000];
  int radiusIndex = 2;
  String? token;
  String imagePath = "asset/img/default_profile.jpeg";

  Set<Marker> markers = {};
  GoogleMapController? _mapController;
  LatLng? _currentCameraPosition;


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
  Future<void> _addUserIcon() async{
    BitmapDescriptor icon;
    if(UserInfo.profileImage.isEmpty){
      // 로그인 하지 않았을 때
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
    loadMarkerList();
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
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(0.0, 0.0),
                zoom: 20.0,
              ),
              mapType: MapType.normal,
              // 스타일 적용
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              markers: markers,
            ),
            if (toggleAimPoint) // toggleAimPoint 상태에 따라 아이콘 표시 여부 결정
              Positioned(
                top: (availableHeight - 130) / 2, // 아이콘의 높이를 고려하여 중앙 정렬
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
                onPressed: () async {
                  // 현재 카메라 위치 출력
                  await _goToCurrentLocation();
                },
                child: Icon(Icons.location_on),
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
                        latitude: _currentCameraPosition!.latitude,
                        longitude: _currentCameraPosition!.longitude,
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
                  _zoomOut();
                  setState(() {
                    loadMarkerList();
                    _addLocationMarker();
                  });
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
                    _zoomIn();
                    setState(() {
                      loadMarkerList();
                      _addLocationMarker();
                    });
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

