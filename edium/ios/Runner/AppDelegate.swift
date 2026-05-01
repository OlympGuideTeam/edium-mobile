import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Must be called before GeneratedPluginRegistrant so that Firebase iOS SDK
    // captures launchOptions[.remoteNotification] at native launch time.
    // Without this, getInitialMessage() returns nil for terminated-state taps
    // because the Dart-side Firebase.initializeApp() runs too late.
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
