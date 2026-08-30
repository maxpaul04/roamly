import 'package:firebase_auth/firebase_auth.dart';
import 'package:roamly/models/user_model.dart';
import 'package:roamly/services/user_repository.dart';
import 'package:roamly/services/sqflite_user_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = SqfliteUserRepository();

  // Stream to listen to auth state changes (logged in vs logged out)
  Stream<User?> get user => _auth.authStateChanges();

  // Sign up with email, password, and username
  Future<UserCredential?> signUp(String email, String password, String userName) async {
    if (await _userRepository.isUsernameTaken(userName)) {
      throw Exception('Username is already taken');
    }

    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // Update display name in Firebase Auth
      await credential.user?.updateDisplayName(userName);

      // Sync user data to SQFlite
      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email,
        userName: userName,
      );
      await _userRepository.saveUser(newUser);
    }
    return credential;
  }


  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
