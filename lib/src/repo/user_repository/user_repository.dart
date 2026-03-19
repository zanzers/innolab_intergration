import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/route_manager.dart';
import 'package:innolab/src/features/auth/models/user_model.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';



class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

      Future<void> createUser(UserModel user) async {
        try {
          final docRef = user.id != null
              ? _db.collection(DatabaseTable.user).doc(user.id)
              : _db.collection(DatabaseTable.user).doc();

          final jsonData = user.toJson();
          print('[DEBUG] JSON being written: $jsonData');

          await docRef.set(jsonData);

          print('[DEBUG] User created with ID: ${docRef.id}');
        } catch (e) {
          print('[ERROR] Failed to create user: $e');
          rethrow;
        }
      }
  }
