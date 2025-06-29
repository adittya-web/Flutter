import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  static const String backendUrl = 'http://172.20.10.5/kelompok_mobile/public';

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print("Memulai Google Sign-In...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Login Google dibatalkan oleh user.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      print("Login berhasil: ${userCredential.user?.email}");

      await _syncWithBackend(userCredential.user!);

      return userCredential;
    } catch (e, stack) {
      print('Google Sign In Error: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  Future<void> _syncWithBackend(User user) async {
    try {
      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$backendUrl/api/auth/firebase'),
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

  User? getCurrentUser() => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
