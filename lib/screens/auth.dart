import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // Constructor to configure persistence
  Auth() {
    // Try to set persistence to LOCAL - this will persist the user's login state 
    // across app restarts until they explicitly sign out
    try {
      _firebaseAuth.setPersistence(Persistence.LOCAL);
      print("Firebase persistence set to LOCAL");
    } catch (e) {
      print("Error setting persistence: $e");
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    print("Attempting login with email: $email");
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print("Login successful for user: ${result.user?.uid}");
    return result;
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, 
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}