import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Google Sign-In authentication
class GoogleAuthService {
  // Initialize GoogleSignIn with the Web Client ID from Google Cloud Console
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Use the Web OAuth 2.0 Client ID for Android
    clientId:
        '676918546872-cogu1q96g22sju22k323458bmdggbip8.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

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
      rethrow;
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
    return await _googleSignIn.isSignedIn();
  }

  /// Get current user info if signed in
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }

  /// Silent sign-in (attempts to sign in without showing UI)
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signInSilently();
      return googleUser;
    } catch (e) {
      return null;
    }
  }
}
