import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';

class AdminHeaderData {
  const AdminHeaderData({
    required this.username,
    required this.role,
  });

  final String username;
  final String role;
}

class AdminController {
  const AdminController();

  Future<AdminHeaderData> fetchAdminHeaderData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const AdminHeaderData(username: 'User', role: 'Unknown');
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(DatabaseTable.user)
          .doc(user.uid)
          .get();

      final data = snapshot.data();
      if (data == null) {
        return const AdminHeaderData(username: 'User', role: 'Loading...');
      }

      return AdminHeaderData(
        username: (data['fullName'] ?? data['username'] ?? 'User').toString(),
        role: (data['role'] ?? 'Loading...').toString(),
      );
    } catch (_) {
      return const AdminHeaderData(username: 'Loading...', role: 'Loading...');
    }
  }
}
