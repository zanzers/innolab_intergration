import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:innolab/src/features/auth/controllers/currentUser.dart';
import 'package:innolab/src/features/auth/marcelo_login/screens/user_login_web.dart';
import 'package:innolab/src/features/core/controller/profileController/profile_controller.dart';
import 'package:innolab/src/features/core/staff/staffController/staff_controller.dart';
import 'package:innolab/src/features/models/user_model.dart';
import 'package:innolab/src/features/routing/role_router.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';

class Authwrapper extends StatelessWidget {
  const Authwrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges().distinct(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final user = authSnapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection(DatabaseTable.user)
                .doc(user.uid)
                .get(),

            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('Error fetching data')),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final data = userSnapshot.data!.data() as Map<String, dynamic>;

                final int level = data['level'] ?? 1;
                final String fullName = data['fullName'] ?? '';
                final String role = data['role'] ?? 'client';
                final String email = data['email'] ?? '';

                if (!Get.isRegistered<ProfileController>()) {
                  Get.put(ProfileController(), permanent: true);
                }
                Get.find<ProfileController>().setUser(
                  UserModel(
                    id: user.uid,
                    fullName: fullName,
                    email: email,
                    role: role,
                    level: level,
                  ),
                );

                // Also set user data in StaffController for staff users
                if (role == 'staff') {
                  if (!Get.isRegistered<StaffController>()) {
                    Get.put(StaffController(), permanent: true);
                  }
                  Get.find<StaffController>().setUser(
                    UserModel(
                      id: user.uid,
                      fullName: fullName,
                      email: email,
                      role: role,
                      level: level,
                    ),
                  );
                  print(
                    'AuthWrapper: Set staff user data - name: $fullName, role: $role',
                  );
                }

                CurrentUser().uid = user.uid;
                CurrentUser().fullName = fullName;
                CurrentUser().level = level;
                CurrentUser().email = email;

                return RoleRouter(level: level, fullName: fullName);
              }

              // Fallback if Auth exists but no Firestore Document
              return const Scaffold(
                body: Center(child: Text('User Profile Not Found')),
              );
            },
          );
        }

        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().clearUser();
        }
        return const UserLoginWeb();
      },
    );
  }
}
