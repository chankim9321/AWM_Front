import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/LocationInfo/LocationRecommendation/location_recommend.dart';
import 'package:mapdesign_flutter/LocationInfo/marker_clicked.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:mapdesign_flutter/Screen/google_map_screen.dart';

class Place {
  final int locationId;
  final String locationName;
  final String category;
  final double latitude;
  final double longitude;
  final String base64Image;

  Place({
    required this.locationId,
    required this.locationName,
    required this.base64Image,
    required this.category,
    required this.latitude,
    required this.longitude,
  });
}

class SimilarPlacesPage extends StatefulWidget {
  final int locationId;

  const SimilarPlacesPage({Key? key, required this.locationId}) : super(key: key);

  @override
  _SimilarPlacesPageState createState() => _SimilarPlacesPageState();
}

class _SimilarPlacesPageState extends State<SimilarPlacesPage> {
  late Future<List<Place>> futurePlaces;

  @override
  void initState() {
    super.initState();
    futurePlaces = fetchPlaces(widget.locationId);
  }

  Future<List<Place>> fetchPlaces(int locationId) async {
    // Here, you should call your API and parse the response
    // Example:
    List<Place> places = [];
    final List<dynamic> response = await LocationRecommend.recommendLocation(locationId);
    for(int i=0; i<response.length; i++){
      int resLocationId = response[i]["locationId"];
      String resLocationName = response[i]["title"];
      String reseCategoryName = response[i]["category"];
      double resLatitude = response[i]["latitude"];
      double resLongitude = response[i]["longitude"];
      String resBase64Image = response[i]["image"];
      places.add(
          Place(
            locationId: resLocationId,
            locationName: resLocationName,
            base64Image: resBase64Image,
            category: reseCategoryName,
            latitude: resLatitude,
            longitude: resLongitude,
          )
      );
    }
    // Decode the response and create a list of Place objects
    return places;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '추천된 장소',
          style: TextStyle(fontFamily: 'PretendardLight', color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Place>>(
        future: futurePlaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('발견된 장소가 없습니다. 다시 시도해주세요!', style: TextStyle(fontFamily: 'PretendardLight')));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('발견된 장소가 없습니다. 다시 시도해주세요!', style: TextStyle(fontFamily: 'PretendardLight')));
          } else {
            List<Place> places = snapshot.data!;
            return ResponsiveGridView(places: places);
          }
        },
      ),
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Place> places;

  ResponsiveGridView({required this.places});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxCrossAxisExtent;

        if (constraints.maxWidth < 600) {
          maxCrossAxisExtent = 200;
        } else if (constraints.maxWidth < 1200) {
          maxCrossAxisExtent = 250;
        } else {
          maxCrossAxisExtent = 300;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: places.length,
          itemBuilder: (context, index) {
            return PlaceCard(
              place: places[index],
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MarkerClicked(
                    latitude: places[index].latitude,
                    longitude: places[index].longitude,
                    category: places[index].category)
                )
                );
              },
            );
          },
        );
      },
    );
  }
}

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  PlaceCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(place.base64Image);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.0)),
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                place.locationName,
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'PretendardLight',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
