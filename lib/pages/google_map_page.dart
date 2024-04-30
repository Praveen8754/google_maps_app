import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart' hide LocationAccuracy;
import 'package:google_map_app/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  Location locationController = Location();
  final Completer<GoogleMapController> _controller = Completer();
  static const googlePlex = LatLng(37.4223, -122.0848);
  static const mountainView = LatLng(37.3861, -122.0839);
  late CameraPosition cameraPosition;
  Position? currentPosition;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation().then((value) async {
      print(" initstate :${value.latitude} ${value.longitude}");

      // marker added for current users location
      _markers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        position: LatLng(value.latitude, value.longitude),
        infoWindow: const InfoWindow(
          title: 'My Current Location',
        ),
      ));

      // specified current users location
      cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14,
      );
      currentPosition = await Geolocator.getCurrentPosition();

      print("a");
      print(cameraPosition == null ? "null dhaan" : "iruku");
      print(currentPosition == null ? "null dhaan" : "iruku1");
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
      //   setState(() {});
    });
    initializeMap();

/*
    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        //setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
      //  });
      }
      setState(() {

      });
    });*/
    /*   WidgetsBinding.instance
        .addPostFrameCallback((_) async => await initializeMap());*/
  }

  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR$error");
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> initializeMap() async {
    //  await fetchLocationUpdates();
    final coordinates = await fetchPolylinePoints();
    generatePolyLineFromPoints(coordinates);
  }

  final List<Marker> _markers = <Marker>[
    const Marker(
      markerId: MarkerId('sourceLocation'),
      icon: BitmapDescriptor.defaultMarker,
      position: googlePlex,
    ),
    const Marker(
      markerId: MarkerId('destinationLocation'),
      icon: BitmapDescriptor.defaultMarker,
      position: mountainView,
    )
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: /* currentPosition.latitude
            ? const Center(child: CircularProgressIndicator())
            :*/
            GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.43296265331129, -122.08832357078792),
                  // LatLng(currentPosition!.latitude, currentPosition!.longitude),
                  zoom: 14,
                ) /*const CameraPosition(
                  target:currentPosition ,
                  zoom: 13,
                )*/
                ,
                myLocationEnabled: true,
                markers: Set<Marker>.of(_markers),
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(
                // on below line we have given positions of Location 5
                CameraPosition(
              target: LatLng(20.42796133580664, 73.885749655962),
              zoom: 14,
            )));
            setState(() {});
          },
          // on below line we have set icon for button
          child: Icon(Icons.location_disabled_outlined),
        ),
      );

  Future<List<LatLng>> fetchPolylinePoints() async {
    print("fetchPolylinePoints");
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapsApiKey,
      PointLatLng(googlePlex.latitude, googlePlex.longitude),
      PointLatLng(mountainView.latitude, mountainView.longitude),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(
      List<LatLng> polylineCoordinates) async {
    print("generatePolyLineFromPoints");
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() => polylines[id] = polyline);
  }
}
