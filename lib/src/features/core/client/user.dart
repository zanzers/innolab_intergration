import 'package:flutter/material.dart';

class AUserHome extends StatelessWidget {
  const AUserHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Home')),
      body: const Center(
        child: Text(
          'Client Home',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}