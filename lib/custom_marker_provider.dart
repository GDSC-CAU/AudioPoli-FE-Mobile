import 'dart:ui' as dart_ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerProvider {
  List<BitmapDescriptor> customMarker = [];
  static final MarkerProvider _instance = MarkerProvider._internal();

  factory MarkerProvider() {
    return _instance;
  }

  MarkerProvider._internal();

  Future<void> loadCustomMarker() async {
    List<String> paths = [];
    for (int i = 1; i <= 14; i++) {
      paths.add('assets/img/custom_marker_$i.png');
    }

    for (String path in paths) {
      final ByteData byteData = await rootBundle.load(path);
      final Uint8List imageData = byteData.buffer.asUint8List();
      dart_ui.Codec codec = await dart_ui.instantiateImageCodec(imageData, targetWidth: 128);
      dart_ui.FrameInfo fi = await codec.getNextFrame();
      final Uint8List markerIcon = (await fi.image.toByteData(format: dart_ui.ImageByteFormat.png))!.buffer.asUint8List();
      customMarker.add(BitmapDescriptor.fromBytes(markerIcon));
    }
  }

  BitmapDescriptor? getMarker(int detail) {
    return customMarker[detail - 1];
  }
}