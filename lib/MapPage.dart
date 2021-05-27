import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocean_view/src/mpa.dart' as mpa;

class MapPage extends StatefulWidget {
  const MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController mapController;

  LatLng _center = LatLng(32.832809, -117.271271);
  Location _location = Location();
  final Map<String, Marker> _markers = {};
  final Map<String, Polygon> _polygons = {};
  final Map<String, Circle> _circles = {};

  Future<void> getCurrentLocation() async {
    setState(() async {
      final position = await Geolocator.getCurrentPosition();
      _center = LatLng(position.latitude,position.longitude);
      print(position);
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {

    // Get current location
    mapController = controller;
    // getCurrentLocation();

    // Load MPAs
    final MPAs = await mpa.getMPAs();
    setState(() {

      _markers.clear();
      _polygons.clear();
      _circles.clear();

      var num = 1;
      for (final MPA in MPAs.features){
        var name = MPA.properties.FULLNAME;
        var polygonCoords = <LatLng>[];
        var radius = 0.0;
        var points = MPA.geometry.coordinates[0];

        // Add polygon points
        for (final coord in points) {
          polygonCoords.add(LatLng(coord[1],coord[0]));
        }

        // Calculate center of polygon
        var first = points[0], last = points[points.length-1];
        if (first[1] != last[1] || first[0] != last[0]) points.add(first);
        var twicearea=0.0,
            x=0.0, y=0.0,
            nPts = points.length,
            p1, p2, f;
        for ( var i=0, j=nPts-1 ; i<nPts ; j=i++ ) {
          p1 = points[i]; p2 = points[j];
          f = p1[1]*p2[0] - p2[1]*p1[0];    // [1]:x, [0]:y
          twicearea += f;
          x += ( p1[1] + p2[1] ) * f;
          y += ( p1[0] + p2[0] ) * f;
        }
        f = twicearea * 3;
        var center = LatLng(x/f, y/f);

        // Calculate longest distance as radius (1 degree=111000 meters)
        for (final coord in points) {
          var distance = sqrt(pow(coord[1] - center.latitude, 2) +
              pow(coord[0] - center.longitude, 2));
          if (distance > radius) {
            radius = distance.toDouble();
          }
        }
        radius *= 111000;

        // Add polygons
        final polygon = Polygon(
          polygonId: PolygonId(name),
          points: polygonCoords,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 1,
          strokeColor: Colors.blue.withOpacity(0.5),
        );
        _polygons[name] = polygon;

        // Add circles
        final circle = Circle(
            circleId: CircleId(name),
            center: center,
            radius: radius,
            fillColor: Colors.red.withOpacity(0.5),
            strokeWidth: 1,
            strokeColor: Colors.red.withOpacity(0.5)
        );
        _circles[name] = circle;

        // Add markers
        _markers[name] = Marker(
            markerId: MarkerId(name),
            position: center,
            alpha: 0.5,
            infoWindow: InfoWindow(
                title: name,
                snippet: MPA.properties.Type
            )
        );

        var type = MPA.properties.Type;
        print('$num. Add $name, Type: $type, Radius: $radius');
        num++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: _center,
          ),
          polygons: _polygons.values.toSet(),
          circles: _circles.values.toSet(),
          markers: _markers.values.toSet(),
          myLocationEnabled: true,
        ),
      ),
    );
  }
}