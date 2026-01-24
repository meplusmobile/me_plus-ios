import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Google Sign-In authentication
class GoogleAuthService {
  // Get the GoogleSignIn instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  GoogleAuthService() {
    _initialize();
  }

  /// Initialize GoogleSignIn with configuration
  Future<void> _initialize() async {
    if (Platform.isAndroid) {
      // Use the Web OAuth 2.0 Client ID for Android
      await _googleSignIn.initialize(
        clientId:
            '676918546872-cogu1q96g22sju22k323458bmdggbip8.apps.googleusercontent.com',
      );
    } else if (Platform.isIOS) {
      // iOS needs serverClientId (Web OAuth Client ID) for backend verification
      // The iOS client ID is configured in Info.plist
      await _googleSignIn.initialize(
        clientId:
            '676918546872-ijegpgmpglge555oemqh4lj89spf2ado.apps.googleusercontent.com',
        // Add Web OAuth Client ID so backend can verify the token
        serverClientId:
            '676918546872-cogu1q96g22sju22k323458bmdggbip8.apps.googleusercontent.com',
      );
    }
  }

  /// Sign in with Google and return the user account
  /// Returns null if user cancels or sign-in fails
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      return googleUser;
    } catch (e) {
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    final user = await signInSilently();
    return user != null;
  }

  /// Get current user info if signed in
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return signInSilently();
  }

  /// Silent sign-in (attempts to sign in without showing UI)
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.attemptLightweightAuthentication();
      return googleUser;
    } catch (e) {
      return null;
    }
  }
}
