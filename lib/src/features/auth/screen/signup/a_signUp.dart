import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:innolab/src/features/models/user_model.dart';
import 'package:innolab/src/repo/user_repository/user_repository.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    Get.put(UserRepository());

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                try {
                  final auth = FirebaseAuth.instance;

                  final userCredential =
                      await auth.createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  await userCredential.user!.reload();

                  final uid = auth.currentUser!.uid;

                  final user = UserModel(
                    id: uid,
                    fullName: fullNameController.text.trim(),
                    email: emailController.text.trim(),
                    role: 'client',
                    level: 1,
                  );

                  final userRepo = Get.find<UserRepository>();
                  await userRepo.createUser(user);

                  Get.snackbar("Success", "Account created successfully");

                } catch (e) {
                  print('SignUp Error: $e');

                  Get.snackbar("ERROR", e.toString());
                }
              },
              child: const Text("Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}