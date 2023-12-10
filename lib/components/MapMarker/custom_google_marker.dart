import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapdesign_flutter/LocationInfo/marker_clicked.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';

Future<ui.Image> getImageFromPath(String imagePath) async {
  final Completer<ui.Image> completer = Completer();
  final AssetImage assetImage = AssetImage(imagePath);
  assetImage.resolve(ImageConfiguration()).addListener(
    ImageStreamListener(
          (ImageInfo info, bool _) => completer.complete(info.image),
    ),
  );
  return completer.future;
}
Future<ui.Image> getImageFromUint8List(Uint8List data) async {
  final Completer<ui.Image> completer = Completer();

  // Uint8List 데이터를 이미지 스트림으로 디코딩
  ui.decodeImageFromList(data, (ui.Image img) {
    completer.complete(img);
  });

  return completer.future;
}
Future<Uint8List> createMarkerImage(String? imagePath , Uint8List? imageData, Size size) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final Radius radius = Radius.circular(size.width / 2);

  final Paint tagPaint = Paint()..color = Colors.blue;
  final double tagWidth = 80.0;

  final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
  final double shadowWidth = 15.0;

  final Paint borderPaint = Paint()..color = Colors.white;
  final double borderWidth = 3.0;

  final double imageOffset = shadowWidth + borderWidth;

// Add shadow circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
            0.0,
            0.0,
            size.width,
            size.height
        ),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      shadowPaint);

// Add border circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
            shadowWidth,
            shadowWidth,
            size.width - (shadowWidth * 2),
            size.height - (shadowWidth * 2)
        ),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      borderPaint);

// Add tag circle
//   canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(
//             size.width - tagWidth,
//             0.0,
//             tagWidth,
//             tagWidth
//         ),
//         topLeft: radius,
//         topRight: radius,
//         bottomLeft: radius,
//         bottomRight: radius,
//       ),
//       tagPaint);

// Add tag text
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  textPainter.text = TextSpan(
    text: '1',
    style: TextStyle(fontSize: 40.0, color: Colors.white),
  );

  textPainter.layout();
  textPainter.paint(
      canvas,
      Offset(
          size.width - tagWidth / 2 - textPainter.width / 2,
          tagWidth / 2 - textPainter.height / 2
      )
  );

// Oval for the image
  Rect oval = Rect.fromLTWH(
      imageOffset,
      imageOffset,
      size.width - (imageOffset * 2),
      size.height - (imageOffset * 2)
  );

// Add path for oval image
  canvas.clipPath(Path()
    ..addOval(oval));

// Add image
  ui.Image image;
  if (imagePath != null && imagePath.isNotEmpty) {
    // 이미지 경로가 제공된 경우
    image = await getImageFromPath(imagePath);
  } else if (imageData != null && imageData.isNotEmpty) {
    // Uint8List 데이터가 제공된 경우
    image = await getImageFromUint8List(imageData);
  } else {
    throw Exception('No image provided');
  }
  paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);


  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt()
  );

  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<BitmapDescriptor> getMarkerIcon(String imagePath, Uint8List imageData, Size size) async {
  Uint8List markerImage = await createMarkerImage(imagePath, imageData, size);
  return BitmapDescriptor.fromBytes(markerImage);
}
class CustomGoogleMarker extends StatefulWidget {
  final String imagePath;
  final Size size;
  final bool isPlace;
  final double latitude;
  final double longitude;
  final String category;
  final Uint8List imageData;
  const CustomGoogleMarker({super.key, required this.imagePath, required this.size, this.isPlace = false,
    required this.latitude, required this.longitude, required this.imageData, this.category = "none"});

  @override
  _CustomGoogleMarkerState createState() => _CustomGoogleMarkerState();
}

class _CustomGoogleMarkerState extends State<CustomGoogleMarker> {
  Uint8List? imageBytes;
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  Future<dynamic> _getPlaceInfo(){
    if(widget.isPlace){
      return showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context){
            return Container(
              height: MediaQuery.of(context).size.height,
              child: MarkerClicked(latitude:widget.latitude, longitude: widget.longitude, category: widget.category)
            );
          }
      );
    }
    else {
      return Future.value();
    }
  }
  Future<void> _loadImage() async {
    imageBytes = await createMarkerImage(widget.imagePath, widget.imageData, widget.size);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (imageBytes == null) {
      return Container();
    }
    return GestureDetector(
      onTap: _getPlaceInfo,
      child: Image.memory(imageBytes!),
    );
  }
}