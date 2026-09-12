class Comment {
  static const UNSAVED_ID = 0;

  final int id;
  final int cityEntryId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.cityEntryId,
    required this.userId,
    required this.userName,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityEntryId': cityEntryId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as int,
      cityEntryId: map['cityEntryId'] as int,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      text: map['text'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Comment copyWith({
    int? id,
    String? text,
}) {
    return Comment(
      id: id ?? this.id,
      cityEntryId: cityEntryId,
      userId: userId,
      userName: userName,
      text: text ?? this.text,
      createdAt: createdAt,
    );
  }
}