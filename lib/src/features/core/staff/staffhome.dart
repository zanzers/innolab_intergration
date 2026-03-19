import 'package:flutter/material.dart';


class AStaffHome extends StatelessWidget {
  const AStaffHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Home')),
      body: const Center(
        child: Text(
          'Staff Home',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}