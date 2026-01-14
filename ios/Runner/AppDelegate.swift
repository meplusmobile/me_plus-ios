import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Call super FIRST to initialize Flutter engine and window
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Register all plugins with 5 seconds delay to ensure engine is fully ready
    // Testing with longer delay to diagnose PathProviderPlugin crash
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
      guard let self = self else { return }
      GeneratedPluginRegistrant.register(with: self)
    }
    
    return result
  }
  
  // Handle app lifecycle to prevent memory issues
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    URLCache.shared.removeAllCachedResponses()
  }
}
