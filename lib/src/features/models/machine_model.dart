import 'package:flutter/material.dart';
import 'material_model.dart';


@immutable

class MachineModel {
  final String id;
  final String name;
  final String description;
  final List<MaterialOption> materials;

  const MachineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.materials,
  });

  MachineModel copyWith({
    String? id,
    String? name,
    String? description,
    List<MaterialOption>? materials,
  }) {
    return MachineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      materials: materials ?? this.materials,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'materials': materials.map((m) => m.toMap()).toList(),
    };
  }

  /// Create from Map (from backend)
  factory MachineModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MachineModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      materials: map['materials'] != null
          ? List<MaterialOption>.from(
              (map['materials'] as List)
                  .map((m) => MaterialOption.fromMap(
                        m as Map<String, dynamic>,
                        (m)['id'] ?? '',
                      )),
            )
          : [],
    );
  }
}