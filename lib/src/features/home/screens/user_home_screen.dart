import 'package:flutter/material.dart';
import 'package:innolab/src/features/home/screens/user_home_mobile.dart';
import 'package:innolab/src/features/home/screens/user_home_web.dart';


class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return const UserHomeWeb();
        }
        return const UserHomeMobile();
      },
    );
  }
}