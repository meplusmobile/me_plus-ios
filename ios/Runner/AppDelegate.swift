import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register plugins BEFORE calling super to prevent timing issues
    GeneratedPluginRegistrant.register(with: self)
    
    // Call super to initialize Flutter engine
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle app lifecycle to prevent memory issues
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    URLCache.shared.removeAllCachedResponses()
  }
}
