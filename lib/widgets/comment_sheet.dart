import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/comment_repository.dart';

class CommentSheet extends StatefulWidget {
  final int cityEntryId;
  final CommentRepository commentRepository;

  const CommentSheet({
    super.key,
    required this.cityEntryId,
    required this.commentRepository,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  List<Comment> _comments = [];
  bool _isLoading = true;

  final _inputController = TextEditingController();
  int? _editingCommentId;
  final _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final data = await widget.commentRepository.getCommentsForEntry(widget.cityEntryId);
    setState(() {
      _comments = data;
      _isLoading = false;
    });
  }

  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final comment = Comment(
      id: Comment.UNSAVED_ID,
      cityEntryId: widget.cityEntryId,
      userId: user.uid,
      userName: user.displayName ?? 'Traveler',
      text: text,
    );

    await widget.commentRepository.addComment(comment);
    _inputController.clear();
    await _loadComments();
  }

  void _startEditing(Comment comment) {
    setState(() {
      _editingCommentId = comment.id;
      _editController.text = comment.text;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingCommentId = null;
      _editController.clear();
    });
  }

  Future<void> _saveEdit(Comment comment) async {
    final newText = _editController.text.trim();
    if (newText.isEmpty) return;

    await widget.commentRepository.updateComment(comment.copyWith(text: newText));
    setState(() {
      _editingCommentId = null;
    });
    await _loadComments();
  }

  void _showDeleteCommentDialog(int commentId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.commentRepository.deleteComment(commentId, userId);
              await _loadComments();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment, String? currentUid) {
    final isOwn = currentUid != null && comment.userId == currentUid;
    final isEditing = _editingCommentId == comment.id;

    if (isEditing) {
      return ListTile(
        title: TextField(
          controller: _editController,
          autofocus: true,
          decoration: const InputDecoration(isDense: true),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, size: 20),
              onPressed: () => _saveEdit(comment),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: _cancelEditing,
            ),
          ],
        ),
      );
    }

    return ListTile(
      title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(comment.text),
      trailing: isOwn
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => _startEditing(comment),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: () => _showDeleteCommentDialog(comment.id, comment.userId),
          ),
        ],
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                  ? const Center(child: Text('No comments yet.'))
                  : ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) =>
                    _buildCommentTile(_comments[index], currentUser?.uid),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      enabled: currentUser != null,
                      decoration: InputDecoration(
                        hintText: currentUser != null ? 'Add a comment...' : 'Log in to comment',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: currentUser != null ? _submitComment : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}