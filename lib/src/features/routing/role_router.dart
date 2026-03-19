import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innolab/src/features/core/admin/home/screens/admin_home_web.dart';
import 'package:innolab/src/features/core/staff/home/screens/staff_home_tab.dart';
import 'package:innolab/src/features/home/screens/user_home_web.dart';


class RoleRouter extends StatelessWidget {
  final int level;
  final String? fullName;

  const RoleRouter({super.key, required this.level, this.fullName});

  @override
  Widget build(BuildContext context) {
    // Store in CurrentUser singleton
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CurrentUser().uid = user.uid;
      CurrentUser().email = user.email ?? '';
      CurrentUser().fullName = fullName ?? '';
      CurrentUser().level = level;
    }

    print("Routing Role: ($level),  $CurrentUser.role");

    switch (level) {
      case 3:
        return AdminHomeWeb();
      case 2:
        return StaffHomeTab();
      default:
        return UserHomeWeb();
    }
  }
}

class CurrentUser {
  static final CurrentUser _instance = CurrentUser._internal();
  factory CurrentUser() => _instance;
  CurrentUser._internal();

  String uid = '';
  String email = '';
  String fullName = '';
  int level = 1;
}
