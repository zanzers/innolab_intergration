import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  SHARED STORE
//  A simple singleton that both ScheduleScreen
//  and MaintenanceScreen read and write.
//  No external packages needed.
// ─────────────────────────────────────────────

/// Represents a maintenance task visible in BOTH
/// the Schedule screen and the Maintenance → Schedule tab.
class SharedMaintenanceTask {
  final String id;
  String title;
  String notes;
  String assignedTo;
  String machineName;
  String machineId;
  DateTime scheduledDate;
  DateTime endDate;
  SharedTaskStatus status;
  Duration estimatedDuration;

  SharedMaintenanceTask({
    required this.id,
    required this.title,
    required this.notes,
    required this.assignedTo,
    required this.machineName,
    required this.machineId,
    required this.scheduledDate,
    required this.endDate,
    required this.status,
    required this.estimatedDuration,
  });
}

enum SharedTaskStatus { upcoming, inProgress, completed, overdue, canceled }

/// Singleton store — call AppScheduleStore.instance anywhere.
class AppScheduleStore extends ChangeNotifier {
  AppScheduleStore._();
  static final AppScheduleStore instance = AppScheduleStore._();

  final List<SharedMaintenanceTask> _tasks = [];

  List<SharedMaintenanceTask> get tasks => List.unmodifiable(_tasks);

  // ── Called from ScheduleScreen when a maintenance event is saved ──
  void addOrUpdateFromSchedule(SharedMaintenanceTask task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) {
      _tasks.add(task);
    } else {
      _tasks[idx] = task;
    }
    notifyListeners();
  }

  // ── Called from ScheduleScreen when a maintenance event is deleted ──
  void removeById(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ── Called from MaintenanceScreen to update status ──
  void updateStatus(String id, SharedTaskStatus status) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tasks[idx].status = status;
      notifyListeners();
    }
  }
}