// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mpa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

Properties _$PropertiesFromJson(Map<String, dynamic> json) {
  return Properties(
    Type: json['Type'] as String,
    FULLNAME: json['FULLNAME'] as String,
    DFG_URL: json['DFG_URL'] as String,
  );
}

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'Type': instance.Type,
      'FULLNAME': instance.FULLNAME,
      'DFG_URL': instance.DFG_URL,
    };

Features _$FeaturesFromJson(Map<String, dynamic> json) {
  return Features(
    properties: json['properties'] == null
        ? null
        : Properties.fromJson(json['properties'] as Map<String, dynamic>),
    geometry: json['geometry'] == null
        ? null
        : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$FeaturesToJson(Features instance) => <String, dynamic>{
      'properties': instance.properties,
      'geometry': instance.geometry,
    };

MPAs _$MPAsFromJson(Map<String, dynamic> json) {
  return MPAs(
    (json['features'] as List)
        ?.map((e) =>
            e == null ? null : Features.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$MPAsToJson(MPAs instance) => <String, dynamic>{
      'features': instance.features,
    };
