import 'package:innolab/utils/constant/enums.dart';


extension MachineStatusX on MachineStatus {
  String get value => name;

  static MachineStatus fromString(String value) {
    return MachineStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MachineStatus.idle,
    );
  }
}

extension MachineTypeX on MachineType {
  String get value => name;

  static MachineType fromString(String value) {
    return MachineType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MachineType.printer3D,
    );
  }
}