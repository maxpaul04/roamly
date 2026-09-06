class UserModel {
  final String uid; // This matches the firebase Id
  final String email;
  final String userName;

  UserModel({
    required this.uid,
    required this.email,
    required this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userName': userName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: (map['email'] ?? '') as String,
      userName: (map['username'] ?? 'Unknown User') as String,
    );
  }
}
