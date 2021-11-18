import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

// Connect with serialization code
part 'mpa.g.dart';

/*
// Design specific GeometryFromJson to include polygon and multipolygon
Geometry _$GeometryFromJson(Map<String, dynamic> json) {
  String type = json['type'] as String;
  var coordinates;
  if (type == 'Polygon')
    coordinates = (json['coordinates'] as List<dynamic>)
        .map((e) => (e as List<dynamic>)
        .map((e) =>
        (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
        .toList())
        .toList();
  else if (type == 'MultiPolygon') {
    coordinates =
        (json['coordinates'] as List<dynamic>)
            .map((e) =>
            (e as List<dynamic>)
                .map((e) =>
                (e as List<dynamic>)
                    .map((e) =>
                    (e as List<dynamic>)
                        .map((e) => (e as num).toDouble())
                        .toList())
                    .toList())
                .toList())
            .toList();
    coordinates = coordinates[0];    // Reduce dimension from 4 to 3
  }
  else
    throw('Cannot handle $type');

  return Geometry(
      type: type,
      coordinates: coordinates
  );
}
 */

@JsonSerializable()
class Geometry {
  Geometry ({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      _$GeometryFromJson(json);
  Map<String, dynamic> toJson() => _$GeometryToJson(this);

  final String type;
  final List<List<List<double>>> coordinates;
}

@JsonSerializable()
class Properties {
  Properties({
    required this.Type,
    required this.FULLNAME,
    required this.DFG_URL,
  });

  factory Properties.fromJson(Map<String, dynamic> json) =>
      _$PropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$PropertiesToJson(this);

  final String Type;
  final String FULLNAME;
  final String DFG_URL;
}

@JsonSerializable()
class Features {
  Features({
    required this.properties,
    required this.geometry,
  });

  factory Features.fromJson(Map<String, dynamic> json) =>
      _$FeaturesFromJson(json);
  Map<String, dynamic> toJson() => _$FeaturesToJson(this);

  final Properties properties;
  final Geometry geometry;
}

@JsonSerializable()
class MPAs {
  MPAs(this.features);

  factory MPAs.fromJson(Map<String, dynamic> json) => _$MPAsFromJson(json);
  Map<String, dynamic> toJson() => _$MPAsToJson(this);

  final List<Features> features;
}

Future<MPAs> getMPAs() async {
  final jsonText = await rootBundle
      .loadString('assets/jsons/California_Marine_Protected_Areas_[ds582].geojson');

  return MPAs.fromJson(json.decode(jsonText));
}
