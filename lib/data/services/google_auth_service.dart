import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // Initialize GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  GoogleAuthService() {
    // GoogleSignIn is initialized above
  }

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

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google Sign-Out Error: $e');
      rethrow;
    }
  }

  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      print('Google isSignedIn Error: $e');
      return false;
    }
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      print('Google getCurrentUser Error: $e');
      return null;
    }
  }

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
