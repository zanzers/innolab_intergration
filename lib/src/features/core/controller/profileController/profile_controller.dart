import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:innolab/src/features/models/user_model.dart';


class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final Rx<UserModel?> _user = Rx<UserModel?>(null);

  UserModel? get user => _user.value;
  String get fullName => _user.value?.fullName ?? "Guest";
  String get role => _user.value?.role.toUpperCase() ?? "Visitor";

  void setUser(UserModel user) {
    _user.value = user;
  }
}
