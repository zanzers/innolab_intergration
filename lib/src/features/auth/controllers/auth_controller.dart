import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:innolab/src/features/auth/controllers/app_snackBar.dart';
import 'package:innolab/src/features/models/user_model.dart';

import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';
import 'package:innolab/src/repo/user_repository/user_repository.dart';


class AAuthController extends GetxController {
  static AAuthController get instance => Get.find();

  /// Temporary password assigned when an admin creates a staff account (must match [registerStaffByAdmin]).
  static const String staffDefaultTempPassword = 'Innolab_2026';

  static const String _staffRegistrationAppName = 'innolab_staff_registration';

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _userRepo = Get.find<UserRepository>();

  FirebaseAuth get _staffRegistrationAuth =>
      FirebaseAuth.instanceFor(app: Firebase.app(_staffRegistrationAppName));

  Future<void> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.reload();
      final uid = _auth.currentUser!.uid;

      final user = UserModel(
        id: uid,
        fullName: fullName,
        email: email,
        role: 'client',
        level: 1,
      );

      await _userRepo.createUser(user);
      AppSnackbar.success('Success Accout created successfully');

    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Auth error";
    } catch (e) {
      throw "Something went wrong";
    }
  }

  Future<Map<String, dynamic>> logInUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection(DatabaseTable.user)
          .doc(uid)
          .get();

      print('AAuthConttoller : $userDoc');

      if (!userDoc.exists) {
        throw Exception('user not found');
      }

      final data = userDoc.data();
      final role = data?['role'] as String?;
      final fullName = data?['fullName'] as String?;

      if (role == null) {
        throw Exception('User role not found');
      }

      return {'role': role, 'fullName': fullName};
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login failed';
    } catch (e) {
      throw 'Something went wrong';
    }
  }

  Future<String> registerStaffByAdmin({
    required String fullName,
    required String email,
  }) async {
    try {
      final credential = await _staffRegistrationAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: staffDefaultTempPassword,
      );
      final uid = credential.user!.uid;
      await _staffRegistrationAuth.signOut();

      final staff = UserModel(
        id: uid,
        fullName: fullName,
        email: email,
        role: 'staff',
        level: 2,
      );

      await _db.collection(DatabaseTable.user).doc(uid).set({
        ...staff.toJson(),
        'mustChangePassword': true,
      });

      return staffDefaultTempPassword;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw "Something went wrong";
    }
  }

} 
