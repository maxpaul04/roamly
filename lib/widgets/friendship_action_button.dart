import 'package:flutter/material.dart';
import '../models/friendship_model.dart';
import '../themes/colors.dart';

class FriendshipActionButton extends StatelessWidget {
  final FriendshipModel? friendship;
  final String? currentUid;
  final VoidCallback onAdd;
  final Function(bool accept) onRespond;

  const FriendshipActionButton({
    super.key,
    required this.friendship,
    required this.currentUid,
    required this.onAdd,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    if (friendship == null) {
      return TextButton(
        onPressed: onAdd,
        child: const Text('Add'),
      );
    }

    if (friendship!.status == FriendshipStatus.accepted) {
      return const Text(
        'Friends',
        style: TextStyle(color: AppColors.textSecondaryLight),
      );
    }

    if (friendship!.requesterUid == currentUid) {
      return const Text(
        'Pending',
        style: TextStyle(color: AppColors.textSecondaryLight),
      );
    }

    // Incoming pending request
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => onRespond(true),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => onRespond(false),
        ),
      ],
    );
  }
}