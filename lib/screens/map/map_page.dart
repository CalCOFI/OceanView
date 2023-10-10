import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocean_view/shared/constants.dart';

import 'package:ocean_view/src/mpa.dart' as mpa;
import 'package:ocean_view/src/pin_information.dart';
import 'package:url_launcher/url_launcher_string.dart';

/*
  Map page showing GoogleMap with MPA regions and unfinished Geofence
  User can click on any MAP regions to show the brief description of that
  MPA and link to complete regulation for it.
 */

class MapPage extends StatefulWidget {
  const MapPage({required Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Google map members
  late GoogleMapController? mapController;

  // center of California
  final LatLng _center = LatLng(36.735201, -119.790656);
  final double _zoom = 6.0;
  LatLng _location = LatLng(0.0, 0.0);

  final Map<String, Marker> _markers = {};
  final Map<String, Polygon> _polygons = {};
  final Map<String, Circle> _circles = {};

  // MPA members
  final List<String> _names = <String>[];
  final Map<String, LatLng> _centers = {};
  final Map<String, double> _radiuses = {};
  final Map<String, double> _distances = {};

  // Pin for showing MPA information
  double _pinPillPosition = -100;
  PinInformation pinInformation = PinInformation('None', 'None', [], 'None');

  @override
  void dispose() {
    mapController = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> getCurrentLocation() async {
    // Request permission ()
    // await Geolocator.checkPermission();
    // await Geolocator.requestPermission();

    final position = await Geolocator.getCurrentPosition();
    print(position);
    _location = LatLng(position.latitude, position.longitude);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    // Controller moves with current location
    mapController = controller;
    await getCurrentLocation();

    // Load MPAs
    final MPAs = await mpa.getMPAs();

    // Load MPA regulations
    final mpaRegulations = await mpa.getMPARegulations();
    String generalRegulation = ''; // General regulation in certain type

    setState(() {
      _markers.clear();
      _polygons.clear();
      _circles.clear();

      var num = 1;
      for (final MPA in MPAs.features) {
        var name = MPA.properties.FULLNAME;
        var type = MPA.properties.Type;
        var polygonCoords = <LatLng>[];
        var radius = 0.0;
        var points = MPA.geometry.coordinates[0];

        // Add polygon points
        for (final coord in points) {
          polygonCoords.add(LatLng(coord[1], coord[0]));
        }

        // Calculate center of polygon
        var first = points[0], last = points[points.length - 1];
        if (first[1] != last[1] || first[0] != last[0]) points.add(first);
        var twicearea = 0.0, x = 0.0, y = 0.0, nPts = points.length, p1, p2, f;
        for (var i = 0, j = nPts - 1; i < nPts; j = i++) {
          p1 = points[i];
          p2 = points[j];
          f = p1[1] * p2[0] - p2[1] * p1[0]; // [1]:x, [0]:y
          twicearea += f;
          x += (p1[1] + p2[1]) * f;
          y += (p1[0] + p2[0]) * f;
        }
        f = twicearea * 3;
        var center = LatLng(x / f, y / f);

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
            fillColor: MPA_type_color[type]!.withOpacity(0.5),
            strokeWidth: 1,
            strokeColor: MPA_type_color[type]!.withOpacity(0.5),
            consumeTapEvents: true,
            onTap: () {
              setState(() {
                _pinPillPosition = 100;
                pinInformation = PinInformation(name, type,
                    mpaRegulations[name] ?? ['None'], generalRegulation);
              });
            });
        _polygons[name] = polygon;

        // Get general regulation according to MPA type
        if (type.length > 4 && type.substring(0, 4) == 'SMCA') {
          generalRegulation = mpaRegulations['SMCA'];
        } else if (mpaRegulations.containsKey(type)) {
          generalRegulation = mpaRegulations[type];
        } else {
          generalRegulation = 'None';
        }

        // Add markers
        _markers[name] = Marker(
          markerId: MarkerId(name),
          position: center,
          alpha: 0.0,
        );

        // Store names, centers, radius and distances from current location
        _names.add(name);
        _centers[name] = center;
        _radiuses[name] = radius;
        _distances[name] = sqrt(pow(_location.latitude - center.latitude, 2) +
                pow(_location.longitude - center.longitude, 2)) *
            111000;

        print('$num. Add $name, Type: $type, Radius: $radius');
        num++;
      }

      // add marker for CalCOFI (32.865003202144884, -117.25420953232023)
      _markers[HQ_NAME] = Marker(
          markerId: MarkerId(HQ_NAME),
          position: LatLng(HQ_LOCATION[0], HQ_LOCATION[1]),
          alpha: 0.5,
          onTap: () {
            setState(() {
              _pinPillPosition = 100;
              pinInformation =
                  PinInformation(HQ_NAME, 'None', ['None'], 'None');
            });
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Map'),
            backgroundColor: themeMap['scaffold_appBar_color'],
            centerTitle: true,
          ),
          body: Stack(children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: _zoom,
              ),
              markers: _markers.values.toSet(),
              polygons: _polygons.values.toSet(),
              circles: _circles.values.toSet(),
              // markers: _markers.values.toSet(),
              myLocationEnabled: true,
            ),
            AnimatedPositioned(
              // Float window of MPA description and link to regulation page
              bottom: _pinPillPosition, right: 0, left: 0,
              duration: Duration(microseconds: 200),
              child: Align(
                  // Force it to be aligned at the bottom of the screen
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      // Wrap it inside a container so we can provide the
                      // background white and rounded corners
                      // and nice breathing room with margins, a fixed height
                      // and a nice subtle shadow for a depth effect
                      margin: EdgeInsets.all(5),
                      height: 70,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              blurRadius: 20,
                              offset: Offset.zero,
                              color: Colors.grey.withOpacity(0.5),
                            )
                          ]),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(pinInformation.locationName),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: (MPA_type_icon.containsKey(
                                              pinInformation.locationType))
                                          ? MPA_type_icon[
                                              pinInformation.locationType]!
                                          : [],
                                    ),
                                  ]),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
                                onPressed: () async {
                                  String url =
                                      (pinInformation.locationName == HQ_NAME)
                                          ? HQ_URL
                                          : MPA_URL;
                                  if (!await launchUrlString(url))
                                    throw 'Could not launch $url';
                                },
                              ),
                            )
                          ]))),
            ),
          ])),
    );
  }
}
