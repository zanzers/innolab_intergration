import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innolab/src/features/auth/marcelo_login/screens/user_register_screen.dart';
import 'package:innolab/src/features/auth/screen/login/admin_login_screen.dart';
import 'package:innolab/src/features/routing/role_router.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';


class Authwrapper extends StatelessWidget {
  const Authwrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges().distinct(),
      builder: (context, authSnapshot) {

      
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔹 User is logged in
        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;

          print("✅ LOGGED IN: ${user.email}");

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection(DatabaseTable.user)
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {

              // 🔹 Show loading while fetching Firestore data
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError){
                return const Scaffold(body: Center(child: Text('Error fecthing data')));
              }

              final data = userSnapshot.data?.data() as Map<String, dynamic>?;

              print("🔥 FIRESTORE DATA: $data");

              final int level = data?['level'] ?? 1;
              final fullName = data?['fullName'] ?? '';

              return RoleRouter(level: level, fullName: fullName);
            },
          );
        }

        // 🔹 Not logged in
        print("❌ LOGGED OUT");
        // return UserLoginWeb();
        return AdminLoginScreen();
      },
    );
  }
}