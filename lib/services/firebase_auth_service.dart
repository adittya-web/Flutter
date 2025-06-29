import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String backendUrl = 'http://your-laravel-domain.com/api';

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Kirim ke Laravel backend
      await _syncWithBackend(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  Future<void> _syncWithBackend(User user) async {
    try {
      // Get Firebase ID token
      final idToken = await user.getIdToken();

      // Kirim ke Laravel
      final response = await http.post(
        Uri.parse('$backendUrl/auth/firebase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebase_token': idToken,
          'name': user.displayName,
          'email': user.email,
          'photo_url': user.photoURL,
        }),
      );

      print('Backend sync status: ${response.statusCode}');
    } catch (e) {
      print('Backend sync error: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
