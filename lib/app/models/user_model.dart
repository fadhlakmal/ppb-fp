import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String email;
  final String username;
  final String? imgUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.uid,
    required this.username,
    required this.email,
    this.imgUrl,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'imgUrl': imgUrl,
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
      'updatedAt':
          updatedAt != null
              ? Timestamp.fromDate(updatedAt!)
              : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      imgUrl: data['imgUrl'] ?? '', 
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? imgUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      imgUrl: imgUrl ?? this.imgUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, username: $username, email: $email, imgUrl: $imgUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}