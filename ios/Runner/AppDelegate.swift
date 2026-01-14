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
    // Increased delay to 0.3s to prevent PathProviderPlugin crashes
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      guard let self = self else { return }
      
      // Double-check that Flutter engine is ready
      if let engine = self.engine, engine.isGPUDisabled == false {
        GeneratedPluginRegistrant.register(with: self)
      } else {
        // Fallback: try again after another 0.2s if engine not ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
          guard let self = self else { return }
          GeneratedPluginRegistrant.register(with: self)
        }
      }
    }
    
    return result
  }
  
  // Handle app lifecycle to prevent memory issues
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    URLCache.shared.removeAllCachedResponses()
  }
}
