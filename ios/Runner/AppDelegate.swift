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

    // Add Google Map API key
    if let APIKEY = KeyManager().getValue(key: "mapApiKey") as? String {
      GMSServices.provideAPIKey(APIKEY)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
