import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hardcoded Admin Credentials
  static const String adminEmail = "admin@gmail.com";
  static const String adminPassword = "admin@123";

  Future<String?> login(String email, String password) async {
    try {
      if (email == adminEmail && password == adminPassword) {
        return "admin"; // No Firebase check for hardcoded admin
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "user";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
