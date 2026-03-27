part of 'inventory_screen.dart';

StockLevel _stockLevelForInventoryModel(InventoryModel m) {
  // No max quantity field anymore; use current quantity thresholds only.
  final q = m.currentQuantity;
  if (q <= 0) return StockLevel.critical;
  if (q <= 2) return StockLevel.low;
  return StockLevel.adequate;
}

MaterialCategory _materialCategoryFromString(String raw) {
  for (final c in MaterialCategory.values) {
    if (c.name == raw) return c;
  }
  return MaterialCategory.consumable;
}

InventoryItem _inventoryItemFromModel(InventoryModel m) {
  // No max quantity field anymore; keep UI logic stable with a reasonable default.
  const double maxS = 100.0;
  final cur = m.currentQuantity;
  return InventoryItem(
    id: m.id,
    name: m.materialName,
    brand: m.brand,
    category: _materialCategoryFromString(m.category),
    unit: m.unit,
    currentStock: cur,
    minStock: maxS * 0.25,
    criticalStock: maxS * 0.10,
    maxStock: maxS,
    reorderQty: maxS * 0.2,
    costPerUnit: m.costPerUnit,
    costPerHour: m.costPerHour,
    sku: m.id,
    location: '',
    lastRestocked: DateTime.now(),
    itemColor: AppColors.indigo,
    autoReorder: false,
    supplier: m.supplier,
    recentUsage: const [],
    reorderHistory: const [],
  );
}

InventoryModel _modelFromInventoryItem(InventoryItem item) {
  return InventoryModel(
    id: item.id,
    materialName: item.name,
    brand: item.brand,
    category: item.category.name,
    unit: item.unit,
    currentQuantity: item.currentStock,
    costPerUnit: item.costPerUnit,
    costPerHour: item.costPerHour,
    supplier: item.supplier,
  );
}

// ─────────────────────────────────────────────
//  WEB INVENTORY VIEW ROOT
// ─────────────────────────────────────────────
class _WebInventoryView extends StatefulWidget {
  const _WebInventoryView();
  @override
  State<_WebInventoryView> createState() => _WebInventoryViewState();
}

