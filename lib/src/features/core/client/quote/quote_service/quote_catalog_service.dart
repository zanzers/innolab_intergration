import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innolab/src/features/core/client/quote/quote_models.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';

class QuoteCatalogResult {
  final List<PrinterModel> printers;
  final List<MaterialOption> materials;
  final List<MaterialCategoryInfo> categories;

  QuoteCatalogResult({
    required this.printers,
    required this.materials,
    required this.categories,
  });
}

class QuoteService {
  static Future<QuoteCatalogResult> loadCatalog() async {
    final db = FirebaseFirestore.instance;

    final results = await Future.wait([
      db.collection(DatabaseTable.machine).get(),
      db.collection(DatabaseTable.materials).get(),
    ]);

    final machineSnap = results[0];
    final matSnap = results[1];

    final printers = machineSnap.docs.map(_docToPrinter).toList();

    final materials = matSnap.docs
        .map(_docToMaterial)
        .whereType<MaterialOption>()
        .toList();

    final categories = _buildMaterialCategories(materials);

    return QuoteCatalogResult(
      printers: printers,
      materials: materials,
      categories: categories,
    );
  }

  static MaterialCategory _parseMaterialCategory(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.contains('resin')) return MaterialCategory.resins;
    if (s.contains('metal')) return MaterialCategory.metals;
    if (s.contains('composite')) return MaterialCategory.composites;
    if (s.contains('ceramic')) return MaterialCategory.ceramics;
    if (s.contains('thermo') ||
        s.contains('pla') ||
        s.contains('filament') ||
        s == 'plastic') {
      return MaterialCategory.thermoplastics;
    }
    return MaterialCategory.thermoplastics;
  }

  static PrinterStatus _mapMachineStatusToPrinterStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'operational':
      case 'idle':
        return PrinterStatus.available;
      case 'undermaintenance':
      case 'broken':
        return PrinterStatus.underMaintenance;
      default:
        return PrinterStatus.busy;
    }
  }

  static BuildVolume _parseBuildVolume(Map<String, dynamic> m) {
    final nested = m['buildVolume'];
    if (nested is Map) {
      return BuildVolume(
        _asDouble(nested['width'], 250),
        _asDouble(nested['depth'], 250),
        _asDouble(nested['height'], 250),
      );
    }
    return BuildVolume(
      _asDouble(m['buildWidth'], 250),
      _asDouble(m['buildDepth'], 250),
      _asDouble(m['buildHeight'], 250),
    );
  }

  static PrinterModel _docToPrinter(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data();
    return PrinterModel(
      id: doc.id,
      name: m['name'] ?? 'Printer',
      hourlyRate: _pickDouble(m, ['hourlyRate'], 90),
      status: _mapMachineStatusToPrinterStatus(m['status'] ?? ''),
      buildVolume: _parseBuildVolume(m),
      speedFactor: _asDouble(m['speedFactor'], 1),
    );
  }

  static String _pickMaterialDisplayName(Map<String, dynamic> m) {
    for (final key in ['name', 'materialName', 'title', 'label']) {
      final v = m[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  static MaterialOption? _docToMaterial(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data();

    final name = _pickMaterialDisplayName(m);
    if (name.isEmpty) return null;

    // Check for quantity in multiple possible field names
    final qty = _pickInt(m, [
      'stock',
      'quantity',
      'stockQuantity',
      'available',
    ], 0);

    // Also check for explicit 'avail' or 'available' boolean field
    bool? explicitAvail = m['avail'] as bool?;
    if (explicitAvail == null && m.containsKey('available')) {
      final availValue = m['available'];
      if (availValue is bool) explicitAvail = availValue;
    }

    // Material is available if: explicit avail flag is true, OR quantity > 0

    return MaterialOption(
      id: doc.id,
      name: name,
      fullName: name,
      categoryLabel: 'General',
      category: MaterialCategory.thermoplastics,
      description: m['description'] ?? '',
      hourlyRate: _pickDouble(m, ['hourlyRate'], 50),
      ratePerGram: _pickDouble(m, ['ratePerGram'], 0.01),
      stockQuantity: qty,
      density: 0,
    );
  }

  static List<MaterialCategoryInfo> _buildMaterialCategories(
    List<MaterialOption> mats,
  ) {
    final map = <String, List<MaterialOption>>{};

    for (final m in mats) {
      final key = m.categoryLabel.toLowerCase();
      map.putIfAbsent(key, () => []).add(m);
    }

    return map.entries.map((e) {
      final first = e.value.first;

      return MaterialCategoryInfo(
        key: e.key,
        category: first.category,
        name: first.categoryLabel,
        icon: first.category.quoteIcon,
        color: first.category.quoteColor,
        exampleMaterials: e.value.map((x) => x.name).take(5).join(', '),
      );
    }).toList();
  }

  static int _pickInt(Map<String, dynamic> m, List<String> keys, int def) {
    for (final k in keys) {
      if (m.containsKey(k) && m[k] != null) {
        return _asInt(m[k], def);
      }
    }
    return def;
  }

  static double _pickDouble(
    Map<String, dynamic> m,
    List<String> keys,
    double def,
  ) {
    for (final k in keys) {
      if (m.containsKey(k) && m[k] != null) {
        return _asDouble(m[k], def);
      }
    }
    return def;
  }

  static int _asInt(dynamic v, [int def = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? def;
  }

  static double _asDouble(dynamic v, [double def = 0]) {
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? def;
  }
}
