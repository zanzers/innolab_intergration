part of 'user_quote_screen.dart';

// ─────────────────────────────────────────────
//  MOBILE VIEW (redesigned with expandable bottom card)
// ─────────────────────────────────────────────
class _MobileQuoteView extends StatefulWidget {
  const _MobileQuoteView();
  @override
  State<_MobileQuoteView> createState() => _MobileQuoteViewState();
}

class _MobileQuoteViewState extends State<_MobileQuoteView> with _QuoteStateMixin {
  int _expandedSection = 0; // 0 = file, 1 = printer, 2 = material
  bool _isSummaryExpanded = false;
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressStrip(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              child: Column(
                children: [
                  _buildFileSection(),
                  const SizedBox(height: 10),
                  _buildPrinterSection(),
                  const SizedBox(height: 10),
                  _buildMaterialSection(),
                  const SizedBox(height: 80), // space for bottom card
                ],
              ),
            ),
          ),
          _buildBottomCard(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_kPrimary, _kPrimaryDark],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get a Quote',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1D23),
                  ),
                ),
                Text(
                  '3D Print Request',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      );

  Widget _buildProgressStrip() {
    final s1 = selectedFileName != null;
    final s2 = currentItem != null;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          _StepPill(step: 1, label: 'File', done: s1, active: !s1),
          Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: s1 ? _kPrimary : Colors.grey.shade200,
            ),
          ),
          _StepPill(step: 2, label: 'Material', done: s2, active: s1 && !s2),
          Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: s2 ? _kPrimary : Colors.grey.shade200,
            ),
          ),
          _StepPill(step: 3, label: 'Review', done: false, active: s2),
        ],
      ),
    );
  }

  Widget _buildFileSection() {
    return _buildExpandableSection(
      index: 0,
      icon: Iconsax.document_upload,
      title: 'Upload 3D Model',
      badge: selectedFileName,
      child: _buildFileBody(),
    );
  }

  Widget _buildPrinterSection() {
    return _buildExpandableSection(
      index: 1,
      icon: Iconsax.cpu,
      title: 'Select Printer',
      badge: selectedPrinter?.name,
      child: _buildPrinterBody(),
    );
  }

  Widget _buildMaterialSection() {
    return _buildExpandableSection(
      index: 2,
      icon: Iconsax.layer,
      title: 'Choose Material',
      badge: currentItem?.material.name,
      child: _buildMaterialBody(),
    );
  }

  Widget _buildExpandableSection({
    required int index,
    required IconData icon,
    required String title,
    String? badge,
    required Widget child,
  }) {
    final isExpanded = _expandedSection == index;
    final isDone = badge != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? _kPrimary.withOpacity(0.25)
              : isExpanded
                  ? _kPrimary.withOpacity(0.2)
                  : Colors.grey.shade200,
          width: isDone || isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedSection = expanded ? index : -1;
            });
            if (expanded) {
              _scrollToSection(index);
            }
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDone
                  ? _kPrimary
                  : isExpanded
                      ? _kPrimaryLight
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 15,
              color: isDone
                  ? Colors.white
                  : isExpanded
                      ? _kPrimary
                      : Colors.grey.shade500,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isExpanded ? _kPrimaryDark : const Color(0xFF1A1D23),
            ),
          ),
          subtitle: badge != null && !isExpanded
              ? Text(
                  badge,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: isDone && !isExpanded
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                )
              : Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
          children: [child],
        ),
      ),
    );
  }

  void _scrollToSection(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        final offset = (index * 250.0).clamp(0.0, _scrollCtrl.position.maxScrollExtent);
        _scrollCtrl.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildFileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: pickFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              color: selectedFileName != null ? _kPrimaryLight.withOpacity(0.5) : Colors.grey.shade50,
              border: Border.all(
                color: selectedFileName != null ? _kPrimary.withOpacity(0.4) : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedFileName != null ? _kPrimary.withOpacity(0.12) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    selectedFileName != null ? Iconsax.document_text : Iconsax.document_upload,
                    size: 22,
                    color: selectedFileName != null ? _kPrimary : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  selectedFileName ?? 'Tap to upload your 3D file',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selectedFileName != null ? FontWeight.w600 : FontWeight.normal,
                    color: selectedFileName != null ? _kPrimaryDark : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Iconsax.folder_open, size: 15),
                  label: Text(selectedFileName != null ? 'Change File' : 'Browse Files'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 7, runSpacing: 7, children: [
          _FmtChip(ext: 'STL', color: _kPrimary),
          _FmtChip(ext: 'OBJ', color: const Color(0xFF1E88E5)),
          _FmtChip(ext: '3MF', color: const Color(0xFF43A047)),
          _FmtChip(ext: 'ZIP', color: const Color(0xFFFF8F00)),
        ]),
        if (selectedFileName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPrimaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kPrimary.withOpacity(0.15)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ModelInfoChip(
                  icon: Iconsax.document_text,
                  label: 'File',
                  value: selectedFileName!,
                ),
                if (estimatedVolume != null)
                  _ModelInfoChip(
                    icon: Iconsax.box,
                    label: 'Volume',
                    value: '${estimatedVolume!.toStringAsFixed(1)} cm³',
                  ),
                if (modelWidth != null)
                  _ModelInfoChip(
                    icon: Iconsax.maximize_3,
                    label: 'Size',
                    value: '${modelWidth!.toInt()}×${modelDepth!.toInt()}×${modelHeight!.toInt()} mm',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _expandedSection = 1),
              icon: const Icon(Iconsax.cpu, size: 15),
              label: const Text('Choose Printer  →'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
        if (modelSizeWarning != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.warning_2, color: Color(0xFFE53935), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    modelSizeWarning!,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrinterBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...printers.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MobilePrinterCard(
              printer: p,
              isSelected: selectedPrinter?.id == p.id,
              onTap: () => setState(() {
                selectedPrinter = selectedPrinter?.id == p.id ? null : p;
                if (selectedFileName != null) _checkModelSize();
                if (currentItem != null) _updateFromAnalysis();
              }),
            ),
          ),
        ),
        if (selectedPrinter != null) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _expandedSection = 2),
              icon: const Icon(Iconsax.layer, size: 15),
              label: const Text('Choose Material  →'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMaterialBody() {
    final filtered = filteredMaterials;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(
                label: 'All',
                icon: Iconsax.grid_1,
                color: Colors.grey.shade600,
                isSelected: selectedCategory == null,
                onTap: () => setState(() => selectedCategory = null),
              ),
              const SizedBox(width: 8),
              ..._kMaterialCategories.map(
                (info) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: info.name,
                    icon: info.icon,
                    color: info.color,
                    isSelected: selectedCategory == info.category,
                    onTap: () => setState(() => selectedCategory = info.category),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.box, size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('No materials in this category', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
          )
        else
          ...filtered.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MaterialCard(
                material: m,
                categoryColor: _QuoteStateMixin.categoryColor(m.category),
                categoryIcon: _QuoteStateMixin.categoryIcon(m.category),
                categoryName: _QuoteStateMixin.categoryName(m.category),
                isSelected: currentItem?.material.id == m.id,
                onAdd: () => setState(() {
                  selectMaterial(m);
                  _isSummaryExpanded = true; // expand bottom card automatically
                  _scrollToSection(2);
                }),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  EXPANDABLE BOTTOM CARD
  // ─────────────────────────────────────────────
  Widget _buildBottomCard() {
    final canSubmit = currentItem != null && modelSizeWarning == null;
    final total = grandTotal;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isSummaryExpanded = !_isSummaryExpanded;
        });
        if (_isSummaryExpanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollCtrl.hasClients) {
              _scrollCtrl.animateTo(
                _scrollCtrl.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          _isSummaryExpanded ? 16 : MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            if (!_isSummaryExpanded) _buildCollapsedState(total)
            else _buildExpandedState(canSubmit),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedState(double total) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grand Total',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              '₱${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _kPrimary,
              ),
            ),
          ],
        ),
        const Spacer(),
        Icon(
          Icons.keyboard_arrow_up_rounded,
          color: _kPrimary,
          size: 28,
        ),
        const SizedBox(width: 4),
        Text(
          'Details',
          style: TextStyle(color: _kPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildExpandedState(bool canSubmit) {
    if (currentItem == null) {
      return const SizedBox.shrink(); // should not happen
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Material badge
        _buildMaterialBadge(),
        const SizedBox(height: 16),

        // Material‑specific options (metals / resins)
        if (currentItem!.material.category == MaterialCategory.metals) ...[
          if (currentItem!.material.surfaceFinishes != null) ...[
            _OptionsLabel(label: 'SURFACE FINISH'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: currentItem!.material.surfaceFinishes!.map((f) {
                final sel = currentItem!.selectedFinish == f;
                return ChoiceChip(
                  label: Text(f, style: const TextStyle(fontSize: 12)),
                  selected: sel,
                  onSelected: (s) => s ? updateFinish(f) : null,
                  backgroundColor: Colors.white,
                  selectedColor: _kPrimary,
                  side: BorderSide(color: sel ? _kPrimary : Colors.grey.shade300, width: 1.5),
                  labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (currentItem!.material.tolerances != null) ...[
            _OptionsLabel(label: 'TOLERANCE'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: currentItem!.material.tolerances!.map((t) {
                final sel = currentItem!.selectedTolerance == t;
                return ChoiceChip(
                  label: Text(t, style: const TextStyle(fontSize: 12)),
                  selected: sel,
                  onSelected: (s) => s ? updateTolerance(t) : null,
                  backgroundColor: Colors.white,
                  selectedColor: _kPrimary,
                  side: BorderSide(color: sel ? _kPrimary : Colors.grey.shade300, width: 1.5),
                  labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ],

        if (currentItem!.material.category == MaterialCategory.resins &&
            currentItem!.material.layerOptions != null) ...[
          _OptionsLabel(label: 'LAYER MICRONS'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: currentItem!.material.layerOptions!.map((l) {
              final sel = currentItem!.selectedLayer == l;
              return ChoiceChip(
                label: Text(l, style: const TextStyle(fontSize: 12)),
                selected: sel,
                onSelected: (s) => s ? updateLayer(l) : null,
                backgroundColor: Colors.white,
                selectedColor: _kPrimary,
                side: BorderSide(color: sel ? _kPrimary : Colors.grey.shade300, width: 1.5),
                labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        const Divider(height: 1),
        const SizedBox(height: 12),

        // Quantity selector
        _buildQuantitySelector(),
        const SizedBox(height: 12),

        // Cost breakdown (with grand total)
        _buildCostBreakdown(),
        const SizedBox(height: 12),

        // Discount section
        _buildDiscountSection(),
        const SizedBox(height: 12),

        // Payment info
        _buildPaymentBox(),
        const SizedBox(height: 12),

        // Action buttons (Draft & Submit)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: saveDraft,
                icon: const Icon(Iconsax.save_2, size: 15),
                label: const Text('Draft'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kPrimary,
                  side: const BorderSide(color: _kPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canSubmit ? submitRequest : null,
                icon: const Icon(Iconsax.send_2, size: 15),
                label: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSubmit ? _kPrimary : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Printer notice if not available
        if (selectedPrinter != null && selectedPrinter!.status != PrinterStatus.available) ...[
          const SizedBox(height: 12),
          _buildPrinterNotice(),
        ],
      ],
    );
  }

  Widget _buildMaterialBadge() {
    final cc = _QuoteStateMixin.categoryColor(currentItem!.material.category);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cc.withOpacity(0.06),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: cc.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cc.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _QuoteStateMixin.categoryIcon(currentItem!.material.category),
              size: 16,
              color: cc,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentItem!.material.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D23),
                  ),
                ),
                Text(
                  _QuoteStateMixin.categoryName(currentItem!.material.category),
                  style: TextStyle(fontSize: 11, color: cc, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            '₱${currentItem!.material.hourlyRate.toStringAsFixed(0)}/hr',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Iconsax.copy, size: 13, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            const Text(
              'Quantity',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1D23)),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QtyButton(icon: Iconsax.minus, onTap: decreaseQty),
              Container(
                width: 38,
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1D23)),
                ),
              ),
              _QtyButton(icon: Iconsax.add, onTap: increaseQty),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    if (currentItem == null) return const SizedBox.shrink();
    final matCost = currentItem!.materialCost;
    final machCost = currentItem!.hours * (selectedPrinter?.hourlyRate ?? currentItem!.material.hourlyRate);
    final elecCost = currentItem!.hours * 5.0;
    final svcFee = matCost * 0.15;
    final sub1 = matCost + machCost + elecCost + svcFee;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _CostRow(label: 'Material', value: '₱${matCost.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _CostRow(label: 'Machine Time', value: '₱${machCost.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _CostRow(label: 'Electricity', value: '₱${elecCost.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _CostRow(label: 'Service Fee (15%)', value: '₱${svcFee.toStringAsFixed(2)}'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _CostRow(label: 'Subtotal (1 unit)', value: '₱${sub1.toStringAsFixed(2)}', bold: true),
          if (quantity > 1) ...[
            const SizedBox(height: 6),
            _CostRow(label: 'Subtotal ($quantity units)', value: '₱${(sub1 * quantity).toStringAsFixed(2)}'),
          ],
          if (selectedDiscountType != null) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
            _CostRow(
              label: 'Discount ($selectedDiscountType 10%)',
              value: '-₱${discountAmount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF43A047),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GRAND TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '₱${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.discount_shape, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 7),
            const Text(
              'DISCOUNTS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1D23)),
            ),
            const Expanded(child: SizedBox()),
            Text('10% off', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kDiscountTypes.map((type) {
            final isSel = selectedDiscountType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSel,
              onSelected: (s) => setState(() => selectedDiscountType = s ? type : null),
              backgroundColor: Colors.grey.shade100,
              selectedColor: _kPrimary,
              labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontSize: 12),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
        if (selectedDiscountType != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Iconsax.card, size: 18, color: _kPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selectedDiscountType!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        uploadedIdName ?? 'ID required — tap to upload',
                        style: TextStyle(
                          fontSize: 11,
                          color: uploadedIdName != null ? const Color(0xFF43A047) : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Iconsax.document_upload, color: _kPrimary, size: 18),
                  onPressed: pickIdFile,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentBox() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _kPrimaryLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _kPrimary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.wallet, color: _kPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay at Admin Office',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A1D23)),
                ),
                SizedBox(height: 3),
                Text(
                  'Payment at admin office during scheduled appointment.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinterNotice() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.clock, color: Color(0xFFFFB300), size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Printer ${selectedPrinter!.status == PrinterStatus.busy ? 'is busy' : 'under maintenance'}. Available: ${selectedPrinter!.nextAvailable}',
              style: const TextStyle(
                color: Color(0xFF795500),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mobile Printer Card (full-width) ───────────────────────────────────────
class _MobilePrinterCard extends StatelessWidget {
  final PrinterModel printer;
  final bool isSelected;
  final VoidCallback onTap;
  const _MobilePrinterCard({required this.printer, required this.isSelected, required this.onTap});

  Color get _sc => switch (printer.status) {
    PrinterStatus.available         => const Color(0xFF43A047),
    PrinterStatus.busy              => const Color(0xFFFFB300),
    PrinterStatus.underMaintenance  => const Color(0xFFE53935),
  };
  String get _sl => switch (printer.status) {
    PrinterStatus.available         => 'Available',
    PrinterStatus.busy              => 'Busy',
    PrinterStatus.underMaintenance  => 'Maintenance',
  };

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? _kPrimaryLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _kPrimary : Colors.grey.shade200,
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? _kPrimary.withOpacity(0.1) : Colors.black.withOpacity(0.03),
            blurRadius: isSelected ? 14 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isSelected ? _kPrimary.withOpacity(0.15) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Iconsax.cpu, size: 18, color: isSelected ? _kPrimary : Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  printer.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? _kPrimaryDark : const Color(0xFF1A1D23),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${printer.buildVolume.width.toInt()}×${printer.buildVolume.depth.toInt()}×${printer.buildVolume.height.toInt()} mm',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Iconsax.flash_1, size: 11, color: isSelected ? _kPrimary : Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Text(
                      '${printer.speedFactor}x · ₱${printer.hourlyRate.toStringAsFixed(0)}/hr',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? _kPrimary : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: _sc, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(_sl, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _sc)),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: _kPrimary),
                    SizedBox(width: 4),
                    Text('Selected', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kPrimary)),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}