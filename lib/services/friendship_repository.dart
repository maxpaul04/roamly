import 'package:roamly/models/friendship_model.dart';

abstract class FriendshipRepository {
  Future<FriendshipModel> sendRequest(String requesterUid, String receiverUid);
  Future<void> respondToRequest(int friendshipId, {required bool accept});
  Future<void> removeFriend(int friendshipId);
  Future<FriendshipModel?> statusBetween(String uidA, String uidB);
  Future<List<FriendshipModel>> friendsOf(String uid);
  Future<List<FriendshipModel>> pendingReceivedBy(String uid);
  Future<List<FriendshipModel>> pendingSentBy(String uid);
}