import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

enum MaterialCategory { filament, resin, other }

extension MaterialCategoryExt on MaterialCategory {
  String get label {
    switch (this) {
      case MaterialCategory.filament: return 'Filament';
      case MaterialCategory.resin:    return 'Resin';
      case MaterialCategory.other:    return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case MaterialCategory.filament: return const Color(0xFF3B82F6);
      case MaterialCategory.resin:    return const Color(0xFF8B5CF6);
      case MaterialCategory.other:    return const Color(0xFF10B981);
    }
  }

  IconData get icon {
    switch (this) {
      case MaterialCategory.filament: return Iconsax.layer;
      case MaterialCategory.resin:    return Iconsax.box;
      case MaterialCategory.other:    return Iconsax.category;
    }
  }
}

enum StockLevel { good, low, critical, outOfStock }

extension StockLevelExt on StockLevel {
  Color get color {
    switch (this) {
      case StockLevel.good:       return const Color(0xFF10B981);
      case StockLevel.low:        return const Color(0xFFF59E0B);
      case StockLevel.critical:   return const Color(0xFFEF4444);
      case StockLevel.outOfStock: return const Color(0xFF6B7280);
    }
  }

  String get label {
    switch (this) {
      case StockLevel.good:       return 'Good';
      case StockLevel.low:        return 'Low';
      case StockLevel.critical:   return 'Critical';
      case StockLevel.outOfStock: return 'Out of Stock';
    }
  }
}

class _InventoryItem {
  final String id;
  final String name;
  final MaterialCategory category;
  final String unit;
  final double quantity;
  final double minQuantity;
  final List<String> compatibleMachines;
  final Color color;

  const _InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.minQuantity,
    required this.compatibleMachines,
    required this.color,
  });

  StockLevel get stockLevel {
    if (quantity <= 0) return StockLevel.outOfStock;
    if (quantity <= minQuantity * 0.3) return StockLevel.critical;
    if (quantity <= minQuantity) return StockLevel.low;
    return StockLevel.good;
  }

  double get stockPercent => (quantity / (minQuantity * 3)).clamp(0.0, 1.0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Inventory data
// ─────────────────────────────────────────────────────────────────────────────

final List<_InventoryItem> _inventoryItems = [
  _InventoryItem(id: 'INV-001', name: 'PLA', category: MaterialCategory.filament,
      unit: 'kg', quantity: 4.5, minQuantity: 2.0,
      compatibleMachines: ['Ender-3 V3 SE', 'X1 Carbon'], color: const Color(0xFF3B82F6)),
  _InventoryItem(id: 'INV-002', name: 'PETG', category: MaterialCategory.filament,
      unit: 'kg', quantity: 1.2, minQuantity: 2.0,
      compatibleMachines: ['Ender-3 V3 SE', 'X1 Carbon'], color: const Color(0xFF06B6D4)),
  _InventoryItem(id: 'INV-003', name: 'TPU', category: MaterialCategory.filament,
      unit: 'kg', quantity: 0.8, minQuantity: 1.0,
      compatibleMachines: ['Ender-3 V3 SE', 'X1 Carbon'], color: const Color(0xFF10B981)),
  _InventoryItem(id: 'INV-004', name: 'PA (Nylon)', category: MaterialCategory.filament,
      unit: 'kg', quantity: 0.0, minQuantity: 1.0,
      compatibleMachines: ['Ender-3 V3 SE'], color: const Color(0xFFF59E0B)),
  _InventoryItem(id: 'INV-005', name: 'ABS', category: MaterialCategory.filament,
      unit: 'kg', quantity: 2.0, minQuantity: 1.5,
      compatibleMachines: ['Ender-3 V3 SE', 'X1 Carbon'], color: const Color(0xFFEF4444)),
  _InventoryItem(id: 'INV-006', name: 'PVA', category: MaterialCategory.filament,
      unit: 'kg', quantity: 0.3, minQuantity: 0.5,
      compatibleMachines: ['X1 Carbon'], color: const Color(0xFF8B5CF6)),
  _InventoryItem(id: 'INV-007', name: 'PET', category: MaterialCategory.filament,
      unit: 'kg', quantity: 1.5, minQuantity: 1.0,
      compatibleMachines: ['X1 Carbon'], color: const Color(0xFF14B8A6)),
  _InventoryItem(id: 'INV-008', name: 'PC (Polycarbonate)', category: MaterialCategory.filament,
      unit: 'kg', quantity: 0.6, minQuantity: 1.0,
      compatibleMachines: ['X1 Carbon'], color: const Color(0xFF6366F1)),
  _InventoryItem(id: 'INV-009', name: 'Carbon / Glass Fiber Reinforced Polymer',
      category: MaterialCategory.filament,
      unit: 'kg', quantity: 0.2, minQuantity: 0.5,
      compatibleMachines: ['X1 Carbon'], color: const Color(0xFF1F2937)),
  _InventoryItem(id: 'INV-010', name: 'Standard Resin', category: MaterialCategory.resin,
      unit: 'bottles', quantity: 3.0, minQuantity: 2.0,
      compatibleMachines: ['Saturn 3 Ultra'], color: const Color(0xFF8B5CF6)),
  _InventoryItem(id: 'INV-011', name: 'ABE Substitute Resin', category: MaterialCategory.resin,
      unit: 'bottles', quantity: 1.0, minQuantity: 2.0,
      compatibleMachines: ['Saturn 3 Ultra'], color: const Color(0xFFA855F7)),
  _InventoryItem(id: 'INV-012', name: 'PE Substitute Resin', category: MaterialCategory.resin,
      unit: 'bottles', quantity: 0.0, minQuantity: 1.0,
      compatibleMachines: ['Saturn 3 Ultra'], color: const Color(0xFFD946EF)),
  _InventoryItem(id: 'INV-013', name: 'Flexible Resin', category: MaterialCategory.resin,
      unit: 'bottles', quantity: 2.0, minQuantity: 1.0,
      compatibleMachines: ['Saturn 3 Ultra'], color: const Color(0xFF7C3AED)),
  _InventoryItem(id: 'INV-014', name: 'Casting Resin', category: MaterialCategory.resin,
      unit: 'bottles', quantity: 1.0, minQuantity: 1.0,
      compatibleMachines: ['Saturn 3 Ultra'], color: const Color(0xFF6D28D9)),
  _InventoryItem(id: 'INV-015', name: 'Draft Resin', category: MaterialCategory.resin,
      unit: 'bottles', quantity: 4.0, minQuantity: 2.0,
      compatibleMachines: ['Saturn 3 Ultra'], color: const Color(0xFF5B21B6)),
  _InventoryItem(id: 'INV-016', name: 'IPA (Isopropyl Alcohol)',
      category: MaterialCategory.other,
      unit: 'liters', quantity: 3.5, minQuantity: 2.0,
      compatibleMachines: ['Wash and Cure 3 Plus'], color: const Color(0xFFF59E0B)),
];

// Preset colors for the color picker
const List<Color> _colorPalette = [
  Color(0xFF3B82F6), Color(0xFF06B6D4), Color(0xFF10B981), Color(0xFF14B8A6),
  Color(0xFF8B5CF6), Color(0xFFA855F7), Color(0xFFD946EF), Color(0xFF6366F1),
  Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF1F2937), Color(0xFF6D28D9),
];

