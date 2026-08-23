import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to auth state changes (logged in vs logged out)
  Stream<User?> get user => _auth.authStateChanges();

  // Sign up with email, password, and username
  Future<UserCredential?> signUp(String email, String password, String username) async {
    try {
      // TODO: Implement username uniqueness check against the database before creating the account.
      
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name in Firebase Auth
      await credential.user?.updateDisplayName(username);
      
      // TODO: Sync user data to SQFlite using credential.user!.uid and the provided username.
      
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
