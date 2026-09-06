enum FriendshipStatus{pending, accepted}

class FriendshipModel {
  static const int UNSAVED_ID = 0;

  final int id;
  final String requesterUid;
  final String receiverUid;
  final FriendshipStatus status;
  final DateTime createdAt;

  const FriendshipModel({
    required this.id,
    required this.requesterUid,
    required this.receiverUid,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != UNSAVED_ID) 'id': id,
      'requesterUid': requesterUid,
      'receiverUid': receiverUid,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FriendshipModel.fromMap(Map<String, dynamic> map) {
    return FriendshipModel(
      id: map['id'] as int,
      requesterUid: map['requesterUid'] as String,
      receiverUid: map['receiverUid'] as String,
      status: FriendshipStatus.values.byName(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  FriendshipModel copyWith({FriendshipStatus? status}) {
    return FriendshipModel(
      id: id,
      requesterUid: requesterUid,
      receiverUid: receiverUid,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}