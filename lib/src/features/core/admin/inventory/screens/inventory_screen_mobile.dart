part of 'inventory_screen.dart';

// ─────────────────────────────────────────────
//  MOBILE INVENTORY VIEW
// ─────────────────────────────────────────────
class _MobileInventoryView extends StatefulWidget {
  const _MobileInventoryView();
  @override
  State<_MobileInventoryView> createState() => _MobileInventoryViewState();
}

class _MobileInventoryViewState extends State<_MobileInventoryView>
    with _InventoryStateMixin {
  bool _showFilters = false;
  InventoryItem? _selectedItem;
  bool _isAdding = false;

  late List<InventoryItem> _localItems;

  @override
  void initState() {
    super.initState();
    _localItems = List<InventoryItem>.from(kInventory);
  }

  List<InventoryItem> get filtered {
    var items = _localItems.where((item) {
      final q = searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.brand.toLowerCase().contains(q);
      final matchesCat =
          categoryFilter == null || item.category == categoryFilter;
      final matchesStock =
          stockFilter == null || item.stockLevel == stockFilter;
      return matchesSearch && matchesCat && matchesStock;
    }).toList();

    items.sort((a, b) {
      if (sortBy == 'stock') return a.currentStock.compareTo(b.currentStock);
      if (sortBy == 'cost') return b.costPerUnit.compareTo(a.costPerUnit);
      return a.name.compareTo(b.name);
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Inventory',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded,
                color: AppColors.textSecondary),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded,
                color: AppColors.textSecondary),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.indigo),
            onPressed: () => setState(() {
              _isAdding = true;
              _selectedItem = null;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilterChips(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _MobileInventoryCard(
                item: filtered[i],
                onTap: () => setState(() {
                  _isAdding = false;
                  _selectedItem = filtered[i];
                }),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _selectedItem != null || _isAdding
          ? Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: _isAdding
                  ? _AddMaterialPanelMobile(
                      onClose: () => setState(() => _isAdding = false),
                      onAdd: (newItem) {
                        setState(() {
                          _localItems.add(newItem);
                          _isAdding = false;
                        });
                      },
                    )
                  : _ItemDetailContent(
                      item: _selectedItem!,
                      onClose: () => setState(() => _selectedItem = null),
                      showCloseButton: true,
                    ),
            )
          : null,
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Category: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ...MaterialCategory.values.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(categoryLabel(c),
                            style: TextStyle(fontSize: 12)),
                        selected: categoryFilter == c,
                        onSelected: (_) => setState(() {
                          categoryFilter = categoryFilter == c ? null : c;
                        }),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Stock: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ...StockLevel.values.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(_stockLabel(s),
                            style: TextStyle(fontSize: 12)),
                        selected: stockFilter == s,
                        onSelected: (_) => setState(() {
                          stockFilter = stockFilter == s ? null : s;
                        }),
                      ),
                    )),
                if (categoryFilter != null || stockFilter != null)
                  TextButton(
                    onPressed: clearFilters,
                    child: const Text('Clear',
                        style: TextStyle(fontSize: 12, color: AppColors.rose)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: TextField(
          autofocus: true,
          onChanged: (v) => setState(() => searchQuery = v),
          decoration: const InputDecoration(
            hintText: 'Search by name or brand',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE INVENTORY CARD
// ─────────────────────────────────────────────
class _MobileInventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const _MobileInventoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final stockColor = _stockColor(item.stockLevel);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.border)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: item.itemColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      item.category == MaterialCategory.filament
                          ? Icons.rotate_right_rounded
                          : item.category == MaterialCategory.resin
                              ? Icons.water_drop_rounded
                              : Icons.inventory_2_rounded,
                      color: item.itemColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text(item.brand,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.currentStock % 1 == 0 ? item.currentStock.toInt() : item.currentStock} ${item.unit}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: stockColor),
                      ),
                      Text('₱${item.costPerUnit.toStringAsFixed(2)}/unit',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontFamily: 'monospace')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SharedCategoryBadge(category: item.category),
                  const Spacer(),
                  Text('₱${item.costPerHour.toStringAsFixed(2)}/hr',
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontFamily: 'monospace')),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.stockPercent,
                  backgroundColor: Colors.grey.shade200,
                  color: stockColor,
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ADD MATERIAL PANEL MOBILE
// ─────────────────────────────────────────────
class _AddMaterialPanelMobile extends StatefulWidget {
  const _AddMaterialPanelMobile({required this.onClose, required this.onAdd});

  final VoidCallback onClose;
  final ValueChanged<InventoryItem> onAdd;

  @override
  State<_AddMaterialPanelMobile> createState() => _AddMaterialPanelMobileState();
}

class _AddMaterialPanelMobileState extends State<_AddMaterialPanelMobile> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '0');
  final _maxCtrl = TextEditingController(text: '100');
  final _costUnitCtrl = TextEditingController(text: '0');
  final _costHourCtrl = TextEditingController(text: '0');
  final _supplierCtrl = TextEditingController();
  MaterialCategory _category = MaterialCategory.filament;
  String _unit = 'rolls';
  Color _itemColor = const Color(0xFF6366F1);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _qtyCtrl.dispose();
    _maxCtrl.dispose();
    _costUnitCtrl.dispose();
    _costHourCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (_nameCtrl.text.trim().isEmpty) return;

    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final max = double.tryParse(_maxCtrl.text) ?? 100;

    final newItem = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      category: _category,
      unit: _unit,
      currentStock: qty,
      minStock: 0,
      criticalStock: 0,
      maxStock: max,
      reorderQty: 0,
      costPerUnit: double.tryParse(_costUnitCtrl.text) ?? 0,
      costPerHour: double.tryParse(_costHourCtrl.text) ?? 0,
      sku: '',
      location: '',
      lastRestocked: DateTime.now(),
      itemColor: _itemColor,
      autoReorder: false,
      supplier: _supplierCtrl.text.trim(),
      recentUsage: const [],
      reorderHistory: const [],
    );
    widget.onAdd(newItem);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Add Material',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MobileEditField(label: 'Material Name *', controller: _nameCtrl),
          _MobileEditField(label: 'Brand', controller: _brandCtrl),
          const SizedBox(height: 8),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: MaterialCategory.values.map((c) {
              final active = _category == c;
              return ChoiceChip(
                label: Text(categoryLabel(c)),
                selected: active,
                onSelected: (_) => setState(() => _category = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Unit', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: ['rolls', 'kg', 'g', 'L', 'mL', 'pcs', 'bottles'].map((u) {
              final active = _unit == u;
              return ChoiceChip(
                label: Text(u),
                selected: active,
                onSelected: (_) => setState(() => _unit = u),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _MobileEditField(
              label: 'Current Quantity',
              controller: _qtyCtrl,
              keyboardType: TextInputType.number),
          _MobileEditField(
              label: 'Max Quantity',
              controller: _maxCtrl,
              keyboardType: TextInputType.number),
          Row(
            children: [
              Expanded(
                child: _MobileEditField(
                    label: 'Cost Per Unit (₱)',
                    controller: _costUnitCtrl,
                    keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MobileEditField(
                    label: 'Cost Per Hour (₱)',
                    controller: _costHourCtrl,
                    keyboardType: TextInputType.number),
              ),
            ],
          ),
          _MobileEditField(label: 'Supplier', controller: _supplierCtrl),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClose,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleAdd,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigo),
                  child: const Text('Add Material'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE EDIT FIELD
// ─────────────────────────────────────────────
class _MobileEditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _MobileEditField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ],
      ),
    );
  }
}