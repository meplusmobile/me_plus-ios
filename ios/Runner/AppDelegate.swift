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
    
    // Delay plugin registration to ensure Flutter engine is fully initialized
    // Increased delay to 0.5s to prevent PathProviderPlugin crashes
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
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
