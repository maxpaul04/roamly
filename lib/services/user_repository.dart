import 'package:roamly/models/user_model.dart';

abstract class UserRepository {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> deleteUser(String uid);
  Future<bool> isUsernameTaken(String username);
}
