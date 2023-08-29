/*
  Class for containing information of pin used on GoogleMap
 */

class PinInformation {
  late String locationName; // MPA name
  late String locationType; // MPA type
  late List<dynamic> exceptions; // Specific regulation
  late String generalRegulation; // General regulation

  PinInformation(String locationName, String locationType,
      List<dynamic> exceptions, String generalRegulation) {
    this.locationName = locationName;
    this.locationType = locationType;
    this.exceptions = exceptions;
    this.generalRegulation = generalRegulation;
  }
}
