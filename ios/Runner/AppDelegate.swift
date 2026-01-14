import Flutter
import UIKit
import path_provider_foundation
import shared_preferences_foundation
import google_sign_in_ios
import image_picker_ios
import url_launcher_ios

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Register all plugins EXCEPT PathProviderPlugin and SharedPreferencesPlugin
    // These two cause crashes if registered too early
    if let controller = window?.rootViewController as? FlutterViewController {
      FLTGoogleSignInPlugin.register(with: registrar(forPlugin: "FLTGoogleSignInPlugin")!)
      FLTImagePickerPlugin.register(with: registrar(forPlugin: "FLTImagePickerPlugin")!)
      URLLauncherPlugin.register(with: registrar(forPlugin: "URLLauncherPlugin")!)
    }
    
    // Call super to initialize Flutter engine
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Delay registration of PathProviderPlugin and SharedPreferencesPlugin
    // to ensure Flutter engine is fully initialized
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      guard let self = self else { return }
      if let controller = self.window?.rootViewController as? FlutterViewController {
        PathProviderPlugin.register(with: self.registrar(forPlugin: "PathProviderPlugin")!)
        SharedPreferencesPlugin.register(with: self.registrar(forPlugin: "SharedPreferencesPlugin")!)
      }
    }
    
    return result
  }
  
  // Handle app lifecycle to prevent memory issues
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    URLCache.shared.removeAllCachedResponses()
  }
}
