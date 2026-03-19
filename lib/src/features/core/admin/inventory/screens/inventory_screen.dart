import 'package:flutter/material.dart';

part 'inventory_screen_web.dart';
part 'inventory_screen_mobile.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  (shared)
// ─────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFF4F6FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE8ECF4);
  static const indigo = Color(0xFF4F46E5);
  static const indigoLight = Color(0xFFEEF2FF);
  static const emerald = Color(0xFF10B981);
  static const emeraldLight = Color(0xFFD1FAE5);
  static const rose = Color(0xFFF43F5E);
  static const roseLight = Color(0xFFFFE4E6);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const violet = Color(0xFF8B5CF6);
  static const violetLight = Color(0xFFEDE9FE);
  static const sky = Color(0xFF0EA5E9);
  static const skyLight = Color(0xFFE0F2FE);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
}

// ─────────────────────────────────────────────
//  MODELS  (shared)
// ─────────────────────────────────────────────
enum MaterialCategory { filament, resin, powder, sparePart, consumable }
enum StockLevel { critical, low, adequate, overstocked }

class UsageEntry {
  final String projectId;
  final String projectName;
  final double amountUsed;
  final String unit;
  final DateTime usedAt;
  const UsageEntry({
    required this.projectId,
    required this.projectName,
    required this.amountUsed,
    required this.unit,
    required this.usedAt,
  });
}

class ReorderHistory {
  final DateTime orderedAt;
  final double quantity;
  final String unit;
  final double cost;
  final String supplier;
  final String status;
  const ReorderHistory({
    required this.orderedAt,
    required this.quantity,
    required this.unit,
    required this.cost,
    required this.supplier,
    required this.status,
  });
}

class InventoryItem {
  final String id;
  final String name;
  final String brand;
  final MaterialCategory category;
  final String unit;
  final double currentStock;
  final double minStock;
  final double criticalStock;
  final double maxStock;
  final double reorderQty;
  final double costPerUnit;
  final String sku;
  final String location;
  final DateTime lastRestocked;
  final DateTime? expiryDate;
  final Color itemColor;
  final bool autoReorder;
  final String supplier;
  final List<UsageEntry> recentUsage;
  final List<ReorderHistory> reorderHistory;
  final String? compatiblePrinters;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minStock,
    required this.criticalStock,
    required this.maxStock,
    required this.reorderQty,
    required this.costPerUnit,
    required this.sku,
    required this.location,
    required this.lastRestocked,
    this.expiryDate,
    required this.itemColor,
    required this.autoReorder,
    required this.supplier,
    required this.recentUsage,
    required this.reorderHistory,
    this.compatiblePrinters,
  });

  StockLevel get stockLevel {
    if (currentStock <= criticalStock) return StockLevel.critical;
    if (currentStock <= minStock) return StockLevel.low;
    if (currentStock >= maxStock * 0.9) return StockLevel.overstocked;
    return StockLevel.adequate;
  }

  double get stockPercent => (currentStock / maxStock).clamp(0.0, 1.0);

  double get weeklyUsage {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return recentUsage
        .where((u) => u.usedAt.isAfter(cutoff))
        .fold(0.0, (sum, u) => sum + u.amountUsed);
  }
}