// Known machines for the compatible machines selector
const List<String> _knownMachines = [
  'Ender-3 V3 SE',
  'Saturn 3 Ultra',
  'Wash and Cure 3 Plus',
  'X1 Carbon',
  'Einstar',
];

const List<String> _unitOptions = ['kg', 'g', 'bottles', 'liters', 'ml', 'rolls', 'pieces'];

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class StaffInventoryScreen extends StatefulWidget {
  const StaffInventoryScreen({super.key});

  @override
  State<StaffInventoryScreen> createState() => _StaffInventoryScreenState();
}

class _StaffInventoryScreenState extends State<StaffInventoryScreen> {
  MaterialCategory? _selectedCategory;
  final List<_InventoryItem> _items = List.from(_inventoryItems);

  List<_InventoryItem> get _filtered => _selectedCategory == null
      ? _items
      : _items.where((i) => i.category == _selectedCategory).toList();

  int get _lowStockCount => _items
      .where((i) =>
          i.stockLevel == StockLevel.low ||
          i.stockLevel == StockLevel.critical ||
          i.stockLevel == StockLevel.outOfStock)
      .length;

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Add Material sheet ──────────────────────────────────────────────────────

  void _showAddMaterialSheet() {
    final nameCtrl     = TextEditingController();
    final qtyCtrl      = TextEditingController();
    final minQtyCtrl   = TextEditingController();
    final machineCtrl  = TextEditingController();

    MaterialCategory selectedCategory = MaterialCategory.filament;
    String selectedUnit               = 'kg';
    Color selectedColor               = _colorPalette.first;
    final List<String> selectedMachines = [];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {

          void addMachine() {
            final v = machineCtrl.text.trim();
            if (v.isNotEmpty && !selectedMachines.contains(v)) {
              setLocal(() { selectedMachines.add(v); machineCtrl.clear(); });
            }
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Center(child: Container(width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),

                    // Title row
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                            color: selectedCategory.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(selectedCategory.icon, size: 20,
                            color: selectedCategory.color),
                      ),
                      const SizedBox(width: 12),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Add Material', style: TextStyle(fontSize: 17,
                            fontWeight: FontWeight.w800, color: Color(0xFF1A1D23))),
                        Text('Register new inventory item', style: TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                      ]),
                    ]),
                    const SizedBox(height: 24),

                    // Name
                    _SheetLabel('Material Name'),
                    const SizedBox(height: 6),
                    _SheetTextField(controller: nameCtrl, hint: 'e.g. PLA, Standard Resin…'),
                    const SizedBox(height: 14),

                    // Category
                    _SheetLabel('Category'),
                    const SizedBox(height: 6),
                    Row(children: MaterialCategory.values.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Expanded(child: Padding(
                        padding: EdgeInsets.only(right: cat != MaterialCategory.values.last ? 8 : 0),
                        child: GestureDetector(
                          onTap: () => setLocal(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? cat.color : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isSelected ? cat.color : Colors.grey.shade200),
                            ),
                            child: Column(children: [
                              Icon(cat.icon, size: 16,
                                  color: isSelected ? Colors.white : Colors.grey.shade500),
                              const SizedBox(height: 4),
                              Text(cat.label, style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey.shade600)),
                            ]),
                          ),
                        ),
                      ));
                    }).toList()),
                    const SizedBox(height: 14),

                    // Quantity + Unit row
                    Row(children: [
                      Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _SheetLabel('Current Qty'),
                        const SizedBox(height: 6),
                        _SheetTextField(controller: qtyCtrl, hint: '0.0',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      ])),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _SheetLabel('Min. Qty'),
                        const SizedBox(height: 6),
                        _SheetTextField(controller: minQtyCtrl, hint: '0.0',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      ])),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _SheetLabel('Unit'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedUnit,
                          isExpanded: true,
                          decoration: _sheetInputDeco(''),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1D23)),
                          items: _unitOptions.map((u) =>
                              DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (v) => setLocal(() => selectedUnit = v!),
                        ),
                      ])),
                    ]),
                    const SizedBox(height: 14),

                    // Compatible machines
                    _SheetLabel('Compatible Machines'),
                    const SizedBox(height: 8),
                    // Quick-select known machines
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: _knownMachines.map((m) {
                        final isSelected = selectedMachines.contains(m);
                        return GestureDetector(
                          onTap: () => setLocal(() {
                            if (isSelected) selectedMachines.remove(m);
                            else selectedMachines.add(m);
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedCategory.color.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? selectedCategory.color.withValues(alpha: 0.4)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              if (isSelected) ...[
                                Icon(Icons.check_rounded, size: 12,
                                    color: selectedCategory.color),
                                const SizedBox(width: 4),
                              ],
                              Text(m, style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? selectedCategory.color
                                    : Colors.grey.shade600,
                              )),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Custom machine entry
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: machineCtrl,
                          onSubmitted: (_) => addMachine(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          decoration: _sheetInputDeco('Add custom machine…'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: addMachine,
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                              color: selectedCategory.color,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),

                    // Color picker
                    _SheetLabel('Color Tag'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _colorPalette.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final c = _colorPalette[i];
                          final isSelected = selectedColor.value == c.value;
                          return GestureDetector(
                            onTap: () => setLocal(() => selectedColor = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: isSelected ? 36 : 30,
                              height: isSelected ? 36 : 30,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: c.withValues(alpha: 0.5),
                                      blurRadius: 8, spreadRadius: 1),
                                ] : [],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 16)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) {
                            _snack('Material name is required', Colors.red.shade400);
                            return;
                          }
                          final qty    = double.tryParse(qtyCtrl.text) ?? 0.0;
                          final minQty = double.tryParse(minQtyCtrl.text) ?? 1.0;
                          final newId  = 'INV-${(_items.length + 1).toString().padLeft(3, '0')}';

                          final newItem = _InventoryItem(
                            id: newId,
                            name: nameCtrl.text.trim(),
                            category: selectedCategory,
                            unit: selectedUnit,
                            quantity: qty,
                            minQuantity: minQty == 0.0 ? 1.0 : minQty,
                            compatibleMachines: selectedMachines.isEmpty
                                ? ['N/A']
                                : List.from(selectedMachines),
                            color: selectedColor,
                          );

                          setState(() => _items.add(newItem));
                          Navigator.pop(ctx);
                          _snack('${newItem.name} added to inventory', selectedCategory.color);
                        },
                        icon: const Icon(Iconsax.add, size: 18),
                        label: const Text('Add Material'),
                        style: FilledButton.styleFrom(
                          backgroundColor: selectedCategory.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final filtered = _filtered;

    return Stack(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Inventory',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700, color: Colors.black87, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text('Track all material stock levels.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500)),
            ])),
            if (_lowStockCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200)),
                child: Row(children: [
                  Icon(Iconsax.warning_2, size: 13, color: Colors.red.shade400),
                  const SizedBox(width: 6),
                  Text('$_lowStockCount Low Stock',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: Colors.red.shade500)),
                ]),
              ),
          ]),
        ),

        const SizedBox(height: 16),

        // Summary stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(children: [
            _StatCard(label: 'Total Items', value: '${_items.length}',
                icon: Iconsax.box, color: Colors.teal),
            const SizedBox(width: 10),
            _StatCard(
                label: 'Filaments',
                value: '${_items.where((i) => i.category == MaterialCategory.filament).length}',
                icon: Iconsax.layer, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 10),
            _StatCard(
                label: 'Resins',
                value: '${_items.where((i) => i.category == MaterialCategory.resin).length}',
                icon: Iconsax.box, color: const Color(0xFF8B5CF6)),
          ]),
        ),

        const SizedBox(height: 16),

        // Category filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(children: [
            _FilterChip(label: 'All', icon: Iconsax.category,
                isSelected: _selectedCategory == null, color: Colors.teal,
                onTap: () => setState(() => _selectedCategory = null)),
            const SizedBox(width: 8),
            ...MaterialCategory.values.map((c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(label: c.label, icon: c.icon,
                  isSelected: _selectedCategory == c, color: c.color,
                  onTap: () => setState(() => _selectedCategory = c)),
            )),
          ]),
        ),

        const SizedBox(height: 16),

        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('No items in this category.',
                  style: TextStyle(color: Colors.grey.shade500)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _InventoryCard(
                      item: filtered[i],
                      onTap: () => _showItemDetail(filtered[i])),
                ),
        ),
      ]),

      // FAB — bottom right
      Positioned(
        bottom: 28,
        right: 28,
        child: GestureDetector(
          onTap: _showAddMaterialSheet,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.add, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text('Add Material',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Detail sheet ────────────────────────────────────────────────────────────

  void _showItemDetail(_InventoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(item.category.icon, size: 24, color: item.color),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700, color: Color(0xFF1A1D23))),
              Text(item.category.label,
                  style: TextStyle(fontSize: 12, color: item.color, fontWeight: FontWeight.w500)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: item.stockLevel.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: item.stockLevel.color.withOpacity(0.3))),
              child: Text(item.stockLevel.label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: item.stockLevel.color)),
            ),
          ]),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatBox(label: 'Current Stock',
                value: '${item.quantity} ${item.unit}', color: item.stockLevel.color)),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(label: 'Min. Required',
                value: '${item.minQuantity} ${item.unit}', color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Stock Level',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text('${(item.stockPercent * 100).toInt()}%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: item.stockLevel.color)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: item.stockPercent,
                    backgroundColor: Colors.grey.shade200,
                    color: item.stockLevel.color, minHeight: 8)),
          ]),
          const SizedBox(height: 14),
          Text('COMPATIBLE WITH', style: TextStyle(fontSize: 10,
              fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6,
              children: item.compatibleMachines.map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: item.color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(m,
                    style: TextStyle(fontSize: 11, color: item.color, fontWeight: FontWeight.w500)),
              )).toList()),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared form helpers (same as machine screen)
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _sheetInputDeco(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
  filled: true,
  fillColor: const Color(0xFFF9FAFB),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.teal, width: 1.5)),
);

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280), letterSpacing: 0.2));
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({required this.controller, required this.hint, this.keyboardType});
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1D23)),
    decoration: _sheetInputDeco(hint),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Inventory Card
// ─────────────────────────────────────────────────────────────────────────────

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.item, required this.onTap});
  final _InventoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(item.category.icon, size: 20, color: item.color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700, color: Color(0xFF1A1D23))),
              const SizedBox(height: 2),
              Text(item.compatibleMachines.join(' · '),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${item.quantity} ${item.unit}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                      color: item.stockLevel.color)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: item.stockLevel.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(item.stockLevel.label,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                        color: item.stockLevel.color)),
              ),
            ]),
          ]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: item.stockPercent, backgroundColor: Colors.grey.shade100,
                  color: item.stockLevel.color, minHeight: 5)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.color});
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ]),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.icon,
      required this.isSelected, required this.color, required this.onTap});
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13,
            color: isSelected ? Colors.white : Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.grey.shade600)),
      ]),
    ),
  );
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}