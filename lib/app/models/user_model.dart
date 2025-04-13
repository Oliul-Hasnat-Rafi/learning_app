import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String role; 
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    photoUrl: json['photoUrl'] ?? '',
    role: json['role'] ?? '',
    createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : json['createdAt'] is Timestamp 
            ? (json['createdAt'] as Timestamp).toDate()
            : json['createdAt'] is String 
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
    updatedAt: json['updatedAt'] is DateTime 
        ? json['updatedAt'] 
        : json['updatedAt'] is Timestamp 
            ? (json['updatedAt'] as Timestamp).toDate()
            : json['updatedAt'] is String 
                ? DateTime.parse(json['updatedAt'])
                : DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}