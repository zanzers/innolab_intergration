import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:innolab/src/common/loader/app_loader.dart';
import 'package:innolab/src/features/core/admin/inventory/inventortWidgets/addMaterial.dart';
import 'package:innolab/src/features/core/admin/inventory/inventortWidgets/editMaterial.dart';
import 'package:innolab/src/features/core/admin/inventory/inventoryController/inventory_controller.dart';
import 'package:innolab/src/features/models/inventory_model.dart';

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
  final double costPerHour; // new field
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
    required this.costPerHour, // new
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

  // ── copyWith ────────────────────────────────
  InventoryItem copyWith({
    String? id,
    String? name,
    String? brand,
    MaterialCategory? category,
    String? unit,
    double? currentStock,
    double? minStock,
    double? criticalStock,
    double? maxStock,
    double? reorderQty,
    double? costPerUnit,
    double? costPerHour,
    String? sku,
    String? location,
    DateTime? lastRestocked,
    DateTime? expiryDate,
    Color? itemColor,
    bool? autoReorder,
    String? supplier,
    List<UsageEntry>? recentUsage,
    List<ReorderHistory>? reorderHistory,
    String? compatiblePrinters,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      criticalStock: criticalStock ?? this.criticalStock,
      maxStock: maxStock ?? this.maxStock,
      reorderQty: reorderQty ?? this.reorderQty,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      costPerHour: costPerHour ?? this.costPerHour,
      sku: sku ?? this.sku,
      location: location ?? this.location,
      lastRestocked: lastRestocked ?? this.lastRestocked,
      expiryDate: expiryDate ?? this.expiryDate,
      itemColor: itemColor ?? this.itemColor,
      autoReorder: autoReorder ?? this.autoReorder,
      supplier: supplier ?? this.supplier,
      recentUsage: recentUsage ?? this.recentUsage,
      reorderHistory: reorderHistory ?? this.reorderHistory,
      compatiblePrinters: compatiblePrinters ?? this.compatiblePrinters,
    );
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
    reorderQty: 10, costPerUnit: 320.00, costPerHour: 0.45,
    sku: 'BL-PLA-BLK-1KG', location: 'Shelf A1',
    lastRestocked: DateTime.now().subtract(const Duration(days: 12)),
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
    reorderQty: 10, costPerUnit: 320.00, costPerHour: 0.45,
    sku: 'BL-PLA-WHT-1KG', location: 'Shelf A2',
    lastRestocked: DateTime.now().subtract(const Duration(days: 5)),
    itemColor: Colors.white, autoReorder: true, supplier: 'Bambu Lab PH',
    compatiblePrinters: 'Bambu X1, Bambu P1S, Prusa MK4',
    recentUsage: [
      UsageEntry(projectId: 'JOB-891', projectName: 'phone_stand_v2', amountUsed: 0.3, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(hours: 1))),
      UsageEntry(projectId: 'JOB-880', projectName: 'product_mockup', amountUsed: 1.1, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(days: 1))),
    ],
    reorderHistory: [],
  ),
  // ... add costPerHour to all other sample items similarly
  // (for brevity, add costPerHour = 0.0 to others; you can fill realistic values later)
  InventoryItem(
    id: 'INV-003', name: 'PETG Filament — Clear', brand: 'Prusa',
    category: MaterialCategory.filament, unit: 'rolls',
    currentStock: 2, minStock: 4, criticalStock: 1, maxStock: 15,
    reorderQty: 8, costPerUnit: 380.00, costPerHour: 0.55,
    sku: 'PR-PETG-CLR-1KG', location: 'Shelf A3',
    lastRestocked: DateTime.now().subtract(const Duration(days: 18)),
    itemColor: Colors.cyan, autoReorder: false, supplier: 'Prusa Research',
    compatiblePrinters: 'Prusa MK4, Creality K1',
    recentUsage: [
      UsageEntry(projectId: 'JOB-891', projectName: 'phone_stand_v2', amountUsed: 0.9, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(hours: 5))),
      UsageEntry(projectId: 'JOB-872', projectName: 'enclosure_lid', amountUsed: 0.7, unit: 'rolls', usedAt: DateTime.now().subtract(const Duration(days: 3))),
    ],
    reorderHistory: [],
  ),
  // Add remaining sample items with costPerHour = 0.0 for now
  // ...
];

// (The rest of the file – helpers, mixin, shared widgets – remains unchanged except for the model addition)
// ...

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

          // Item name block (SKU removed)
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
                Text(item.brand, // SKU removed
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

          // Details (added cost per hour)
          const Text('Details',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _SharedInfoRow(icon: Icons.attach_money_rounded, label: 'Cost Per Unit', value: '₱${item.costPerUnit.toStringAsFixed(2)}', mono: true),
          _SharedInfoRow(icon: Icons.timer_rounded, label: 'Cost Per Hour', value: '₱${item.costPerHour.toStringAsFixed(2)}', mono: true),
          _SharedInfoRow(icon: Icons.payments_rounded, label: 'Total Value', value: '₱${(item.currentStock * item.costPerUnit).toStringAsFixed(2)}', mono: true),
          _SharedInfoRow(icon: Icons.local_shipping_rounded, label: 'Supplier', value: item.supplier),
          // Reorder Qty removed from UI
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

          // Weekly usage (unchanged)
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

          // Reorder button removed (min/reorder points removed)
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
        child: const Icon(Icons.print_rounded, size: 13, color: AppColors.indigo),
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
          decoration: BoxDecoration(color: light, borderRadius: BorderRadius.circular(7)),
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
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: light, borderRadius: BorderRadius.circular(6)),
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
    final label = switch (category) {
      MaterialCategory.filament => 'Filament',
      MaterialCategory.resin => 'Resin',
      MaterialCategory.powder => 'Powder',
      MaterialCategory.sparePart => 'Spare Part',
      MaterialCategory.consumable => 'Consumable',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
      ),
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

String categoryLabel(MaterialCategory c) => switch (c) {
  MaterialCategory.filament => 'Filament',
  MaterialCategory.resin => 'Resin',
  MaterialCategory.powder => 'Powder',
  MaterialCategory.sparePart => 'Spare Parts',
  MaterialCategory.consumable => 'Consumables',
};

// ─────────────────────────────────────────────
//  SHARED DATE HELPERS
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