// ─────────────────────────────────────────────
//  SAMPLE DATA  (shared)
// ─────────────────────────────────────────────
final List<InventoryItem> kInventory = [
  // ── FILAMENTS ──
  InventoryItem(
    id: 'INV-001', name: 'PLA Filament — Black', brand: 'Bambu Lab',
    category: MaterialCategory.filament, unit: 'rolls',
    currentStock: 3, minStock: 5, criticalStock: 2, maxStock: 20,
    reorderQty: 10, costPerUnit: 320.00, sku: 'BL-PLA-BLK-1KG',
    location: 'Shelf A1', lastRestocked: DateTime.now().subtract(const Duration(days: 12)),
    itemColor: Colors.black87, autoReorder: true, supplier: 'Bambu Lab PH',
    compatiblePrinters: 'Bambu X1, Bambu P1S',
    recentUsage: [
      UsageEntry(projectId: 'JOB-884', projectName: 'bracket_v3_final', amountUsed: 0.8, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(hours: 3))),
      UsageEntry(projectId: 'JOB-877', projectName: 'enclosure_base', amountUsed: 1.2, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(days: 2))),
      UsageEntry(projectId: 'JOB-861', projectName: 'gear_prototype', amountUsed: 0.5, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(days: 4))),
    ],
    reorderHistory: [
      ReorderHistory(orderedAt: DateTime.now().subtract(const Duration(days: 30)), quantity: 10, unit: 'rolls', cost: 3200, supplier: 'Bambu Lab PH', status: 'Delivered'),
    ],
  ),
  InventoryItem(
    id: 'INV-002', name: 'PLA Filament — White', brand: 'Bambu Lab',
    category: MaterialCategory.filament, unit: 'rolls',
    currentStock: 10, minStock: 5, criticalStock: 2, maxStock: 20,
    reorderQty: 10, costPerUnit: 320.00, sku: 'BL-PLA-WHT-1KG',
    location: 'Shelf A2', lastRestocked: DateTime.now().subtract(const Duration(days: 5)),
    itemColor: Colors.white, autoReorder: true, supplier: 'Bambu Lab PH',
    compatiblePrinters: 'Bambu X1, Bambu P1S, Prusa MK4',
    recentUsage: [
      UsageEntry(projectId: 'JOB-891', projectName: 'phone_stand_v2', amountUsed: 0.3, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(hours: 1))),
      UsageEntry(projectId: 'JOB-880', projectName: 'product_mockup', amountUsed: 1.1, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(days: 1))),
    ],
    reorderHistory: [],
  ),
  InventoryItem(
    id: 'INV-003', name: 'PETG Filament — Clear', brand: 'Prusa',
    category: MaterialCategory.filament, unit: 'rolls',
    currentStock: 2, minStock: 4, criticalStock: 1, maxStock: 15,
    reorderQty: 8, costPerUnit: 380.00, sku: 'PR-PETG-CLR-1KG',
    location: 'Shelf A3', lastRestocked: DateTime.now().subtract(const Duration(days: 18)),
    itemColor: Colors.cyan, autoReorder: false, supplier: 'Prusa Research',
    compatiblePrinters: 'Prusa MK4, Creality K1',
    recentUsage: [
      UsageEntry(projectId: 'JOB-891', projectName: 'phone_stand_v2', amountUsed: 0.9, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(hours: 5))),
      UsageEntry(projectId: 'JOB-872', projectName: 'enclosure_lid', amountUsed: 0.7, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(days: 3))),
    ],
    reorderHistory: [],
  ),
  InventoryItem(
    id: 'INV-004', name: 'ABS Filament — Grey', brand: 'eSUN',
    category: MaterialCategory.filament, unit: 'rolls',
    currentStock: 7, minStock: 4, criticalStock: 2, maxStock: 16,
    reorderQty: 8, costPerUnit: 295.00, sku: 'ES-ABS-GRY-1KG',
    location: 'Shelf A4', lastRestocked: DateTime.now().subtract(const Duration(days: 8)),
    itemColor: Colors.grey, autoReorder: true, supplier: 'eSUN Philippines',
    compatiblePrinters: 'Voron 2.4, Bambu X1 (AMS)',
    recentUsage: [
      UsageEntry(projectId: 'JOB-895', projectName: 'industrial_clamp', amountUsed: 1.5, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(hours: 1))),
    ],
    reorderHistory: [],
  ),
  InventoryItem(
    id: 'INV-005', name: 'TPU Filament — Blue', brand: 'Bambu Lab',
    category: MaterialCategory.filament, unit: 'rolls',
    currentStock: 1, minStock: 3, criticalStock: 1, maxStock: 10,
    reorderQty: 5, costPerUnit: 490.00, sku: 'BL-TPU-BLU-1KG',
    location: 'Shelf A5', lastRestocked: DateTime.now().subtract(const Duration(days: 22)),
    itemColor: Colors.blue, autoReorder: false, supplier: 'Bambu Lab PH',
    compatiblePrinters: 'Bambu X1, Prusa MK4',
    recentUsage: [
      UsageEntry(projectId: 'JOB-888', projectName: 'phone_case_prototype', amountUsed: 0.6, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(days: 1))),
    ],
    reorderHistory: [],
  ),
  InventoryItem(
    id: 'INV-006', name: 'Carbon Fibre PLA — Black', brand: 'Bambu Lab',
    category: MaterialCategory.filament, unit: 'rolls',
    currentStock: 4, minStock: 3, criticalStock: 1, maxStock: 12,
    reorderQty: 6, costPerUnit: 780.00, sku: 'BL-CFPLA-BLK-1KG',
    location: 'Shelf A6', lastRestocked: DateTime.now().subtract(const Duration(days: 3)),
    itemColor: const Color(0xFF2D2D2D), autoReorder: true, supplier: 'Bambu Lab PH',
    compatiblePrinters: 'Bambu X1 only (hardened nozzle)',
    recentUsage: [
      UsageEntry(projectId: 'JOB-885', projectName: 'drone_frame_v7', amountUsed: 1.0, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(days: 1))),
    ],
    reorderHistory: [],
  ),
  // ── RESIN ──
  InventoryItem(
    id: 'INV-007', name: 'Standard Resin — Grey', brand: 'Elegoo',
    category: MaterialCategory.resin, unit: 'bottles',
    currentStock: 2, minStock: 4, criticalStock: 1, maxStock: 12,
    reorderQty: 6, costPerUnit: 650.00, sku: 'EL-STD-GRY-500ML',
    location: 'Cabinet B1', lastRestocked: DateTime.now().subtract(const Duration(days: 14)),
    expiryDate: DateTime.now().add(const Duration(days: 90)),
    itemColor: Colors.grey, autoReorder: false, supplier: 'Elegoo Official PH',
    compatiblePrinters: 'Elegoo Saturn 4 Ultra',
    recentUsage: [
      UsageEntry(projectId: 'JOB-870', projectName: 'miniature_figurine', amountUsed: 0.8, unit: 'bottles', usedAt: DateTime.now().subtract(const Duration(days: 3))),
    ],
    reorderHistory: [],
  ),
  InventoryItem(
    id: 'INV-008', name: 'ABS-Like Resin — Clear', brand: 'Anycubic',
    category: MaterialCategory.resin, unit: 'bottles',
    currentStock: 6, minStock: 3, criticalStock: 1, maxStock: 10,
    reorderQty: 4, costPerUnit: 720.00, sku: 'AC-ABS-CLR-500ML',
    location: 'Cabinet B2', lastRestocked: DateTime.now().subtract(const Duration(days: 7)),
    expiryDate: DateTime.now().add(const Duration(days: 120)),
    itemColor: Colors.cyan, autoReorder: true, supplier: 'Anycubic PH Reseller',
    compatiblePrinters: 'Elegoo Saturn 4 Ultra, Anycubic Photon',
    recentUsage: [],
    reorderHistory: [],
  ),
  // ── POWDER ──
  InventoryItem(
    id: 'INV-009', name: 'Nylon PA12 Powder', brand: 'Sinterit',
    category: MaterialCategory.powder, unit: 'kg',
    currentStock: 1.5, minStock: 5, criticalStock: 2, maxStock: 20,
    reorderQty: 10, costPerUnit: 4200.00, sku: 'ST-PA12-PWD-1KG',
    location: 'Vault C1', lastRestocked: DateTime.now().subtract(const Duration(days: 25)),
    itemColor: const Color(0xFFD1D5DB), autoReorder: false, supplier: 'Sinterit Global',
    compatiblePrinters: 'Sinterit Lisa Pro (SLS)',
    recentUsage: [
      UsageEntry(projectId: 'JOB-860', projectName: 'industrial_bracket_sls', amountUsed: 2.0, unit: 'kg', usedAt: DateTime.now().subtract(const Duration(days: 5))),
      UsageEntry(projectId: 'JOB-845', projectName: 'functional_hinge', amountUsed: 1.5, unit: 'kg', usedAt: DateTime.now().subtract(const Duration(days: 10))),
    ],
    reorderHistory: [
      ReorderHistory(orderedAt: DateTime.now().subtract(const Duration(days: 25)), quantity: 10, unit: 'kg', cost: 42000, supplier: 'Sinterit Global', status: 'Delivered'),
    ],
  ),
  // ── SPARE PARTS ──
  InventoryItem(
    id: 'INV-010', name: 'Brass Nozzle 0.4mm', brand: 'E3D',
    category: MaterialCategory.sparePart, unit: 'pcs',
    currentStock: 8, minStock: 5, criticalStock: 2, maxStock: 20,
    reorderQty: 10, costPerUnit: 150.00, sku: 'E3D-NOZ-BRS-04',
    location: 'Drawer D1', lastRestocked: DateTime.now().subtract(const Duration(days: 10)),
    itemColor: const Color(0xFFD4A853), autoReorder: true, supplier: 'E3D Online',
    recentUsage: [
      UsageEntry(projectId: 'MAINT-014', projectName: 'Prusa MK4 nozzle swap', amountUsed: 1, unit: 'pcs', usedAt: DateTime.now().subtract(const Duration(days: 4))),
    ],
    reorderHistory: [],
  ),
  InventoryItem(
    id: 'INV-011', name: 'Hardened Steel Nozzle 0.4mm', brand: 'E3D',
    category: MaterialCategory.sparePart, unit: 'pcs',
    currentStock: 2, minStock: 4, criticalStock: 1, maxStock: 10,
    reorderQty: 5, costPerUnit: 480.00, sku: 'E3D-NOZ-HST-04',
    location: 'Drawer D1', lastRestocked: DateTime.now().subtract(const Duration(days: 20)),
    itemColor: const Color(0xFF6B7280), autoReorder: false, supplier: 'E3D Online',
    recentUsage: [
      UsageEntry(projectId: 'MAINT-012', projectName: 'Bambu X1 nozzle swap', amountUsed: 1, unit: 'pcs', usedAt: DateTime.now().subtract(const Duration(days: 7))),
    ],
    reorderHistory: [],
  ),
  InventoryItem(
    id: 'INV-012', name: 'Build Plate PEI Sheet', brand: 'Bambu Lab',
    category: MaterialCategory.sparePart, unit: 'pcs',
    currentStock: 5, minStock: 3, criticalStock: 1, maxStock: 12,
    reorderQty: 6, costPerUnit: 890.00, sku: 'BL-PEI-256MM',
    location: 'Drawer D3', lastRestocked: DateTime.now().subtract(const Duration(days: 6)),
    itemColor: AppColors.amber, autoReorder: true, supplier: 'Bambu Lab PH',
    recentUsage: [],
    reorderHistory: [],
  ),
  // ── CONSUMABLES ──
  InventoryItem(
    id: 'INV-013', name: 'Isopropyl Alcohol 99%', brand: 'Generic',
    category: MaterialCategory.consumable, unit: 'bottles',
    currentStock: 3, minStock: 5, criticalStock: 2, maxStock: 15,
    reorderQty: 8, costPerUnit: 110.00, sku: 'GEN-IPA-99-500ML',
    location: 'Cabinet E1', lastRestocked: DateTime.now().subtract(const Duration(days: 9)),
    itemColor: Colors.blue, autoReorder: true, supplier: 'Local Supplier',
    recentUsage: [
      UsageEntry(projectId: 'MAINT-015', projectName: 'Resin plate cleaning', amountUsed: 1, unit: 'bottles', usedAt: DateTime.now().subtract(const Duration(days: 2))),
    ],
    reorderHistory: [],
  ),
  InventoryItem(
    id: 'INV-014', name: 'Glue Stick (Bed Adhesion)', brand: 'Pritt',
    category: MaterialCategory.consumable, unit: 'pcs',
    currentStock: 12, minStock: 5, criticalStock: 2, maxStock: 20,
    reorderQty: 10, costPerUnit: 45.00, sku: 'PRT-GLUE-40G',
    location: 'Shelf F1', lastRestocked: DateTime.now().subtract(const Duration(days: 2)),
    itemColor: Colors.yellow, autoReorder: false, supplier: 'Local Supplier',
    recentUsage: [],
    reorderHistory: [],
  ),
];

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return const _WebInventoryView();
        }
        return const _MobileInventoryView();
      },
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED STATE MIXIN
// ─────────────────────────────────────────────
mixin _InventoryStateMixin<T extends StatefulWidget> on State<T> {
  String searchQuery = '';
  MaterialCategory? categoryFilter;
  StockLevel? stockFilter;
  String sortBy = 'name';

  List<InventoryItem> get filtered {
    var list = List<InventoryItem>.from(kInventory);
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((i) =>
          i.name.toLowerCase().contains(q) ||
          i.brand.toLowerCase().contains(q) ||
          i.sku.toLowerCase().contains(q)).toList();
    }
    if (categoryFilter != null) {
      list = list.where((i) => i.category == categoryFilter).toList();
    }
    if (stockFilter != null) {
      list = list.where((i) => i.stockLevel == stockFilter).toList();
    }
    list.sort((a, b) {
      if (sortBy == 'stock') return a.stockPercent.compareTo(b.stockPercent);
      if (sortBy == 'cost') return b.costPerUnit.compareTo(a.costPerUnit);
      return a.name.compareTo(b.name);
    });
    return list;
  }

  int get criticalCount => kInventory.where((i) => i.stockLevel == StockLevel.critical).length;
  int get lowCount => kInventory.where((i) => i.stockLevel == StockLevel.low).length;
  int get alertCount => criticalCount + lowCount;
  double get totalInventoryValue => kInventory.fold(0, (s, i) => s + i.currentStock * i.costPerUnit);

  void clearFilters() => setState(() { categoryFilter = null; stockFilter = null; });
}

