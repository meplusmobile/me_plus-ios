import Flutter
import UIKit
import google_sign_in_ios
import image_picker_ios
import url_launcher_ios

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Call super FIRST to initialize Flutter engine
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Manually register only safe plugins immediately
    // PathProviderPlugin and SharedPreferencesPlugin will auto-register via Flutter
    FLTGoogleSignInPlugin.register(with: registrar(forPlugin: "FLTGoogleSignInPlugin")!)
    FLTImagePickerPlugin.register(with: registrar(forPlugin: "FLTImagePickerPlugin")!)
    URLLauncherPlugin.register(with: registrar(forPlugin: "URLLauncherPlugin")!)
    
    return result
  }
  
  // Handle app lifecycle to prevent memory issues
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    URLCache.shared.removeAllCachedResponses()
  }
}
