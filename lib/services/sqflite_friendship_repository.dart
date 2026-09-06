import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/friendship_model.dart';
import 'friendship_repository.dart';

class SqfliteFriendshipRepository implements FriendshipRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  @override
  Future<FriendshipModel> sendRequest(String requesterUid, String receiverUid) async {
    final db = await _db;
    final friendship = FriendshipModel(
      id: FriendshipModel.UNSAVED_ID,
      requesterUid: requesterUid,
      receiverUid: receiverUid,
      status: FriendshipStatus.pending,
      createdAt: DateTime.now(),
    );
    final id = await db.insert('friendships', friendship.toMap());
    return FriendshipModel(
      id: id,
      requesterUid: friendship.requesterUid,
      receiverUid: friendship.receiverUid,
      status: friendship.status,
      createdAt: friendship.createdAt,
    );
  }

  @override
  Future<void> respondToRequest(int friendshipId, {required bool accept}) async{
    final db = await _db;
    if (accept) {
      await db.update(
        'friendships',
        {'status': FriendshipStatus.accepted.name},
        where: 'id = ?',
        whereArgs: [friendshipId],
      );
    } else {
      await db.delete('friendships', where: 'id = ?', whereArgs: [friendshipId]);
    }
  }

  @override
  Future<void> removeFriend(int friendshipId) async {
    final db = await _db;
    await db.delete('friendships', where: 'id = ?', whereArgs: [friendshipId]);
  }

  @override
  Future<FriendshipModel?> statusBetween(String uidA, String uidB) async {
    final db = await _db;
    final rows = await db.query(
      'friendships',
      where: '(requesterUid = ? AND receiverUid = ?) OR (requesterUid = ? AND receiverUid = ?)',
      whereArgs: [uidA, uidB, uidB, uidA],
    );
    if (rows.isEmpty) return null;
    return FriendshipModel.fromMap(rows.first);
  }

  @override
  Future<List<FriendshipModel>> friendsOf(String uid) async {
    final db = await _db;
    final rows = await db.query(
      'friendships',
      where: '(requesterUid = ? OR receiverUid = ?) AND status = ?',
      whereArgs: [uid, uid, FriendshipStatus.accepted.name],
    );
    return rows.map(FriendshipModel.fromMap).toList();
  }

  @override
  Future<List<FriendshipModel>> pendingReceivedBy(String uid) async {
    final db = await _db;
    final rows = await db.query(
      'friendships',
      where: 'receiverUid = ? AND status = ?',
      whereArgs: [uid, FriendshipStatus.pending.name],
    );
    return rows.map(FriendshipModel.fromMap).toList();
  }

  @override
  Future<List<FriendshipModel>> pendingSentBy(String uid) async {
    final db = await _db;
    final rows = await db.query(
      'friendships',
      where: 'requesterUid = ? AND status = ?',
      whereArgs: [uid, FriendshipStatus.pending.name],
    );
    return rows.map(FriendshipModel.fromMap).toList();
  }
}