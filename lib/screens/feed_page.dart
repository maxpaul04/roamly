import 'package:flutter/material.dart';
import 'package:roamly/services/city_repository.dart';
import 'package:roamly/services/comment_repository.dart';
import '../models/city_entry_model.dart';
import '../services/friendship_repository.dart';
import '../services/user_repository.dart';
import '../services/wishlist_repository.dart';
import '../widgets/city_entry_card.dart';

class FeedPage extends StatefulWidget {
  final int reloadTrigger;
  final CityRepository cityRepository;
  final CommentRepository commentRepository;
  final UserRepository userRepository;
  final FriendshipRepository friendshipRepository;
  final WishlistRepository wishlistRepository;


  const FeedPage({
    super.key,
    required this.reloadTrigger,
    required this.cityRepository,
    required this.commentRepository,
    required this.userRepository,
    required this.friendshipRepository,
    required this.wishlistRepository,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<CityEntry> _logs = [];
  Map<int, int> _commentCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(FeedPage old) {
    super.didUpdateWidget(old);
    if (old.reloadTrigger != widget.reloadTrigger) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final data = await widget.cityRepository.getAllEntries();
    final ids = data.map((e) => e.id).toList();
    final counts = await widget.commentRepository.getCommentCounts(ids);
    setState(() {
      _logs = data;
      _commentCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('roamly'),
      ),
      body: _logs.isEmpty 
        ? const Center(child: Text('No journeys logged yet.'))
        : ListView(
        padding: const EdgeInsets.all(8),
            children: [
              for (final log in _logs)
                CityEntryCard(
                  log: log,
                  commentCount: _commentCounts[log.id] ?? 0,
                  commentRepository: widget.commentRepository,
                  cityRepository: widget.cityRepository,
                  userRepository: widget.userRepository,
                  friendshipRepository: widget.friendshipRepository,
                  wishlistRepository: widget.wishlistRepository,
                  onCommentsChanged: _loadData,
                ),
            ],
          ),
    );
  }
}
