part of 'inventory_screen.dart';

// ─────────────────────────────────────────────
//  MOBILE INVENTORY VIEW ROOT
// ─────────────────────────────────────────────
class _MobileInventoryView extends StatefulWidget {
  const _MobileInventoryView();
  @override
  State<_MobileInventoryView> createState() => _MobileInventoryViewState();
}

class _MobileInventoryViewState extends State<_MobileInventoryView>
    with _InventoryStateMixin {

  @override
  Widget build(BuildContext context) {
    final items = filtered;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        // Stats strip
        _MobileStatsStrip(
          totalSkus: kInventory.length,
          criticalCount: criticalCount,
          lowCount: lowCount,
          inventoryValue: totalInventoryValue,
        ),
        // Alert banner (if needed)
        if (alertCount > 0) _buildMobileAlertBanner(),
        // Active filter chips
        if (categoryFilter != null || stockFilter != null || searchQuery.isNotEmpty)
          _buildActiveFilters(),
        // Item list
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _MobileInventoryCard(
                    item: items[i],
                    onTap: () => _showItemDetail(items[i]),
                  ),
                ),
        ),
      ]),
    );
  }

  // ── AppBar ───────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final hasFilters = categoryFilter != null ||
        stockFilter != null ||
        searchQuery.isNotEmpty;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: 16,
      title: Row(children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.indigo, AppColors.violet],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Inventory',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary)),
          Text('Materials & Stock',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 22),
          onPressed: _showSearchSheet,
        ),
        // Filter button with dot indicator
        Stack(alignment: Alignment.center, children: [
          IconButton(
            icon: const Icon(Icons.tune_rounded,
                color: AppColors.textSecondary, size: 22),
            onPressed: _showFilterSheet,
          ),
          if (hasFilters)
            Positioned(
              top: 8, right: 8,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.indigo, shape: BoxShape.circle),
              ),
            ),
        ]),
        // Sort button
        IconButton(
          icon: const Icon(Icons.sort_rounded,
              color: AppColors.textSecondary, size: 22),
          onPressed: _showSortSheet,
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Alert banner (mobile) ────────────────────
  Widget _buildMobileAlertBanner() {
    return GestureDetector(
      onTap: () =>
          setState(() => stockFilter = StockLevel.critical),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.roseLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.rose.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.warning_rounded,
                color: AppColors.rose, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$alertCount item${alertCount > 1 ? 's' : ''} need attention',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.rose),
                ),
                const Text('Tap to filter critical items',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.rose),
        ]),
      ),
    );
  }

  // ── Active filter chips ──────────────────────
  Widget _buildActiveFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(children: [
        if (searchQuery.isNotEmpty)
          _ActiveFilterChip(
            label: '"$searchQuery"',
            color: AppColors.indigo,
            onRemove: () => setState(() => searchQuery = ''),
          ),
        if (categoryFilter != null) ...[
          if (searchQuery.isNotEmpty) const SizedBox(width: 8),
          _ActiveFilterChip(
            label: _categoryLabel(categoryFilter!),
            color: AppColors.violet,
            onRemove: () => setState(() => categoryFilter = null),
          ),
        ],
        if (stockFilter != null) ...[
          if (categoryFilter != null || searchQuery.isNotEmpty) const SizedBox(width: 8),
          _ActiveFilterChip(
            label: _stockLabel(stockFilter!),
            color: _stockColor(stockFilter!),
            onRemove: () => setState(() => stockFilter = null),
          ),
        ],
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              searchQuery = '';
              clearFilters();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border)),
            child: const Text('Clear all',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  // ── Empty state ──────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: AppColors.indigoLight, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_rounded,
                size: 32, color: AppColors.indigo),
          ),
          const SizedBox(height: 16),
          const Text('No items found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Try adjusting your search or filters',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }

  // ── Item detail bottom sheet ─────────────────
  void _showItemDetail(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                child: _ItemDetailContent(
                  item: item,
                  onClose: () => Navigator.pop(context),
                  showCloseButton: false,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Search sheet ─────────────────────────────
  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        String localQ = searchQuery;
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Search Inventory',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border)),
                child: TextField(
                  autofocus: true,
                  controller: TextEditingController(text: searchQuery),
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Name, brand, or SKU…',
                    hintStyle:
                        TextStyle(fontSize: 14, color: AppColors.textMuted),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (v) => localQ = v,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => searchQuery = localQ);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Search'),
                ),
              ),
              if (searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() => searchQuery = '');
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Search',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ]),
          ),
        );
      },
    );
  }

  // ── Filter sheet ─────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        // Declared outside StatefulBuilder so setSheetState rebuilds
        // don't reset them back to the current mixin values.
        MaterialCategory? localCat = categoryFilter;
        StockLevel? localStock = stockFilter;

        return StatefulBuilder(
          builder: (ctx, setSheetState) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            builder: (_, sc) => ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                Row(children: [
                  const Text('Filter Inventory',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(clearFilters);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear All',
                        style: TextStyle(color: AppColors.rose)),
                  ),
                ]),
                const SizedBox(height: 16),

                const Text('Category',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _MobileFilterChip(
                    label: 'All',
                    isActive: localCat == null,
                    activeColor: AppColors.indigo,
                    onTap: () => setSheetState(() => localCat = null),
                  ),
                  ...MaterialCategory.values.map((c) => _MobileFilterChip(
                        label: _categoryLabel(c),
                        isActive: localCat == c,
                        activeColor: _categoryColor(c),
                        onTap: () => setSheetState(() => localCat = c),
                      )),
                ]),
                const SizedBox(height: 16),

                const Text('Stock Level',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _MobileFilterChip(
                    label: 'All',
                    isActive: localStock == null,
                    activeColor: AppColors.indigo,
                    onTap: () => setSheetState(() => localStock = null),
                  ),
                  ...StockLevel.values.map((s) => _MobileFilterChip(
                        label: _stockLabel(s),
                        isActive: localStock == s,
                        activeColor: _stockColor(s),
                        onTap: () => setSheetState(() => localStock = s),
                      )),
                ]),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        categoryFilter = localCat;
                        stockFilter = localStock;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Sort sheet ───────────────────────────────
  void _showSortSheet() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _PickerSheet(title: 'Sort By', options: [
      _PickerOption(
          label: 'Name (A–Z)',
          onTap: () { setState(() => sortBy = 'name'); Navigator.pop(context); }),
      _PickerOption(
          label: 'Stock Level (lowest first)',
          onTap: () { setState(() => sortBy = 'stock'); Navigator.pop(context); }),
      _PickerOption(
          label: 'Cost Per Unit (highest first)',
          onTap: () { setState(() => sortBy = 'cost'); Navigator.pop(context); }),
    ]),
  );

  Color _categoryColor(MaterialCategory c) => switch (c) {
    MaterialCategory.filament => AppColors.indigo,
    MaterialCategory.resin => AppColors.violet,
    MaterialCategory.powder => AppColors.amber,
    MaterialCategory.sparePart => AppColors.sky,
    MaterialCategory.consumable => AppColors.emerald,
  };
}

