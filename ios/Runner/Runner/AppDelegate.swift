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

    // Local notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    // TODO: Add your API key
    GMSServices.provideAPIKey("AIzaSyBpDLenOUhz8cWFT0Oc7gWD4MneSUboyVc")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
