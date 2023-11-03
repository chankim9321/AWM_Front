import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

Future<Uint8List> createMarkerImage(String imagePath, Size size) async {
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
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
            size.width - tagWidth,
            0.0,
            tagWidth,
            tagWidth
        ),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      tagPaint);

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
  ui.Image image = await getImageFromPath(imagePath); // Alternatively use your own method to get the image
  paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);


  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt()
  );

  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<BitmapDescriptor> getMarkerIcon(String imagePath, Size size) async {
  Uint8List markerImage = await createMarkerImage(imagePath, size);
  return BitmapDescriptor.fromBytes(markerImage);
}

class CustomMarkerIcon extends StatefulWidget {
  final String imagePath;
  final Size size;

  CustomMarkerIcon({required this.imagePath, required this.size});

  @override
  _CustomMarkerIconState createState() => _CustomMarkerIconState();
}

class _CustomMarkerIconState extends State<CustomMarkerIcon> {
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    imageBytes = await createMarkerImage(widget.imagePath, widget.size);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (imageBytes == null) {
      return Container();
    }
    return Image.memory(imageBytes!);
  }
}