// ─────────────────────────────────────────────
//  MOBILE: STATS STRIP
// ─────────────────────────────────────────────
class _MobileStatsStrip extends StatelessWidget {
  final int totalSkus, criticalCount, lowCount;
  final double inventoryValue;
  const _MobileStatsStrip(
      {required this.totalSkus,
      required this.criticalCount,
      required this.lowCount,
      required this.inventoryValue});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _MobileStatCard(
            label: 'Total SKUs',
            value: totalSkus.toString(),
            color: AppColors.indigo,
            icon: Icons.inventory_2_rounded),
        const SizedBox(width: 8),
        _MobileStatCard(
            label: 'Critical',
            value: criticalCount.toString(),
            color: AppColors.rose,
            icon: Icons.warning_rounded),
        const SizedBox(width: 8),
        _MobileStatCard(
            label: 'Low Stock',
            value: lowCount.toString(),
            color: AppColors.amber,
            icon: Icons.trending_down_rounded),
        const SizedBox(width: 8),
        _MobileStatCard(
            label: 'Value',
            value: '₱${(inventoryValue / 1000).toStringAsFixed(1)}k',
            color: AppColors.emerald,
            icon: Icons.payments_rounded),
      ]),
    ),
  );
}

class _MobileStatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _MobileStatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15))),
    child: Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Text(value,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color)),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
    ]),
  );
}

