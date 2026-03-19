import 'package:flutter/material.dart';
import 'package:innolab/src/features/auth/marcelo_login/screens/user_register_mobile.dart';
import 'package:innolab/src/features/auth/marcelo_login/screens/user_register_web.dart';

class UserRegisterScreen extends StatelessWidget {
  const UserRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              return const UserRegisterWeb();
            }
            return const UserRegisterMobile();
          },
        ),
      ),
    );
  }
}