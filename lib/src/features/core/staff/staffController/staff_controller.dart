import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:innolab/src/features/models/user_model.dart';

class StaffController extends GetxController {
  static StaffController get instance => Get.find();

  final Rx<UserModel?> _user = Rx<UserModel?>(null);

  UserModel? get user => _user.value;

  bool get isLoading => _user.value == null;

  String get fullName {
    final name = _user.value?.fullName ?? '';
    print('StaffController.fullName accessed: "$name"');
    return name;
  }

  /// Display-friendly role (e.g. `Staff`), empty if not loaded.
  String get roleDisplay {
    final r = _user.value?.role ?? '';
    final display = r.isEmpty
        ? ''
        : r[0].toUpperCase() + r.substring(1).toLowerCase();
    print('StaffController.roleDisplay accessed: "$display" (raw: "$r")');
    return display;
  }

  void setUser(UserModel user) {
    print(
      'StaffController.setUser called with: ${user.fullName}, role: ${user.role}',
    );
    _user.value = user;
  }

  void clearUser() {
    _user.value = null;
  }
}
