import 'package:roamly/models/user_model.dart';

abstract class UserRepository {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> deleteUser(String uid);
  Future<bool> isUsernameTaken(String username);
  Future<List<UserModel>> searchUsers(String query, {required String excludeUid});
  Future<void> updateProfilePicture(String uid, String? imagePath);
  Future<void> deleteProfilePicture(String uid);
}