class _WebInventoryViewState extends State<_WebInventoryView>
    with _InventoryStateMixin {
  bool _isAdding = false;
  InventoryModel? _selectedItem;
  late final InventoryController controller;

  @override
  void initState() {
    super.initState();
    // Ensure the controller is available before the first build.
    if (!Get.isRegistered<InventoryController>()) {
      Get.put(InventoryController());
    }
    controller = InventoryController.instance;
  }

  List<InventoryModel> get _filteredModels {
    var items = controller.items.where((item) {
      final q = searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          item.materialName.toLowerCase().contains(q) ||
          item.brand.toLowerCase().contains(q);
      final matchesCat =
          categoryFilter == null || item.category == categoryFilter!.name;
      final matchesStock =
          stockFilter == null ||
          _stockLevelForInventoryModel(item) == stockFilter;
      return matchesSearch && matchesCat && matchesStock;
    }).toList();

    switch (sortBy) {
      case 'stock':
        items.sort((a, b) => a.currentQuantity.compareTo(b.currentQuantity));
      case 'cost':
        items.sort((a, b) => b.costPerUnit.compareTo(a.costPerUnit));
      default:
        items.sort((a, b) => a.materialName.compareTo(b.materialName));
    }
    return items;
  }

  int get _criticalCount => controller.items
      .where((i) => _stockLevelForInventoryModel(i) == StockLevel.critical)
      .length;
  int get _lowCount => controller.items
      .where((i) => _stockLevelForInventoryModel(i) == StockLevel.low)
      .length;
  double get _totalValue =>
      controller.items.fold(0, (s, i) => s + i.currentQuantity * i.costPerUnit);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.bg,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 32, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSummaryRow(),
                    const SizedBox(height: 20),
                    _buildFiltersBar(),
                    const SizedBox(height: 16),
                    _buildInventoryTable(),
                  ],
                ),
              ),
            ),
            // ── Side detail panel (Edit or Add) ──
            if (_selectedItem != null || _isAdding)
              Container(
                width: 360,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(left: BorderSide(color: AppColors.border)),
                ),
                child: _isAdding
                    ? AddMaterialPanel(
                        onClose: () => setState(() => _isAdding = false),
                        onAdd: (newItem) async {
                          final saved = await controller.addItem(newItem);
                          if (!mounted) return false;
                          if (saved) {
                            setState(() => _isAdding = false);
                          }
                          return saved;
                        },
                      )
                    : EditMaterialPanel(
                        item: _inventoryItemFromModel(_selectedItem!),
                        onClose: () => setState(() => _selectedItem = null),

                        onSave: (updated) async {
                          try {
                            await controller.updateItem(
                              _modelFromInventoryItem(updated),
                            );

                            setState(() {
                              _selectedItem = controller.items.firstWhere(
                                (e) => e.id == updated.id,
                              );
                            });
                          } catch (e) {
                            print('[EditMaterial] Save Error: $e');
                          }
                        },
                        onDelete: (item) async {
                          await controller.deleteItem(item.id);

                          setState(() {
                            _selectedItem = null;
                          });
                          return true;
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.indigo, AppColors.violet],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Inventory',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Track materials, stock levels and reorder supplies',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Add Materials button in header top-right ──
        ElevatedButton.icon(
          onPressed: () => setState(() {
            _isAdding = true;
            _selectedItem = null;
          }),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Materials'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ── Summary row ──────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        _WebSummaryTile(
          label: 'Total Items',
          value: controller.items.length.toString(),
          color: AppColors.indigo,
          icon: Icons.inventory_2_rounded,
        ),
        const SizedBox(width: 12),

        _WebSummaryTile(
          label: 'Filament Rolls',
          value:
              '${controller.items.where((i) => i.category == MaterialCategory.filament.name).fold(0.0, (s, i) => s + i.currentQuantity).toInt()} left',
          color: AppColors.violet,
          icon: Icons.rotate_right_rounded,
        ),
        const SizedBox(width: 12),
        _WebSummaryTile(
          label: 'Inventory Value',
          value: '₱${(_totalValue / 1000).toStringAsFixed(1)}k',
          color: AppColors.emerald,
          icon: Icons.payments_rounded,
        ),
      ],
    );
  }

  // ── Filters bar ──────────────────────────────
  Widget _buildFiltersBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Search by name or brand…',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _WebDropdownFilter(
          label: categoryFilter == null
              ? 'All Categories'
              : categoryLabel(categoryFilter!),
          icon: Icons.category_rounded,
          color: AppColors.indigo,
          onTap: _showCategoryPicker,
        ),
        const SizedBox(width: 8),
        _WebDropdownFilter(
          label: 'Sort: ${sortBy[0].toUpperCase()}${sortBy.substring(1)}',
          icon: Icons.sort_rounded,
          color: AppColors.textSecondary,
          onTap: _showSortPicker,
        ),
        if (categoryFilter != null || stockFilter != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }


  // ── Inventory table ──────────────────────────
  Widget _buildInventoryTable() {
    final models = _filteredModels;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: _WebTH('Material')),
                Expanded(flex: 2, child: _WebTH('Category')),
                Expanded(flex: 2, child: _WebTH('Quantity')),
                Expanded(flex: 2, child: _WebTH('Cost')),
                Expanded(flex: 2, child: _WebTH('Last Restocked')),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (models.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'No items match your filters',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ),
            )
          else
            ...models.asMap().entries.map(
              (e) => _WebInventoryRow(
                item: _inventoryItemFromModel(e.value),
                isEven: e.key.isEven,
                isSelected: _selectedItem?.id == e.value.id,
                onTap: () => setState(() {
                  _isAdding = false;
                  _selectedItem = _selectedItem?.id == e.value.id
                      ? null
                      : e.value;
                }),
              ),
            ),
        ],
      ),
    );
  }

  // ── Pickers ──────────────────────────────────
  void _showCategoryPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _PickerSheet(
      title: 'Filter by Category',
      options: [
        _PickerOption(
          label: 'All Categories',
          onTap: () {
            setState(() => categoryFilter = null);
            Navigator.pop(context);
          },
        ),
        ...MaterialCategory.values.map(
          (c) => _PickerOption(
            label: categoryLabel(c),
            onTap: () {
              setState(() => categoryFilter = c);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    ),
  );

  void _showSortPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _PickerSheet(
      title: 'Sort By',
      options: [
        _PickerOption(
          label: 'Name (A–Z)',
          onTap: () {
            setState(() => sortBy = 'name');
            Navigator.pop(context);
          },
        ),
        _PickerOption(
          label: 'Stock Level (lowest first)',
          onTap: () {
            setState(() => sortBy = 'stock');
            Navigator.pop(context);
          },
        ),
        _PickerOption(
          label: 'Cost Per Unit (highest first)',
          onTap: () {
            setState(() => sortBy = 'cost');
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
//  WEB: INVENTORY TABLE ROW
// ─────────────────────────────────────────────
class _WebInventoryRow extends StatelessWidget {
  final InventoryItem item;
  final bool isEven, isSelected;
  final VoidCallback onTap;

  const _WebInventoryRow({
    required this.item,
    required this.isEven,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.indigoLight
              : isEven
              ? Colors.white
              : AppColors.bg.withOpacity(0.5),
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.indigo : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            // Name + brand
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.itemColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: item.name,
                          waitDuration: const Duration(milliseconds: 250),
                          child: Text(
                            item.name,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: item.brand,
                          waitDuration: const Duration(milliseconds: 250),
                          child: Text(
                            item.brand,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Category
            Expanded(
              flex: 2,
              child: _SharedCategoryBadge(category: item.category),
            ),
            // Quantity
            Expanded(
              flex: 2,
              child: Text(
                '${item.currentStock % 1 == 0 ? item.currentStock.toInt() : item.currentStock} ${item.unit}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Cost (unit + hourly)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₱${item.costPerUnit.toStringAsFixed(2)}/unit',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₱${item.costPerHour.toStringAsFixed(2)}/hr',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            // Last restocked
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _daysAgo(item.lastRestocked),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _formatDate(item.lastRestocked),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB-ONLY SMALL WIDGETS
// ─────────────────────────────────────────────
class _WebTH extends StatelessWidget {
  final String label;
  const _WebTH(this.label);
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
      letterSpacing: 0.4,
    ),
  );
}

class _WebSummaryTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _WebSummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  WEB DROPDOWN FILTER
// ─────────────────────────────────────────────
class _WebDropdownFilter extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _WebDropdownFilter({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: color),
        ],
      ),
    ),
  );
}
