import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Google Sign-In authentication
class GoogleAuthService {
  // Initialize GoogleSignIn with platform-specific configuration
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    // Use different client IDs for iOS and Android
    if (Platform.isIOS) {
      // For iOS, use the iOS Client ID from Google Cloud Console
      _googleSignIn = GoogleSignIn(
        // iOS URL Scheme Client ID
        clientId:
            '676918546872-cogu1q96g22sju22k323458bmdggbip8.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      // For Android, use the Web OAuth Client ID
      _googleSignIn = GoogleSignIn(
        clientId:
            '676918546872-cogu1q96g22sju22k323458bmdggbip8.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    }
  }

  /// Sign in with Google and return the user account
  /// Returns null if user cancels or sign-in fails
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      return googleUser;
    } catch (e) {
      // Log error and rethrow
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google Sign-Out Error: $e');
      rethrow;
    }
  }

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      print('Google isSignedIn Error: $e');
      return false;
    }
  }

  /// Get current user info if signed in
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      print('Google getCurrentUser Error: $e');
      return null;
    }
  }

  /// Silent sign-in (attempts to sign in without showing UI)
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently();
      return googleUser;
    } catch (e) {
      print('Google signInSilently Error: $e');
      return null;
    }
  }
}
