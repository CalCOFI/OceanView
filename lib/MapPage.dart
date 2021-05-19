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

  Future<void> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    _center = LatLng(position.latitude, position.longitude);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {

    // Controller moves with current location
    mapController = controller;
    // await getCurrentLocation();

    // Load MPAs
    final MPAs = await mpa.getMPAs();
    setState(() {

      _markers.clear();
      _polygons.clear();

      var num = 1;
      for (final MPA in MPAs.features){
        var name = MPA.properties.FULLNAME;
        var polygonCoords = <LatLng>[];

        // Add polygons
        for (final coord in MPA.geometry.coordinates[0]) {
          polygonCoords.add(LatLng(coord[1],coord[0]));
        }

        final polygon = Polygon(
          polygonId: PolygonId(name),
          points: polygonCoords,
          strokeColor: Colors.blue.withOpacity(0.5),
          fillColor: Colors.blue.withOpacity(0.5),
        );
        _polygons[name] = polygon;

        // Add markers
        _markers[name] = Marker(
            markerId: MarkerId(name),
            position: polygonCoords[0],
            alpha: 0.5,
            infoWindow: InfoWindow(
                title: name,
                snippet: MPA.properties.Type
            )
        );

        var type = MPA.properties.Type;
        print('$num. Add $name, Type: $type');
        num++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Marine Protected Areas'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 15,
          ),
          polygons: _polygons.values.toSet(),
          markers: _markers.values.toSet(),
          myLocationEnabled: true,
        ),
      ),
    );
  }
}