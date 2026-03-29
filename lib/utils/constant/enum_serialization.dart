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

extension EventTypeX on EventType {
  String get value => name;

  static EventType fromString(String? value) {
    if (value == null || value.isEmpty) return EventType.meeting;
    return EventType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventType.meeting,
    );
  }
}

extension EventStatusX on EventStatus {
  String get value => name;

  static EventStatus fromString(String? value) {
    if (value == null || value.isEmpty) return EventStatus.pending;
    return EventStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventStatus.pending,
    );
  }
}