import 'dart:io';
import 'package:exif/exif.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*
  File for extracting meta data from an image

  Two classes for defining data formats of meta data
  One method for returning meta data given the image file
 */

class Location {
  // Represent them in decimal degrees
  // Positive for N and E, Negative for S and W
  double longitude = 0;
  double latitude = 0;
  LatLng latLng = LatLng(0,0);

  Location(List<dynamic> longitude, List<dynamic> longRef, List<dynamic> latitude, List<dynamic> latRef) {
    this.longitude = toDouble(longitude[0]) + toDouble(longitude[1])/60 + toDouble(longitude[2])/3600;
    this.longitude = String.fromCharCode(longRef[0])=='E' ? this.longitude : -this.longitude;

    this.latitude = toDouble(latitude[0]) + toDouble(latitude[1])/60 + toDouble(latitude[2])/3600;
    this.latitude = String.fromCharCode(latRef[0])=='N' ? this.latitude : -this.latitude;
  }

  Location.empty() { }

  double toDouble(Ratio ratio) => ratio.numerator/ratio.denominator;

  LatLng getLatLng() {
    return LatLng(this.latitude, this.longitude);
  }

  @override
  String toString() {
    String latSymbol = (this.latitude>=0)? 'N' : 'S';
    String longSymbol = (this.longitude>=0)? 'E' : 'W';
    return '( ${this.latitude.abs().toStringAsFixed(2) + latSymbol} , ${this.longitude.abs().toStringAsFixed(2) + longSymbol} )';
  }
}

// Class of PhotoMeta of location and time
class PhotoMeta<T1, T2> {
  final T1 location;
  final T2 time;

  PhotoMeta(this.location, this.time);

  @override
  String toString() {
    return 'Location - ${this.location}\nTime - ${this.time}';
  }
}

// Future<File> getImageFileFromAssets(String path) async {
//   final byteData = await rootBundle.load('assets/$path');
//
//   final file = File('${(await getTemporaryDirectory()).path}/$path');
//   await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//
//   return file;
// }

Future<PhotoMeta> extractLocationAndTime(File imageFile) async {

  // Read data from imageFile
  final fileBytes = imageFile.readAsBytesSync();
  final data = await readExifFromBytes(fileBytes);

  // Example of time and location
  // Key: Image DateTime, Value: 2015:10:24 10:02:25
  // Key: GPSLatitude, Value: [24, 48, 4841/100] (Ratio)
  // Key: GPSLongitude, Value: [121, 14, 1147/25]
  // Key: GPSAltitude, Value: [2, 2, 25]
  // Key: GPSDate, Value: 2015:10:24
  // Key: GPS GPSLatitudeRef, Value: N
  // Key: GPS GPSLongitudeRef, Value: E
  // Key: GPS GPSAltitudeRef, Value: 0

  if (data!.isEmpty) {
    print("No EXIF information found");
    return PhotoMeta(0,0);
  } else {

    Location location = Location.empty();
    // Extract location from GPS
    try {
      location = Location(
          data['GPS GPSLongitude']!.values!,
          data['GPS GPSLongitudeRef']!.values!,
          data['GPS GPSLatitude']!.values!,
          data['GPS GPSLatitudeRef']!.values!
      );
    } catch (e) {
      print(e);
    }

    // Extract time
    DateTime dateTime = DateTime(0);
    String time = data['Image DateTime']!.printable ?? 'None';
    if (time!='None') {
      // 2015:10:24 10:02:25 -> 2015-10-24 10:02:25
      List<String> list = time.split(':');
      dateTime = DateTime.parse('${list[0]}-${list[1]}-${list[2]}:${list[3]}:${list[4]}');
    }

    return PhotoMeta(location, dateTime);
  }
}