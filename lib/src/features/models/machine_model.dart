import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:innolab/utils/constant/enum_serialization.dart';
import 'package:innolab/utils/constant/enums.dart';


@immutable
class MachineModel {
  final String id, name, model, location;
  final MachineType type;
  final MachineStatus status;
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;
  final String assignedTech;
  final double uptimePercent;
  final int totalJobs;
  final String? currentJob;
  final String? currentOperator;
  final String? reservedBy;
  final List<String> compatibleMaterials;

  const MachineModel({
    required this.id, required this.name, required this.model,
    required this.location, required this.type, required this.status,
    required this.lastMaintenance, required this.nextMaintenance,
    required this.assignedTech, required this.uptimePercent,
    required this.totalJobs, this.currentJob,
    this.currentOperator, this.reservedBy,
    this.compatibleMaterials = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "model": model,
      "location": location,
      "type": type.value,
      "status": status.value,
      "lastMaintenance": lastMaintenance,
      "nextMaintenance": nextMaintenance,
      "assignedTech": assignedTech,
      "uptimePercent": uptimePercent,
      "totalJobs": totalJobs,
      "currentJob": currentJob,
      "currentOperator": currentOperator,
      "reservedBy": reservedBy,
      "compatibleMaterials": compatibleMaterials,
    };
  }

  factory MachineModel.fromMap(Map<String, dynamic> map, String id) {
    return MachineModel(
      id: id,
      name: map["name"] ?? "",
      model: map["model"] ?? "",
      location: map["location"] ?? "",
      type: MachineTypeX.fromString(map["type"]),
      status: MachineStatusX.fromString(map["status"]),
      lastMaintenance: (map["lastMaintenance"] as Timestamp).toDate(),
      nextMaintenance: (map["nextMaintenance"] as Timestamp).toDate(),
      assignedTech: map["assignedTech"] ?? "",
      uptimePercent: (map["uptimePercent"] ?? 0).toDouble(),
      totalJobs: map["totalJobs"] ?? 0,
      currentJob: map["currentJob"],
      currentOperator: map["currentOperator"],
      reservedBy: map["reservedBy"],
      compatibleMaterials: List<String>.from(map["compatibleMaterials"] ?? []),
    );
  }


  MachineModel copyWith({
    String? id, String? name, String? model, String? location,
    MachineType? type, MachineStatus? status,
    DateTime? lastMaintenance, DateTime? nextMaintenance,
    String? assignedTech, double? uptimePercent, int? totalJobs,
    String? currentJob, String? currentOperator, String? reservedBy,
    List<String>? compatibleMaterials,
  }) {

    return MachineModel(
      id: id ?? this.id, name: name ?? this.name, model: model ?? this.model,
      location: location ?? this.location, type: type ?? this.type,
      status: status ?? this.status,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      nextMaintenance: nextMaintenance ?? this.nextMaintenance,
      assignedTech: assignedTech ?? this.assignedTech,
      uptimePercent: uptimePercent ?? this.uptimePercent,
      totalJobs: totalJobs ?? this.totalJobs,
      currentJob: currentJob ?? this.currentJob,
      currentOperator: currentOperator ?? this.currentOperator,
      reservedBy: reservedBy ?? this.reservedBy,
      compatibleMaterials: compatibleMaterials ?? this.compatibleMaterials,
    );
  }
}