// ─────────────────────────────────────────────
//  MOBILE: INVENTORY CARD
// ─────────────────────────────────────────────
class _MobileInventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const _MobileInventoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sc = _stockColor(item.stockLevel);
    final sl = _stockLight(item.stockLevel);
    final isCritical = item.stockLevel == StockLevel.critical;
    final isLow = item.stockLevel == StockLevel.low;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isCritical
                  ? AppColors.rose.withOpacity(0.3)
                  : AppColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(children: [
            // Top accent bar for critical/low
            if (isCritical || isLow)
              Container(height: 3, color: sc),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: color dot + name + stock badge
                  Row(children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                          color: item.itemColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: sl,
                          borderRadius: BorderRadius.circular(7)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (isCritical) ...[
                          Icon(Icons.error_rounded, size: 10, color: sc),
                          const SizedBox(width: 3),
                        ],
                        Text(_stockLabel(item.stockLevel),
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: sc)),
                      ]),
                    ),
                  ]),

                  const SizedBox(height: 4),
                  // Row 2: brand + sku
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('${item.brand}  ·  ${item.sku}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ),

                  const SizedBox(height: 10),

                  // Row 3: category + location badges
                  Row(children: [
                    _SharedCategoryBadge(category: item.category),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.location_on_rounded,
                            size: 10, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(item.location,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ]),
                    ),
                    const Spacer(),
                    // Auto-reorder indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.autoReorder
                            ? AppColors.emeraldLight
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                            item.autoReorder
                                ? Icons.autorenew_rounded
                                : Icons.block_rounded,
                            size: 10,
                            color: item.autoReorder
                                ? AppColors.emerald
                                : AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(item.autoReorder ? 'Auto' : 'Manual',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item.autoReorder
                                    ? AppColors.emerald
                                    : AppColors.textMuted)),
                      ]),
                    ),
                  ]),

                  const SizedBox(height: 12),

                  // Stock progress bar + quantity
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.currentStock % 1 == 0 ? item.currentStock.toInt() : item.currentStock} / ${item.maxStock.toInt()} ${item.unit}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                              Text(
                                '${(item.stockPercent * 100).toInt()}%',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: sc),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: item.stockPercent,
                              backgroundColor: sc.withOpacity(0.12),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(sc),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 10),

                  // Row: Cost + restocked + chevron
                  Row(children: [
                    // Cost per unit
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.indigoLight,
                          borderRadius: BorderRadius.circular(7)),
                      child: Text(
                        '₱${item.costPerUnit.toStringAsFixed(0)}/unit',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.indigo,
                            fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Restocked ${_daysAgo(item.lastRestocked)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.textMuted.withOpacity(0.5)),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE: ACTIVE FILTER CHIP
// ─────────────────────────────────────────────
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;
  const _ActiveFilterChip(
      {required this.label, required this.color, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color)),
      const SizedBox(width: 5),
      GestureDetector(
        onTap: onRemove,
        child: Icon(Icons.close_rounded, size: 13, color: color),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────
//  MOBILE: FILTER CHIP (used in filter sheet)
// ─────────────────────────────────────────────
class _MobileFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  const _MobileFilterChip(
      {required this.label,
      required this.isActive,
      required this.activeColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor
            : activeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive
                ? activeColor
                : activeColor.withOpacity(0.2)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : activeColor)),
    ),
  );
}