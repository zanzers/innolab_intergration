part of 'inventory_screen.dart';

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
  InventoryItem? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  if (alertCount > 0) ...[
                    const SizedBox(height: 16),
                    _buildAlertBanner(),
                  ],
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
          // ── Side detail panel ──
          if (_selectedItem != null)
            Container(
              width: 360,
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border:
                    Border(left: BorderSide(color: AppColors.border)),
              ),
              child: _ItemDetailContent(
                item: _selectedItem!,
                onClose: () => setState(() => _selectedItem = null),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 6, height: 32,
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
              const Text('Inventory',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      color: AppColors.textPrimary)),
            ]),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                  'Track materials, stock levels and reorder supplies',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
      if (alertCount > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.roseLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.rose.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.warning_rounded, size: 15, color: AppColors.rose),
            const SizedBox(width: 7),
            Text('$alertCount items need attention',
                style: const TextStyle(
                    color: AppColors.rose,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ]),
        ),
    ]);
  }

  // ── Alert Banner ─────────────────────────────
  Widget _buildAlertBanner() {
    final criticalItems = kInventory
        .where((i) => i.stockLevel == StockLevel.critical)
        .toList();
    final lowItems =
        kInventory.where((i) => i.stockLevel == StockLevel.low).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.roseLight,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.inventory_2_rounded,
              color: AppColors.rose, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stock Alert',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: [
                  ...criticalItems.map((i) =>
                      _WebAlertChip(name: i.name, level: StockLevel.critical)),
                  ...lowItems.map((i) =>
                      _WebAlertChip(name: i.name, level: StockLevel.low)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: () =>
              setState(() => stockFilter = StockLevel.critical),
          icon: const Icon(Icons.filter_list_rounded, size: 14),
          label: const Text('Show Critical'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.rose,
            backgroundColor: AppColors.roseLight,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }

  // ── Summary row ──────────────────────────────
  Widget _buildSummaryRow() {
    return Row(children: [
      _WebSummaryTile(
          label: 'Total SKUs',
          value: kInventory.length.toString(),
          color: AppColors.indigo,
          icon: Icons.inventory_2_rounded),
      const SizedBox(width: 12),
      _WebSummaryTile(
          label: 'Critical Stock',
          value: criticalCount.toString(),
          color: AppColors.rose,
          icon: Icons.warning_rounded),
      const SizedBox(width: 12),
      _WebSummaryTile(
          label: 'Low Stock',
          value: lowCount.toString(),
          color: AppColors.amber,
          icon: Icons.trending_down_rounded),
      const SizedBox(width: 12),
      _WebSummaryTile(
          label: 'Filament Rolls',
          value: '${kInventory.where((i) => i.category == MaterialCategory.filament).fold(0.0, (s, i) => s + i.currentStock).toInt()} left',
          color: AppColors.violet,
          icon: Icons.rotate_right_rounded),
      const SizedBox(width: 12),
      _WebSummaryTile(
          label: 'Inventory Value',
          value:
              '₱${(totalInventoryValue / 1000).toStringAsFixed(1)}k',
          color: AppColors.emerald,
          icon: Icons.payments_rounded),
      const SizedBox(width: 12),
      _WebSummaryTile(
          label: 'Auto-Reorder On',
          value: kInventory.where((i) => i.autoReorder).length.toString(),
          color: AppColors.sky,
          icon: Icons.autorenew_rounded),
    ]);
  }

  // ── Filters bar ──────────────────────────────
  Widget _buildFiltersBar() {
    return Row(children: [
      Expanded(
        child: Container(
          height: 42,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            style: const TextStyle(
                fontSize: 14, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Search by name, brand or SKU…',
              hintStyle:
                  TextStyle(fontSize: 13, color: AppColors.textMuted),
              prefixIcon: Icon(Icons.search_rounded,
                  size: 18, color: AppColors.textMuted),
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
            : _categoryLabel(categoryFilter!),
        icon: Icons.category_rounded,
        color: AppColors.indigo,
        onTap: _showCategoryPicker,
      ),
      const SizedBox(width: 8),
      _WebDropdownFilter(
        label: stockFilter == null
            ? 'All Stock'
            : _stockLabel(stockFilter!),
        icon: Icons.bar_chart_rounded,
        color: stockFilter == null
            ? AppColors.textSecondary
            : _stockColor(stockFilter!),
        onTap: _showStockPicker,
      ),
      const SizedBox(width: 8),
      _WebDropdownFilter(
        label:
            'Sort: ${sortBy[0].toUpperCase()}${sortBy.substring(1)}',
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
                  horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.textMuted),
            ),
          ),
        ),
    ]);
  }

  // ── Inventory table ──────────────────────────
  Widget _buildInventoryTable() {
    final items = filtered;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16))),
          child: const Row(children: [
            Expanded(flex: 4, child: _WebTH('Material')),
            Expanded(flex: 2, child: _WebTH('Category')),
            Expanded(flex: 2, child: _WebTH('Stock Level')),
            Expanded(flex: 3, child: _WebTH('Quantity')),
            Expanded(flex: 2, child: _WebTH('Cost/Unit')),
            Expanded(flex: 2, child: _WebTH('Location')),
            Expanded(flex: 2, child: _WebTH('Auto-Reorder')),
            Expanded(flex: 2, child: _WebTH('Last Restocked')),
          ]),
        ),
        const Divider(height: 1, color: AppColors.border),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text('No items match your filters',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 14)),
            ),
          )
        else
          ...items.asMap().entries.map((e) => _WebInventoryRow(
                item: e.value,
                isEven: e.key.isEven,
                isSelected: _selectedItem?.id == e.value.id,
                onTap: () => setState(() {
                  _selectedItem = _selectedItem?.id == e.value.id
                      ? null
                      : e.value;
                }),
              )),
      ]),
    );
  }

  // ── Pickers ──────────────────────────────────
  void _showCategoryPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _PickerSheet(title: 'Filter by Category', options: [
      _PickerOption(label: 'All Categories', onTap: () { setState(() => categoryFilter = null); Navigator.pop(context); }),
      ...MaterialCategory.values.map((c) => _PickerOption(
          label: _categoryLabel(c),
          onTap: () { setState(() => categoryFilter = c); Navigator.pop(context); })),
    ]),
  );

  void _showStockPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _PickerSheet(title: 'Filter by Stock', options: [
      _PickerOption(label: 'All Stock', onTap: () { setState(() => stockFilter = null); Navigator.pop(context); }),
      ...StockLevel.values.map((s) => _PickerOption(
          label: _stockLabel(s),
          onTap: () { setState(() => stockFilter = s); Navigator.pop(context); })),
    ]),
  );

  void _showSortPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _PickerSheet(title: 'Sort By', options: [
      _PickerOption(label: 'Name (A–Z)', onTap: () { setState(() => sortBy = 'name'); Navigator.pop(context); }),
      _PickerOption(label: 'Stock Level (lowest first)', onTap: () { setState(() => sortBy = 'stock'); Navigator.pop(context); }),
      _PickerOption(label: 'Cost Per Unit (highest first)', onTap: () { setState(() => sortBy = 'cost'); Navigator.pop(context); }),
    ]),
  );
}

