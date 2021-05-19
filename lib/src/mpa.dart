import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

// Connect with serialization code
part 'mpa.g.dart';

@JsonSerializable()
class Geometry {
  Geometry ({
    this.type,
    this.coordinates,
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
    this.Type,
    this.FULLNAME,
    this.DFG_URL,
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
    this.properties,
    this.geometry,
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
      .loadString('assets/California_Marine_Protected_Areas_[ds582].geojson');

  return MPAs.fromJson(json.decode(jsonText));
}
