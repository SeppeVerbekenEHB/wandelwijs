import 'package:firebase_auth/firebase_auth.dart';

class Auth{
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    User? get currentUser => _firebaseAuth.currentUser;

    Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

    Future<void> signInWithEmailAndPassword(String email, String password) async {
        try {
            await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        } catch (e) {
            throw e;
        }
    }

    Future<void> createUserWithEmailAndPassword(String email, String password) async {
        try {
            await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
        } catch (e) {
            throw e;
        }
    }

    Future<void> signOut() async {
        await _firebaseAuth.signOut();
    }
}