// ─────────────────────────────────────────────
//  WEB: INVENTORY TABLE ROW
// ─────────────────────────────────────────────
class _WebInventoryRow extends StatelessWidget {
  final InventoryItem item;
  final bool isEven, isSelected;
  final VoidCallback onTap;

  const _WebInventoryRow(
      {required this.item,
      required this.isEven,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sl = item.stockLevel;
    final sc = _stockColor(sl);
    final sl2 = _stockLight(sl);

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
                  width: 3)),
        ),
        child: Row(children: [
          // Name + brand
          Expanded(
            flex: 4,
            child: Row(children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                    color: item.itemColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('${item.brand}  ·  ${item.sku}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                ]),
              ),
            ]),
          ),
          // Category
          Expanded(
              flex: 2,
              child: _SharedCategoryBadge(category: item.category)),
          // Stock level badge
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: sl2, borderRadius: BorderRadius.circular(7)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (sl == StockLevel.critical)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.error_rounded, size: 11, color: sc),
                  ),
                Text(_stockLabel(sl),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sc)),
              ]),
            ),
          ),
          // Quantity + bar
          Expanded(
            flex: 3,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                '${item.currentStock % 1 == 0 ? item.currentStock.toInt() : item.currentStock} / ${item.maxStock.toInt()} ${item.unit}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.stockPercent,
                  backgroundColor: sc.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(sc),
                  minHeight: 4,
                ),
              ),
            ]),
          ),
          // Cost
          Expanded(
            flex: 2,
            child: Text('₱${item.costPerUnit.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace')),
          ),
          // Location
          Expanded(
            flex: 2,
            child: Row(children: [
              const Icon(Icons.location_on_rounded,
                  size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(item.location,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
          // Auto-reorder
          Expanded(
            flex: 2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.autoReorder
                    ? AppColors.emeraldLight
                    : AppColors.bg,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                    item.autoReorder
                        ? Icons.autorenew_rounded
                        : Icons.block_rounded,
                    size: 11,
                    color: item.autoReorder
                        ? AppColors.emerald
                        : AppColors.textMuted),
                const SizedBox(width: 4),
                Text(item.autoReorder ? 'ON' : 'OFF',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: item.autoReorder
                            ? AppColors.emerald
                            : AppColors.textMuted)),
              ]),
            ),
          ),
          // Last restocked
          Expanded(
            flex: 2,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(_daysAgo(item.lastRestocked),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text(_formatDate(item.lastRestocked),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
            ]),
          ),
        ]),
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
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.4));
}

class _WebAlertChip extends StatelessWidget {
  final String name;
  final StockLevel level;
  const _WebAlertChip({required this.name, required this.level});
  @override
  Widget build(BuildContext context) {
    final color = level == StockLevel.critical ? AppColors.rose : AppColors.amber;
    final light = level == StockLevel.critical
        ? AppColors.roseLight
        : AppColors.amberLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: light,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Text(name,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _WebSummaryTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _WebSummaryTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});
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
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.4)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted)),
          ]),
        ),
      ]),
    ),
  );
}

class _WebDropdownFilter extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _WebDropdownFilter(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(width: 4),
        Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: color),
      ]),
    ),
  );
}