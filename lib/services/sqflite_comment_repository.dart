import 'package:roamly/database/database_helper.dart';
import 'package:roamly/models/comment_model.dart';
import 'package:roamly/services/comment_repository.dart';

class SqfliteCommentRepository implements CommentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Comment>> getCommentsForEntry(int cityEntryId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'comments',
      where: 'cityEntryId = ?',
      whereArgs: [cityEntryId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((m) => Comment.fromMap(m)).toList();
  }

  @override
  Future<Comment> addComment(Comment comment) async {
    final db = await _dbHelper.database;
    final map = comment.toMap()..remove('id');
    final newId = await db.insert('comments', map);

    return comment.copyWith(id: newId);
  }

  @override
  Future<void> updateComment(Comment comment) async {
    final db = await _dbHelper.database;
    final map = comment.toMap()..remove('id');
    await db.update(
      'comments',
      map,
      where: 'id = ? AND userId = ?',
      whereArgs: [comment.id, comment.userId],
    );
  }

  @override
  Future<void> deleteComment(int id, String userId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'comments',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  @override
  Future<int> getCommentCount(int cityEntryId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM comments WHERE cityEntryId = ?',
      [cityEntryId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  @override
  Future<Map<int, int>> getCommentCounts(List<int> cityEntryIds) async {
    if (cityEntryIds.isEmpty) return {};

    final db = await _dbHelper.database;
    final placeholders = List.filled(cityEntryIds.length, '?').join(',');
    final result = await db.rawQuery(
      'SELECT cityEntryId, COUNT(*) as count FROM comments '
          'WHERE cityEntryId IN ($placeholders) '
          'GROUP BY cityEntryId',
      cityEntryIds,
    );

    return {
      for (final row in result)
        row['cityEntryId'] as int: row['count'] as int,
    };
  }
}