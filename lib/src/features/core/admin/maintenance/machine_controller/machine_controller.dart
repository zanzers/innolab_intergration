import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:innolab/src/features/models/machine_model.dart';
import 'package:innolab/src/repo/machine_repository/machine_repository.dart';


class MachineController extends GetxController {
  static MachineController get instance => Get.find();

  final MachineRepository _repo = MachineRepository();

  RxList<MachineModel> machines = <MachineModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMachines();
  }

  void fetchMachines() {
    isLoading.value = true;

    _repo.getMachines().listen((data) {
      machines.assignAll(data);
      isLoading.value = false;
    });
  }

  Future<void> addMachine(MachineModel machine) async {
    try {
      await _repo.addMachine(machine);
    } catch (e) {
      print("Add Machine Error: $e");
    }
  }

  Future<void> updateMachine(MachineModel machine) async {
    try {
      await _repo.updateMachine(machine);
    } catch (e) {
      print("Update Machine Error: $e");
    }
  }

  Future<void> deleteMachine(String id) async {
    try {
      await _repo.deleteMachine(id);
    } catch (e) {
      print("Delete Machine Error: $e");
    }
  }
}