// ─────────────────────────────────────────────
//  SHARED: ITEM DETAIL CONTENT
// ─────────────────────────────────────────────
class _ItemDetailContent extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const _ItemDetailContent({
    required this.item,
    this.onClose,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final stockColor = _stockColor(item.stockLevel);
    final stockLight = _stockLight(item.stockLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(children: [
            const Text('Item Detail',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const Spacer(),
            if (showCloseButton && onClose != null)
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border)),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textSecondary),
                ),
              ),
          ]),

          const SizedBox(height: 18),

          // Item name block
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                        color: item.itemColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                  ),
                ]),
                const SizedBox(height: 6),
                Text('${item.brand}  ·  ${item.sku}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 10),
                Row(children: [
                  _SharedCategoryBadge(category: item.category),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: stockLight,
                        borderRadius: BorderRadius.circular(7)),
                    child: Text(_stockLabel(item.stockLevel),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: stockColor)),
                  ),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Stock Gauge
          const Text('Stock Status',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _SharedStockGauge(item: item, stockColor: stockColor),

          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Details
          const Text('Details',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _SharedInfoRow(icon: Icons.location_on_rounded, label: 'Location', value: item.location),
          _SharedInfoRow(icon: Icons.attach_money_rounded, label: 'Cost Per Unit', value: '₱${item.costPerUnit.toStringAsFixed(2)}', mono: true),
          _SharedInfoRow(icon: Icons.payments_rounded, label: 'Total Value', value: '₱${(item.currentStock * item.costPerUnit).toStringAsFixed(2)}', mono: true),
          _SharedInfoRow(icon: Icons.local_shipping_rounded, label: 'Supplier', value: item.supplier),
          _SharedInfoRow(icon: Icons.autorenew_rounded, label: 'Reorder Qty', value: '${item.reorderQty} ${item.unit}'),
          _SharedInfoRow(icon: Icons.autorenew_rounded, label: 'Auto-Reorder', value: item.autoReorder ? '✅ Enabled' : '❌ Disabled'),
          if (item.expiryDate != null)
            _SharedInfoRow(
                icon: Icons.event_busy_rounded,
                label: 'Expiry Date',
                value: _formatDate(item.expiryDate!),
                valueColor: _expiryColor(item.expiryDate!)),
          if (item.compatiblePrinters != null)
            _SharedInfoRow(
                icon: Icons.precision_manufacturing_rounded,
                label: 'Compatible With',
                value: item.compatiblePrinters!),

          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Weekly usage
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Usage This Week',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(
              '${item.weeklyUsage % 1 == 0 ? item.weeklyUsage.toInt() : item.weeklyUsage} ${item.unit}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.indigo),
            ),
          ]),
          const SizedBox(height: 10),
          if (item.recentUsage.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('No usage recorded',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            )
          else
            ...item.recentUsage.map((u) => _SharedUsageCard(
                entry: u,
                unit: item.unit,
                costPerUnit: item.costPerUnit)),

          if (item.reorderHistory.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),
            const Text('Reorder History',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            ...item.reorderHistory.map((r) => _SharedReorderCard(record: r)),
          ],

          const SizedBox(height: 22),

          // Reorder button
          if (item.stockLevel == StockLevel.critical ||
              item.stockLevel == StockLevel.low)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_rounded, size: 16),
                label:
                    Text('Reorder ${item.reorderQty} ${item.unit} Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _expiryColor(DateTime expiry) {
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    if (daysLeft < 30) return AppColors.rose;
    if (daysLeft < 60) return AppColors.amber;
    return AppColors.emerald;
  }
}

