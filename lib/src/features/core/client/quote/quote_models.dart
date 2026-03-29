import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ─────────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────────
enum MaterialCategory { thermoplastics, resins, metals, composites, ceramics }

enum PrinterStatus { available, busy, underMaintenance }

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
class BuildVolume {
  final double width, depth, height;
  const BuildVolume(this.width, this.depth, this.height);
}

class PrinterModel {
  final String id, name;
  final double hourlyRate;
  final PrinterStatus status;
  final BuildVolume buildVolume;
  final double speedFactor;

  const PrinterModel({
    required this.id,
    required this.name,
    required this.hourlyRate,
    required this.status,
    this.buildVolume = const BuildVolume(250, 250, 250),
    this.speedFactor = 1,
  });
}

class MaterialCategoryInfo {
  /// Normalized key for filter (e.g. lowercase trim).
  final String key;
  final MaterialCategory category;
  /// Label from Firestore (e.g. Filament, Resin).
  final String name, exampleMaterials;
  final IconData icon;
  final Color color;

  const MaterialCategoryInfo({
    required this.key,
    required this.category,
    required this.name,
    required this.icon,
    required this.color,
    required this.exampleMaterials,
  });
}

class MaterialOption {
  final String id, name, fullName, description;
  /// Raw category from DB (e.g. filament, resin) for display.
  final String categoryLabel;
  final MaterialCategory category;
  final double hourlyRate, ratePerGram, density;
  final List<String>? surfaceFinishes, tolerances, layerOptions;
  final int stockQuantity;
  final bool isAvailable;

  const MaterialOption({
    required this.id,
    required this.name,
    required this.fullName,
    required this.categoryLabel,
    required this.category,
    required this.description,
    required this.hourlyRate,
    required this.ratePerGram,
    this.surfaceFinishes,
    this.tolerances,
    this.layerOptions,
    required this.density,
    this.stockQuantity = 0,
    this.isAvailable = true,
  });
}

class QuoteItem {
  final String id;
  final MaterialOption material;
  final double grams, hours;
  final int quantity;
  final String? selectedFinish, selectedTolerance, selectedLayer;

  QuoteItem({
    required this.id,
    required this.material,
    required this.grams,
    required this.hours,
    this.quantity = 1,
    this.selectedFinish,
    this.selectedTolerance,
    this.selectedLayer,
  });

  double get materialCost => grams * material.ratePerGram;
  double get laborCost => hours * material.hourlyRate;
  double get totalCost => (materialCost + laborCost) * quantity;
}

/// Snapshot of the estimation summary + user, for Firestore [DatabaseTable.quoteRequests].
class QuoteRequestPayload {
  const QuoteRequestPayload({
    required this.userId,
    this.userEmail,
    this.userFullName,
    this.modelFileName,
    this.estimatedVolumeCm3,
    this.estimatedPrintTimeHours,
    this.modelWidthMm,
    this.modelDepthMm,
    this.modelHeightMm,
    this.triangleCount,
    this.modelSizeWarning,
    this.printerId,
    this.printerName,
    this.printerHourlyRate,
    this.printerStatus,
    required this.materialId,
    required this.materialName,
    required this.categoryLabel,
    required this.materialCategoryKey,
    required this.grams,
    required this.hours,
    required this.quantity,
    this.selectedFinish,
    this.selectedTolerance,
    this.selectedLayer,
    required this.materialCost,
    required this.machineCost,
    required this.electricityCost,
    required this.serviceFee,
    required this.subtotalPerUnit,
    this.discountType,
    required this.discountAmount,
    required this.grandTotal,
    this.discountIdUploadName,
    this.paymentNote = 'Pay at Admin Office',
  });

  final String userId;
  final String? userEmail;
  final String? userFullName;

  final String? modelFileName;
  final double? estimatedVolumeCm3;
  final double? estimatedPrintTimeHours;
  final double? modelWidthMm;
  final double? modelDepthMm;
  final double? modelHeightMm;
  final int? triangleCount;
  final String? modelSizeWarning;

  final String? printerId;
  final String? printerName;
  final double? printerHourlyRate;
  final String? printerStatus;

  final String materialId;
  final String materialName;
  final String categoryLabel;
  final String materialCategoryKey;

  final double grams;
  final double hours;
  final int quantity;
  final String? selectedFinish;
  final String? selectedTolerance;
  final String? selectedLayer;

  final double materialCost;
  final double machineCost;
  final double electricityCost;
  final double serviceFee;
  final double subtotalPerUnit;
  final String? discountType;
  final double discountAmount;
  final double grandTotal;

  final String? discountIdUploadName;
  final String paymentNote;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userFullName': userFullName,
      'model': {
        'fileName': modelFileName,
        'volumeCm3': estimatedVolumeCm3,
        'printTimeHours': estimatedPrintTimeHours,
        'widthMm': modelWidthMm,
        'depthMm': modelDepthMm,
        'heightMm': modelHeightMm,
        'triangleCount': triangleCount,
        'sizeWarning': modelSizeWarning,
      },
      'printer': printerId == null
          ? null
          : {
              'id': printerId,
              'name': printerName,
              'hourlyRate': printerHourlyRate,
              'status': printerStatus,
            },
      'material': {
        'id': materialId,
        'name': materialName,
        'categoryLabel': categoryLabel,
        'category': materialCategoryKey,
      },
      'line': {
        'grams': grams,
        'hours': hours,
        'quantity': quantity,
        'finish': selectedFinish,
        'tolerance': selectedTolerance,
        'layer': selectedLayer,
      },
      'pricing': {
        'material': materialCost,
        'machine': machineCost,
        'electricity': electricityCost,
        'serviceFee': serviceFee,
        'subtotalPerUnit': subtotalPerUnit,
        'discountType': discountType,
        'discountAmount': discountAmount,
        'grandTotal': grandTotal,
      },
      'discountIdUploadName': discountIdUploadName,
      'paymentNote': paymentNote,
      'status': 'pending',
    };
  }
}

// ─────────────────────────────────────────────
//  Category display (shared by UI + catalog loader)
// ─────────────────────────────────────────────
extension MaterialCategoryQuoteDisplay on MaterialCategory {
  String get quoteTitle => switch (this) {
        MaterialCategory.thermoplastics => 'Thermoplastics',
        MaterialCategory.resins => 'Resins',
        MaterialCategory.metals => 'Metals',
        MaterialCategory.composites => 'Composites',
        MaterialCategory.ceramics => 'Ceramics',
      };

  Color get quoteColor => switch (this) {
        MaterialCategory.thermoplastics => const Color(0xFF1E88E5),
        MaterialCategory.resins => const Color(0xFFFF8F00),
        MaterialCategory.metals => const Color(0xFF546E7A),
        MaterialCategory.composites => const Color(0xFF43A047),
        MaterialCategory.ceramics => const Color(0xFF8D6E63),
      };

  IconData get quoteIcon => switch (this) {
        MaterialCategory.thermoplastics => Iconsax.box,
        MaterialCategory.resins => Iconsax.drop,
        MaterialCategory.metals => Iconsax.setting,
        MaterialCategory.composites => Iconsax.layer,
        MaterialCategory.ceramics => Iconsax.lamp,
      };
}
