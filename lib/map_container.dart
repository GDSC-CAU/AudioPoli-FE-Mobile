import 'dart:async';
import 'package:audiopoli_mobile/radar_animation.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import './incident_data.dart';
import 'custom_info_window_widget.dart';
import 'custom_marker_provider.dart';

class MapContainer extends StatefulWidget {
  const MapContainer({super.key, required this.logMap});
  final Map<String, dynamic> logMap;

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {

  late GoogleMapController mapController;

  var incidentMap = <String, dynamic>{};
  Set<Marker> markers = {};

  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  final GlobalKey<RadarAnimationState> radarKey = GlobalKey<RadarAnimationState>();

  final LatLng _center = const LatLng(37.5058, 126.956);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    updateData();
    updateMarkers();
  }

  @override
  void didUpdateWidget(MapContainer oldWidget) {

    if (kDebugMode) {
      print('Update MapContainer Widget');
    }
    super.didUpdateWidget(oldWidget);
    updateData();
    updateMarkers();
  }

  //
  // Future<void> _addMarker(Set<Marker> newMarkers, dynamic entry, String markerId) async {
  //   newMarkers.add(
  //     Marker(
  //       icon: MarkerProvider().getMarker(entry.detail) ?? BitmapDescriptor.defaultMarker,
  //       markerId: MarkerId(markerId),
  //       position: LatLng(entry.latitude, entry.longitude),
  //       onTap: () {
  //         _customInfoWindowController.addInfoWindow!(
  //           CustomInfoWindowWidget(data: entry, controller: _customInfoWindowController,),
  //           LatLng(entry.latitude, entry.longitude),
  //         );
  //       },
  //     ),
  //   );
  // }
  //
  // void updateMarkers() {
  //   Set<Marker> newMarkers = {};
  //   widget.logMap.forEach((key, value) {
  //     _addMarker(newMarkers, incidentMap[key], key);
  //   });
  //   setState(() {
  //     markers = newMarkers;
  //   });
  // }
  //
  // void updateData() {
  //   setState(() {
  //     incidentMap.clear();
  //     widget.logMap.forEach((key, value) {
  //       IncidentData incident = IncidentData(
  //           date: value.date,
  //           time: value.time,
  //           latitude: value.latitude,
  //           longitude: value.longitude,
  //           sound: value.sound,
  //           category: value.category,
  //           detail: value.detail,
  //           id: value.id,
  //           isCrime: value.isCrime,
  //           departureTime: value.departureTime,
  //           caseEndTime: value.caseEndTime
  //       );
  //       incidentMap[key] = incident;
  //     });
  //   });
  // }


  void updateMarkers() async {
    Set<String> currentMarkerIds = markers.map((m) => m.markerId.value).toSet();
    Set<String> logMapMarkerIds = widget.logMap.keys.toSet();
    Set<String> newMarkerIds = logMapMarkerIds.difference(currentMarkerIds);
    Set<String> removedMarkerIds = currentMarkerIds.difference(logMapMarkerIds);

    for (String markerId in newMarkerIds) {
      var newMarkerData = widget.logMap[markerId];
      _addMarker(newMarkerData, markerId);
    }

    setState(() {
      markers.removeWhere((m) => removedMarkerIds.contains(m.markerId.value));
    });
  }

  Future<void> _addMarker(dynamic entry, String markerId) async {
    final Marker newMarker =  Marker(
      icon: MarkerProvider().getMarker(entry.detail) ?? BitmapDescriptor.defaultMarker,
      markerId: MarkerId(markerId),
      position: LatLng(entry.latitude, entry.longitude),
      onTap: () {
        _customInfoWindowController.addInfoWindow!(
          CustomInfoWindowWidget(data: entry, controller: _customInfoWindowController,),
          LatLng(entry.latitude, entry.longitude),
        );
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(entry.latitude + 0.0005, entry.longitude),
              zoom: 17.0,
            ),
          ),
        );
      },
    );

    setState(() {
      if(entry.caseEndTime[0] == '9' && entry.isCrime == 1) {
        markers.add(newMarker);
      }
    });

    if(entry.caseEndTime[0] == '9' && entry.isCrime == 1) {
      _customInfoWindowController.addInfoWindow!(
        CustomInfoWindowWidget(
          data: entry, controller: _customInfoWindowController,),
        LatLng(entry.latitude, entry.longitude),
      );
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(entry.latitude + 0.0005, entry.longitude),
            zoom: 17.0,
          ),
        ),
      );
      radarKey.currentState?.startAnimation();
    }
  }
  void updateData() {
    Set<String> toRemove = {};

    setState(() {
      incidentMap.clear();
      widget.logMap.forEach((key, value) {
        IncidentData incident = IncidentData(
            date: value.date,
            time: value.time,
            latitude: value.latitude,
            longitude: value.longitude,
            sound: value.sound,
            category: value.category,
            detail: value.detail,
            id: value.id,
            isCrime: value.isCrime,
            departureTime: value.departureTime,
            caseEndTime: value.caseEndTime
        );

        if (incident.caseEndTime != null && incident.caseEndTime!.startsWith('9')) {
          incidentMap[key] = incident;
        } else {
          toRemove.add(key);
        }
      });

      markers.removeWhere((marker) => toRemove.contains(marker.markerId.value));
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget> [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _customInfoWindowController.googleMapController = controller;
              _onMapCreated(controller);
              controller.setMapStyle("""[
                      {
                        "featureType": "poi",
                        "elementType": "labels",
                        "stylers": [
                          { "visibility": "off" }
                        ]
                      }
                    ]""");
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 17.0,
            ),
            onCameraMove: (CameraPosition position) {
              _customInfoWindowController.onCameraMove!();
            },
            markers: markers,
          ),
          Center(child: Padding(
            padding: const EdgeInsets.only(top:100.0),
            child: RadarAnimation(key: radarKey),
          )),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 140,
            width: 270,
            offset: 70,
          ),
        ]
      )
    );
  }
}
