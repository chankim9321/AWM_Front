import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool choolCheckDone = false;
  GoogleMapController? mapController;

  static final LatLng kmLatLng = LatLng(
    35.8588,
    128.4874,
  );
  static final CameraPosition initialPosition = CameraPosition(
    target: kmLatLng,
    zoom: 16,
  );
  static final double okDistance = 10;
  static final Circle withinDistanceCircle = Circle(
    circleId: CircleId('withinDistanceCircle'),
    center: kmLatLng,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: okDistance,
    strokeColor: Color(0xff235FD9),
    strokeWidth: 1,
  );
  static final Circle notwithinDistanceCircle = Circle(
    circleId: CircleId('notwithinDistanceCircle'),
    center: kmLatLng,
    fillColor: Colors.red.withOpacity(0.5),
    radius: okDistance,
    strokeColor: Color(0xffF20505),
    strokeWidth: 1,
  );

  static final Marker marker = Marker(
    markerId: MarkerId('marker'),
    position: kmLatLng,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: FutureBuilder<String>(
        future: checkPermission(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == '위치 권한을 허가되었습니다.') {
            return StreamBuilder<Position>(
              stream: Geolocator.getPositionStream(),
              builder: (context, snapshot) {
                bool isWithinRange = false;

                if (snapshot.hasData) {
                  final start = snapshot.data!;
                  final end = kmLatLng;

                  final distance = Geolocator.distanceBetween(
                    start.latitude,
                    start.longitude,
                    end.latitude,
                    end.longitude,
                  );

                  if (distance < okDistance) {
                    isWithinRange = true;
                  }
                }

                return Column(
                  children: [
                    _CustomGoogleMap(
                      initialPosition: initialPosition,
                      circle: isWithinRange
                          ? withinDistanceCircle
                          : notwithinDistanceCircle,
                      marker: marker,
                      onMapCreated: onMapCreated,
                    ),
                  ],
                );
              },
            );
          }

          return Center(
            child: Text(snapshot.data),
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('asset/img/poke.jpg'),
                backgroundColor: Color(0xffDfE4F2),
              ),
              accountName: Text('Shin'),
              accountEmail: Text('leo2120@naver.com'),
              onDetailsPressed: () {
                print('확장');
              },
              decoration: BoxDecoration(
                color: Color(0xff044BD9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Color(0xff235FD9),
              ),
              title: Text('프로필'),
              onTap: (){
                print('프로필 클릭');
              },
              trailing: Icon(Icons.arrow_forward),
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Color(0xff235FD9),
              ),
              title: Text('설정'),
              onTap: (){
                print('설정 클릭');
              },
              trailing: Icon(Icons.arrow_forward),
            ),
            ListTile(
              leading: Icon(
                Icons.question_answer,
                color: Color(0xff235FD9),
              ),
              title: Text('메세지'),
              onTap: (){
                print('메세지 클릭');
              },
              trailing: Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      return '위치 서비스를 활성화 해주세요.';
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해 주세요.';
      }
    }
    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 세팅에서 허가해 주세요.';
    }
    return '위치 권한을 허가되었습니다.';
  }

  AppBar renderAppBar() {
    return AppBar(
      title: Text(
        'AWM',
        style: TextStyle(
          color: Color(0xff044BD9),
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Color(0xffDFE4F2),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () async {
            if (mapController == null) {
              return;
            }

            final location = await Geolocator.getCurrentPosition();

            mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                  location.latitude,
                  location.longitude,
                ),
              ),
            );
          },
          color: Color(0xff044BD9),
          icon: Icon(
            Icons.my_location,
          ),
        ),
        IconButton(
          onPressed: () {
            print('검색');
          },
          icon: Icon(Icons.search),
          color: Color(0xff044BD9),
        ),
      ],
    );
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final CameraPosition initialPosition;
  final Circle circle;
  final Marker marker;
  final MapCreatedCallback onMapCreated;

  const _CustomGoogleMap({
    required this.initialPosition,
    required this.circle,
    required this.marker,
    required this.onMapCreated,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        circles: Set.from([circle]),
        markers: Set.from([marker]),
        onMapCreated: onMapCreated,
      ),
    );
  }
}
