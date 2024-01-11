# CalCOFI OceanView

An app that incentivizes ocean goers to report their wild observations.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Credentials
1. Vision API headers is stored in `/lib/src/api_keys.dart` which needs to be transferred privately. 
2. Google Map API is stored in `/android/local.properties` and `/ios/Runner/APIKey.plist` which need to be transferred privately. 

## Lint Code
- Please run `dart format .` in the project root folder everytime before pushing commits. 
It will automatically lint the code to follow Dart guidelines. 
- Links for linting
  - Code formatting in IDE: https://docs.flutter.dev/tools/formatting
  - Code formatting in command line: https://dart.dev/tools/dart-format
    
## CI/CD (GitHub Actions)
### Unit-test when pushing commit in pull-request
`.github/workflows/test.yml` triggers the following actions to ensure that the code change won't 
break basic functions and fulfills format requirements. 