// ─────────────────────────────────────────────
//  SHARED: STOCK GAUGE
// ─────────────────────────────────────────────
class _SharedStockGauge extends StatelessWidget {
  final InventoryItem item;
  final Color stockColor;
  const _SharedStockGauge({required this.item, required this.stockColor});

  @override
  Widget build(BuildContext context) {
    final pct = item.stockPercent;
    final critPct = item.criticalStock / item.maxStock;
    final minPct = item.minStock / item.maxStock;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${item.currentStock % 1 == 0 ? item.currentStock.toInt() : item.currentStock}',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: stockColor,
                    letterSpacing: -1),
              ),
              Text('${item.unit} remaining',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Max: ${item.maxStock.toInt()} ${item.unit}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text('Reorder at: ${item.minStock.toInt()} ${item.unit}',
                  style: const TextStyle(fontSize: 11, color: AppColors.amber)),
              const SizedBox(height: 2),
              Text('Critical: ${item.criticalStock.toInt()} ${item.unit}',
                  style: const TextStyle(fontSize: 11, color: AppColors.rose)),
            ]),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (_, constraints) {
          return Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                minHeight: 14,
              ),
            ),
            Positioned(
              left: (critPct * constraints.maxWidth).clamp(0.0, constraints.maxWidth - 2),
              top: 0, bottom: 0,
              child: Container(width: 2, color: AppColors.rose.withOpacity(0.6)),
            ),
            Positioned(
              left: (minPct * constraints.maxWidth).clamp(0.0, constraints.maxWidth - 2),
              top: 0, bottom: 0,
              child: Container(width: 2, color: AppColors.amber.withOpacity(0.6)),
            ),
          ]);
        }),
        const SizedBox(height: 8),
        Row(children: [
          _GaugeLegend(color: AppColors.rose, label: 'Critical'),
          const SizedBox(width: 12),
          _GaugeLegend(color: AppColors.amber, label: 'Reorder Point'),
          const Spacer(),
          Text('${(pct * 100).toInt()}% full',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: stockColor)),
        ]),
      ]),
    );
  }
}

