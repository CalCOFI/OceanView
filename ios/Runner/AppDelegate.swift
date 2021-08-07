import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)
    // Firebase
    FirebaseApp.configure()
    // GoogleMaps
    GMSServices.provideAPIKey("AIzaSyBpDLenOUhz8cWFT0Oc7gWD4MneSUboyVc")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
