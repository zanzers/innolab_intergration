import 'package:flutter/material.dart';
import 'package:innolab/src/features/home/screens/staff_home_mobile.dart';
import 'package:innolab/src/features/home/screens/staff_home_web.dart';


class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return const StaffHomeWeb();
        }
        return const StaffHomeMobile();
      },
    );
  }
}