class _GaugeLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _GaugeLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 3, color: color),
    const SizedBox(width: 4),
    Text(label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
  ]);
}

// ─────────────────────────────────────────────
//  SHARED: USAGE & REORDER CARDS
// ─────────────────────────────────────────────
class _SharedUsageCard extends StatelessWidget {
  final UsageEntry entry;
  final String unit;
  final double costPerUnit;
  const _SharedUsageCard(
      {required this.entry, required this.unit, required this.costPerUnit});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: AppColors.indigoLight,
            borderRadius: BorderRadius.circular(7)),
        child: const Icon(Icons.print_rounded,
            size: 13, color: AppColors.indigo),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.projectName,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'monospace')),
          Text('${entry.projectId}  ·  ${_timeAgo(entry.usedAt)}',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${entry.amountUsed} $unit',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Text('₱${(entry.amountUsed * costPerUnit).toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.violet,
                fontFamily: 'monospace')),
      ]),
    ]),
  );
}

class _SharedReorderCard extends StatelessWidget {
  final ReorderHistory record;
  const _SharedReorderCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final isDelivered = record.status == 'Delivered';
    final isTransit = record.status == 'In Transit';
    final color = isDelivered
        ? AppColors.emerald
        : isTransit
            ? AppColors.sky
            : AppColors.amber;
    final light = isDelivered
        ? AppColors.emeraldLight
        : isTransit
            ? AppColors.skyLight
            : AppColors.amberLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration:
              BoxDecoration(color: light, borderRadius: BorderRadius.circular(7)),
          child: Icon(Icons.local_shipping_rounded, size: 13, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                '${record.quantity.toInt()} ${record.unit} from ${record.supplier}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            Text(_formatDate(record.orderedAt),
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration:
                BoxDecoration(color: light, borderRadius: BorderRadius.circular(6)),
            child: Text(record.status,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
          const SizedBox(height: 2),
          Text('₱${record.cost.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.violet,
                  fontFamily: 'monospace')),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: CATEGORY BADGE
// ─────────────────────────────────────────────
class _SharedCategoryBadge extends StatelessWidget {
  final MaterialCategory category;
  const _SharedCategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final data = switch (category) {
      MaterialCategory.filament => (
        label: 'Filament',
        color: AppColors.indigo,
        light: AppColors.indigoLight,
        icon: Icons.rotate_right_rounded
      ),
      MaterialCategory.resin => (
        label: 'Resin',
        color: AppColors.violet,
        light: AppColors.violetLight,
        icon: Icons.water_drop_rounded
      ),
      MaterialCategory.powder => (
        label: 'Powder',
        color: AppColors.amber,
        light: AppColors.amberLight,
        icon: Icons.grain_rounded
      ),
      MaterialCategory.sparePart => (
        label: 'Spare Part',
        color: AppColors.sky,
        light: AppColors.skyLight,
        icon: Icons.build_rounded
      ),
      MaterialCategory.consumable => (
        label: 'Consumable',
        color: AppColors.emerald,
        light: AppColors.emeraldLight,
        icon: Icons.cleaning_services_rounded
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: data.light, borderRadius: BorderRadius.circular(7)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(data.icon, size: 10, color: data.color),
        const SizedBox(width: 4),
        Text(data.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: data.color)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: INFO ROW
// ─────────────────────────────────────────────
class _SharedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool mono;
  final Color? valueColor;
  const _SharedInfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.mono = false,
      this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(children: [
      Icon(icon, size: 13, color: AppColors.textMuted),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const Spacer(),
      Flexible(
        child: Text(value,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
                fontFamily: mono ? 'monospace' : null)),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────
//  SHARED: PICKER WIDGETS
// ─────────────────────────────────────────────
class _PickerOption {
  final String label;
  final VoidCallback onTap;
  const _PickerOption({required this.label, required this.onTap});
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<_PickerOption> options;
  const _PickerSheet({required this.title, required this.options});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        ...options.map((o) => ListTile(
              title: Text(o.label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary)),
              onTap: o.onTap,
              contentPadding: EdgeInsets.zero,
              dense: true,
            )),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
//  SHARED META HELPERS
// ─────────────────────────────────────────────
Color _stockColor(StockLevel s) => switch (s) {
  StockLevel.critical => AppColors.rose,
  StockLevel.low => AppColors.amber,
  StockLevel.adequate => AppColors.emerald,
  StockLevel.overstocked => AppColors.sky,
};

Color _stockLight(StockLevel s) => switch (s) {
  StockLevel.critical => AppColors.roseLight,
  StockLevel.low => AppColors.amberLight,
  StockLevel.adequate => AppColors.emeraldLight,
  StockLevel.overstocked => AppColors.skyLight,
};

String _stockLabel(StockLevel s) => switch (s) {
  StockLevel.critical => 'Critical',
  StockLevel.low => 'Low Stock',
  StockLevel.adequate => 'Adequate',
  StockLevel.overstocked => 'Overstocked',
};

String _categoryLabel(MaterialCategory c) => switch (c) {
  MaterialCategory.filament => 'Filament',
  MaterialCategory.resin => 'Resin',
  MaterialCategory.powder => 'Powder',
  MaterialCategory.sparePart => 'Spare Parts',
  MaterialCategory.consumable => 'Consumables',
};

// ─────────────────────────────────────────────
//  SHARED DATE HELPER
// ─────────────────────────────────────────────
String _formatDate(DateTime dt) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

String _daysAgo(DateTime dt) {
  final d = DateTime.now().difference(dt).inDays;
  if (d == 0) return 'Today';
  if (d == 1) return 'Yesterday';
  return '${d}d ago';
}