import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:innolab/app.dart';
import 'package:innolab/src/features/auth/controllers/auth_controller.dart';
import 'package:innolab/src/repo/user_repository/user_repository.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("FIREBASE INITIALIZED");

  Get.put(UserRepository());
  Get.put(AAuthController());

  runApp(const App());
}

