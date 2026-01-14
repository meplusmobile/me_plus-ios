import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Call super to initialize Flutter engine
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Register plugins asynchronously to prevent crashes
    // This ensures the Flutter engine is fully initialized before plugin registration
    DispatchQueue.main.async {
      GeneratedPluginRegistrant.register(with: self)
    }
    
    return result
  }
  
  // Handle app lifecycle to prevent memory issues
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    // Clear caches if needed
    URLCache.shared.removeAllCachedResponses()
  }
}
