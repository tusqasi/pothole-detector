import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pothole_dectector/drawer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Platform channels help talk with native andriod apis
  final EventChannel _eventChannel = const EventChannel("event_channel");
  final MethodChannel _methodChannel = const MethodChannel("method_channel");

  /// Inclination of the phone
  Map<String, double> inclination = {
    "x": 0,
    "y": 0,
    "z": 0,
    "f": 0,
  };

  /// Control and access the map with [mapController].
  late GoogleMapController mapController;

  /// Set of [Marker] which is shown on map.
  final Set<Marker> _markers = {};

  /// Object which stores the image to make into a [Marker].
  late BitmapDescriptor mapMarker;

  Location location = Location();

  /// The location of delhi
  final LatLng _delhiLoc = const LatLng(
    28.65,
    77.23,
  );

  @override
  void initState() {
    super.initState();
    _eventChannel.receiveBroadcastStream().listen(_onData, onError: _onError);
    setCustomMarker();
  }

  void _onError(dynamic event) {}
  void _onData(dynamic event) {
    setState(() {
      inclination["x"] = event[0];
      inclination["y"] = event[1];
      inclination["z"] = event[2];
      if (event.length > 4) {
        inclination["f"] = event[3];
      }
    });
  }

  /// Convert the [AssetImage] to [BitmapDescriptor]
  void setCustomMarker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'image/marker.png',
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      /// Add the first [Marker] to the set.
      _markers.add(Marker(
        markerId: const MarkerId("Pot hole here"),
        icon: mapMarker,
        position: _delhiLoc,
      ));
    });
    mapController = controller;

    location.onLocationChanged.listen((currentPosition) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                currentPosition.latitude!,
                currentPosition.longitude!,
              ),
              zoom: 15),
        ),
      );
    });
  }

  /// Puts a marker at the current map location
  ///
  /// Warning: Not on the physical current location
  void add_marker() async {
    LatLng _map_position = await mapController
        .getLatLng(
          const ScreenCoordinate(
            x: 500,
            y: 1000,
          ),
        )
        .then((value) => value);

    // adds a marker to the current position on map
    _markers.add(Marker(
      markerId: MarkerId("${_markers.length}"),
      icon: mapMarker,
      position: _map_position,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pothole'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _delhiLoc,
                zoom: 11.0,
              ),
              buildingsEnabled: true,
              markers: _markers,
            ),
            Center(
              child: Text(
                'X: ${inclination["x"]?.toStringAsFixed(5)}\n'
                'Y: ${inclination["y"]?.toStringAsFixed(5)}\n'
                'Z: ${inclination["z"]?.toStringAsFixed(5)}\n'
                'f: ${inclination["f"]?.toStringAsFixed(5)}\n',
              ),
            ),
            Positioned(
              bottom: 50,
              right: 10,
              child: FloatingActionButton(
                hoverColor: Colors.amberAccent,
                backgroundColor: Colors.red,
                splashColor: Colors.indigo,
                onPressed: add_marker,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        drawer: MyDrawer(),
      ),
    );
  }
}
