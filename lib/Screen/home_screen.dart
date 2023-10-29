
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:mapdesign_flutter/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[];
    if(currentLocation != null){
      markers.add(
        // current position
        Marker(
            point: currentLocation!,
            width: 40,
            height: 40,
            child: Icon(
              Icons.location_on,
              color: AppColors.instance.red,
              size: 40,
            ),
        ),
      );

      // 이후 API 요청을 하여 주변 근처 위치를 탐색
      // markers.add()
    }
    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: AppColors.instance.whiteGrey,
      ),
      drawer: Drawer(

      ),
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
          if(toggleAimPoint)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 24, // 24 is half the size of the icon
              left: MediaQuery.of(context).size.width / 2 - 24,
              child: Icon(
                Icons.add,
                size: 48, // You can adjust the size here
                color: AppColors.instance.red,
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
               getCoordinates()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.add_location,
               color: AppColors.instance.white,
             ),
           ),
         )
       ],
      )
    );
  }
}

