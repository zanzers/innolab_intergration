import 'package:flutter/material.dart';
import 'package:innolab/src/features/auth/marcelo_login/screens/user_login_mobile.dart';
import 'package:innolab/src/features/auth/marcelo_login/screens/user_login_web.dart';

class UserLoginScreen extends StatelessWidget {
  const UserLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return const UserLoginWeb();
        }
        return const UserLoginMobile();
      },
    );
  }
}