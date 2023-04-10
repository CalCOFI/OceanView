/*
  Files for defining classes to decode json returned from VisionAPI

  Prediction <- Result <- Taxon
 */

class Prediction {
  List<Result> results;

  Prediction(this.results);

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      (json['results'] as List<dynamic>)
          .map((e) => Result.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Result {
  Taxon taxon;
  bool visuallySimilar;

  Result({
    required this.taxon,
    required this.visuallySimilar,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      taxon: Taxon.fromJson(json['taxon'] ?? '' as Map<String, dynamic>),
      visuallySimilar: json['visually_similar'] ?? '' as bool,
    );
  }
}

class Taxon {
  int id;
  String name;
  String preferredCommonName;

  Taxon({
    required this.id,
    required this.name,
    required this.preferredCommonName,
  });

  factory Taxon.fromJson(Map<String, dynamic> json) {
    return Taxon(
      id: json['id'] ?? 0 as int,
      name: json['name'] ?? '' as String,
      preferredCommonName: json['preferred_common_name'] ?? '' as String,
    );
  }
}
