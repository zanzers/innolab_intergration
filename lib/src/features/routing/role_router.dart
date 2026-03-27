import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innolab/src/features/core/admin/home/screens/admin_home_web.dart';
import 'package:innolab/src/features/home/screens/user_home_web.dart';


class RoleRouter extends StatelessWidget {
  final int level;
  final String? fullName;

  const RoleRouter({super.key, required this.level, this.fullName});

  @override
  Widget build(BuildContext context) {
    // We moved the logic out of here to keep the build method pure
    print("Routing Role Level: $level");

    switch (level) {
      case 3:
        return const AdminHomeWeb();
      default:
        return const UserHomeWeb();
    }
  }
}