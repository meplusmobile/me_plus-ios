import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Flutter engine first
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // Call super to ensure complete initialization
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Small delay to ensure engine is fully ready before plugin registration
    DispatchQueue.main.async {
      GeneratedPluginRegistrant.register(with: self)
    }
    
    return result
  }
}
