
import 'package:flutter/material.dart';

@immutable
class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String role;
  final int? level;  // <-- added level

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'level': 1,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      level: json['level'] ?? 1,  
    );
  }
}
