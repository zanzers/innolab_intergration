import 'package:flutter/material.dart';
import 'admin_login_mobile.dart';
import 'admin_login_web.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 800) {
      return const AdminLoginWeb();
    } 
    else {
      return const AdminLoginMobile();
    }
  }
}