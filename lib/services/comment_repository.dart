import 'package:roamly/models/comment_model.dart';

abstract class CommentRepository {
  Future<List<Comment>> getCommentsForEntry(int cityEntryId);
  Future<Comment> addComment(Comment comment);
  Future<void> updateComment(Comment comment);
  Future<void> deleteComment(int id, String userId);
  Future<int> getCommentCount(int cityEntryId);
  Future<Map<int, int>> getCommentCounts(List<int> cityEntryIds);
}