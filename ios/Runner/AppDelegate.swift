import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Call super first to ensure Flutter engine is initialized
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Register plugins after Flutter engine is ready
    GeneratedPluginRegistrant.register(with: self)
    
    return result
  }
}
