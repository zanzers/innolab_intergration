import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:innolab/utils/constant/enum_serialization.dart';
import 'package:innolab/utils/constant/enums.dart';


@immutable
class ScheduleEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final EventStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final String? assignedStaff;
  final String? relatedUser;
  final String? machine;
  final String? location;
  final String? linkedId;
  final bool isAdminTask;
  final bool isEditable;

  const ScheduleEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.assignedStaff,
    this.relatedUser,
    this.machine,
    this.location,
    this.linkedId,
    this.isAdminTask = false,
    this.isEditable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.value,
      'status': status.value,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'assignedStaff': assignedStaff,
      'relatedUser': relatedUser,
      'machine': machine,
      'location': location,
      'linkedId': linkedId,
      'isAdminTask': isAdminTask,
      'isEditable': isEditable,
    };
  }

  factory ScheduleEvent.fromMap(Map<String, dynamic> map, String id) {
    DateTime readTs(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return ScheduleEvent(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: EventTypeX.fromString(map['type'] as String?),
      status: EventStatusX.fromString(map['status'] as String?),
      startTime: readTs(map['startTime']),
      endTime: readTs(map['endTime']),
      assignedStaff: map['assignedStaff'] as String?,
      relatedUser: map['relatedUser'] as String?,
      machine: map['machine'] as String?,
      location: map['location'] as String?,
      linkedId: map['linkedId'] as String?,
      isAdminTask: map['isAdminTask'] as bool? ?? false,
      isEditable: map['isEditable'] as bool? ?? true,
    );
  }

  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    EventStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    String? assignedStaff,
    String? relatedUser,
    String? machine,
    String? location,
    String? linkedId,
    bool? isAdminTask,
    bool? isEditable,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      relatedUser: relatedUser ?? this.relatedUser,
      machine: machine ?? this.machine,
      location: location ?? this.location,
      linkedId: linkedId ?? this.linkedId,
      isAdminTask: isAdminTask ?? this.isAdminTask,
      isEditable: isEditable ?? this.isEditable,
    );
  }
}
