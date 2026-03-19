import 'package:flutter/material.dart';
import 'admin_home_mobile.dart';
import 'admin_home_web.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 800) {
      return const AdminHomeWeb();
    } else {
      return const AdminHomeMobile();
    }
  }
}