import 'package:flutter/material.dart';

@immutable
class InventoryModel {
    final String id;
    final String materialName;
    final String brand;
    final String category;
    final String unit;

    final double currentQuantity;

    final double costPerUnit;
    final double costPerHour;

    final String supplier;


    const InventoryModel({
        required this.id,
        required this.materialName,
        required this.brand,
        required this.category,
        required this.unit,
        required this.currentQuantity,
        required this.costPerUnit,
        required this.costPerHour,
        required this.supplier,
    });

    factory InventoryModel.empty() {
        return const InventoryModel(
            id: '',
            materialName: '',
            brand: '',
            category: '',
            unit: '',
            currentQuantity: 0,
            costPerUnit: 0,
            costPerHour: 0,
            supplier: '',
        );
    }
    
    InventoryModel copyWith({
        String? id,
        String? materialName,
        String? brand,
        String? category,
        String? unit,
        double? currentQuantity,
        double? costPerUnit,
        double? costPerHour,
        String? supplier,
    }) {
        return InventoryModel(
            id: id ?? this.id,
            materialName: materialName ?? this.materialName,
            brand: brand ?? this.brand,
            category: category ?? this.category,
            unit: unit ?? this.unit,
            currentQuantity: currentQuantity ?? this.currentQuantity,
            costPerUnit: costPerUnit ?? this.costPerUnit,
            costPerHour: costPerHour ?? this.costPerHour,
            supplier: supplier ?? this.supplier,
        );
    }

    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'materialName': materialName,
            'materialNameLower': materialName.trim().toLowerCase(),
            'brand': brand,
            'brandLower': brand.trim().toLowerCase(),
            'category': category,
            'unit': unit,
            'currentQuantity': currentQuantity,
            'costPerUnit': costPerUnit,
            'costPerHour': costPerHour,
            'supplier': supplier,
        };
    }

     factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['id'] ?? '',
      materialName: map['materialName'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      unit: map['unit'] ?? '',
      currentQuantity: (map['currentQuantity'] ?? 0).toDouble(),
      costPerUnit: (map['costPerUnit'] ?? 0).toDouble(),
      costPerHour: (map['costPerHour'] ?? 0).toDouble(),
      supplier: map['supplier'] ?? '',
    );
  }
}