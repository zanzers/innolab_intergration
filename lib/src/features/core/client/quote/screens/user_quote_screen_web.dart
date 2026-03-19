part of 'user_quote_screen.dart';

// ─────────────────────────────────────────────
//  WEB QUOTE VIEW
// ─────────────────────────────────────────────
class _WebQuoteView extends StatefulWidget {
  const _WebQuoteView();
  @override
  State<_WebQuoteView> createState() => _WebQuoteViewState();
}

class _WebQuoteViewState extends State<_WebQuoteView> with _QuoteStateMixin {

  @override
  Widget build(BuildContext context) {
    final step1Done = selectedFileName != null;
    final step2Done = currentItem != null;

    return Scaffold(
      backgroundColor: _kBackground,
      body: Column(children: [
        // ── Breadcrumb / Steps header ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Icon(Iconsax.home, size: 15, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text('Home', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 15, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            const Text('Get a Quote', style: TextStyle(fontSize: 13, color: _kPrimary, fontWeight: FontWeight.w600)),
            const Spacer(),
            _StepPill(step: 1, label: 'Upload File',      done: step1Done, active: !step1Done),
            const SizedBox(width: 6),
            Container(width: 20, height: 1.5, color: Colors.grey.shade300),
            const SizedBox(width: 6),
            _StepPill(step: 2, label: 'Select Material',  done: step2Done, active: step1Done && !step2Done),
            const SizedBox(width: 6),
            Container(width: 20, height: 1.5, color: Colors.grey.shade300),
            const SizedBox(width: 6),
            _StepPill(step: 3, label: 'Review Quote',     done: false,     active: step2Done),
          ]),
        ),

        // ── Main two-column body ──
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Left — scrollable form
            Expanded(
              flex: 13,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildFileUpload(),
                  const SizedBox(height: 20),
                  _buildPrinterSelection(),
                  const SizedBox(height: 20),
                  _buildCategorySelector(),
                  const SizedBox(height: 20),
                  _buildMaterialGrid(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
            // Right — summary panel
            SizedBox(
              width: 400,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                child: _buildSummaryPanel(),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── File Upload ──────────────────────────────
  Widget _buildFileUpload() {
    return _SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(icon: Iconsax.document_upload, title: 'Upload 3D Model',
          subtitle: 'Supported: .stl, .obj, .3mf, .zip'),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: pickFile,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: selectedFileName != null ? _kPrimaryLight.withOpacity(0.5) : Colors.grey.shade50,
            border: Border.all(
                color: selectedFileName != null ? _kPrimary.withOpacity(0.4) : Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Container(width: 56, height: 56,
                decoration: BoxDecoration(
                    color: selectedFileName != null ? _kPrimary.withOpacity(0.12) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(selectedFileName != null ? Iconsax.document_text : Iconsax.document_upload,
                    size: 26, color: selectedFileName != null ? _kPrimary : Colors.grey.shade400)),
            const SizedBox(height: 12),
            Text(selectedFileName ?? 'Drag & drop or click to upload',
                style: TextStyle(fontSize: 14,
                    fontWeight: selectedFileName != null ? FontWeight.w600 : FontWeight.normal,
                    color: selectedFileName != null ? _kPrimaryDark : Colors.grey.shade500)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Iconsax.folder_open, size: 16),
              label: Text(selectedFileName != null ? 'Change File' : 'Browse Files'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary, foregroundColor: Colors.white, elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ]),
        ),
      ),
      if (selectedFileName != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _kPrimaryLight.withOpacity(0.5), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kPrimary.withOpacity(0.15))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Iconsax.info_circle, size: 13, color: _kPrimary),
              const SizedBox(width: 6),
              const Text('MODEL INFORMATION', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary, letterSpacing: 0.8)),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 8, children: [
              _ModelInfoChip(icon: Iconsax.document_text, label: 'File', value: selectedFileName!),
              if (estimatedVolume != null)
                _ModelInfoChip(icon: Iconsax.box, label: 'Volume', value: '${estimatedVolume!.toStringAsFixed(1)} cm³'),
              if (triangleCount != null)
                _ModelInfoChip(icon: Iconsax.shapes, label: 'Triangles', value: '$triangleCount'),
              if (modelWidth != null)
                _ModelInfoChip(icon: Iconsax.maximize_3, label: 'Size',
                    value: '${modelWidth!.toInt()}×${modelDepth!.toInt()}×${modelHeight!.toInt()} mm'),
            ]),
          ]),
        ),
      ],
      if (modelSizeWarning != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFCDD2))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Iconsax.warning_2, color: Color(0xFFE53935), size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(modelSizeWarning!,
                style: const TextStyle(color: Color(0xFFE53935), fontSize: 12, fontWeight: FontWeight.w500, height: 1.5))),
          ]),
        ),
      ],
    ]));
  }

  // ── Printer Selection ────────────────────────
  Widget _buildPrinterSelection() {
    return _SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(icon: Iconsax.cpu, title: 'Printer Selection',
          subtitle: 'Choose the printer that best fits your project'),
      const SizedBox(height: 16),
      Wrap(spacing: 12, runSpacing: 12, children: printers.map((p) => SizedBox(
        width: 210,
        child: _PrinterCard(
          printer: p, isSelected: selectedPrinter?.id == p.id,
          onTap: () => setState(() {
            selectedPrinter = selectedPrinter?.id == p.id ? null : p;
            if (selectedFileName != null) _checkModelSize();
            if (currentItem != null) _updateFromAnalysis();
          }),
        ),
      )).toList()),
    ]));
  }

  // ── Category Selector ────────────────────────
  Widget _buildCategorySelector() {
    return _SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(icon: Iconsax.category, title: 'Material Category', subtitle: 'Filter materials by type'),
      const SizedBox(height: 14),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        _CategoryChip(label: 'All', icon: Iconsax.grid_1, color: Colors.grey.shade600,
            isSelected: selectedCategory == null,
            onTap: () => setState(() => selectedCategory = null)),
        const SizedBox(width: 8),
        ..._kMaterialCategories.map((info) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _CategoryChip(label: info.name, icon: info.icon, color: info.color,
              isSelected: selectedCategory == info.category,
              onTap: () => setState(() => selectedCategory = info.category)),
        )),
      ])),
    ]));
  }

  // ── Material Grid ────────────────────────────
  Widget _buildMaterialGrid() {
    final filtered = filteredMaterials;
    return _SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _SectionTitle(icon: Iconsax.layer, title: 'Material Selection',
            subtitle: selectedCategory == null
                ? 'Showing all ${filtered.length} materials'
                : '${filtered.length} materials in this category')),
        if (selectedCategory != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: _QuoteStateMixin.categoryColor(selectedCategory!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(_QuoteStateMixin.categoryName(selectedCategory!),
                style: TextStyle(color: _QuoteStateMixin.categoryColor(selectedCategory!),
                    fontWeight: FontWeight.w600, fontSize: 12)),
          ),
      ]),
      const SizedBox(height: 16),
      if (filtered.isEmpty)
        Center(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(children: [
            Icon(Iconsax.box, size: 44, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text('No materials in this category', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ]),
        ))
      else
        LayoutBuilder(builder: (_, constraints) {
          // 2 cards per row when wide enough, 1 per row otherwise
          final cardWidth = constraints.maxWidth > 720
              ? (constraints.maxWidth - 14) / 2
              : constraints.maxWidth;
          return Wrap(spacing: 14, runSpacing: 14, children: filtered.map((m) => SizedBox(
            width: cardWidth,
            child: _MaterialCard(
              material: m,
              categoryColor: _QuoteStateMixin.categoryColor(m.category),
              categoryIcon: _QuoteStateMixin.categoryIcon(m.category),
              categoryName: _QuoteStateMixin.categoryName(m.category),
              isSelected: currentItem?.material.id == m.id,
              onAdd: () => selectMaterial(m),
            ),
          )).toList());
        }),
    ]));
  }

  // ── Summary Panel ────────────────────────────
  Widget _buildSummaryPanel() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(18)), boxShadow: [_kShadowMd]),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Gradient header
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(gradient: LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
              begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Iconsax.calculator, size: 20, color: Colors.white)),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Estimation Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Real-time cost calculation', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: currentItem == null ? _buildEmptyState() : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMaterialBadge(),
              const SizedBox(height: 14),
              // Metal-specific options
              if (currentItem!.material.category == MaterialCategory.metals) ...[
                if (currentItem!.material.surfaceFinishes != null) ...[
                  _OptionsLabel(label: 'SURFACE FINISH'), const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6,
                      children: currentItem!.material.surfaceFinishes!.map((f) {
                    final sel = currentItem!.selectedFinish == f;
                    return ChoiceChip(label: Text(f), selected: sel,
                      onSelected: (s) { if (s) updateFinish(f); },
                      backgroundColor: Colors.white, selectedColor: _kPrimary,
                      side: BorderSide(color: sel ? _kPrimary : Colors.grey.shade300, width: 1.5),
                      labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                      visualDensity: VisualDensity.compact);
                  }).toList()),
                  const SizedBox(height: 12),
                ],
                if (currentItem!.material.tolerances != null) ...[
                  _OptionsLabel(label: 'TOLERANCE'), const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6,
                      children: currentItem!.material.tolerances!.map((t) {
                    final sel = currentItem!.selectedTolerance == t;
                    return ChoiceChip(label: Text(t), selected: sel,
                      onSelected: (s) { if (s) updateTolerance(t); },
                      backgroundColor: Colors.white, selectedColor: _kPrimary,
                      side: BorderSide(color: sel ? _kPrimary : Colors.grey.shade300, width: 1.5),
                      labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                      visualDensity: VisualDensity.compact);
                  }).toList()),
                  const SizedBox(height: 12),
                ],
              ],
              // Resin layer options
              if (currentItem!.material.category == MaterialCategory.resins &&
                  currentItem!.material.layerOptions != null) ...[
                _OptionsLabel(label: 'LAYER MICRONS'), const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 6,
                    children: currentItem!.material.layerOptions!.map((l) {
                  final sel = currentItem!.selectedLayer == l;
                  return ChoiceChip(label: Text(l), selected: sel,
                    onSelected: (s) { if (s) updateLayer(l); },
                    backgroundColor: Colors.white, selectedColor: _kPrimary,
                    side: BorderSide(color: sel ? _kPrimary : Colors.grey.shade300, width: 1.5),
                    labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12),
                    visualDensity: VisualDensity.compact);
                }).toList()),
                const SizedBox(height: 12),
              ],
              const _RightDivider(),
              _buildQuantitySelector(),
              const SizedBox(height: 14),
              _buildCostBreakdown(),
              const SizedBox(height: 20),
              _buildDiscountSection(),
              const SizedBox(height: 20),
              _buildPaymentBox(),
              const SizedBox(height: 20),
              _buildActionButtons(),
              if (selectedPrinter != null && selectedPrinter!.status != PrinterStatus.available)
                _buildPrinterNotice(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // How it works
      Row(children: [
        Icon(Iconsax.info_circle, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text('HOW IT WORKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
            color: Colors.grey.shade500, letterSpacing: 0.8)),
      ]),
      const SizedBox(height: 12),
      ...[
        (icon: Iconsax.document_upload, title: 'Upload Your File',   desc: 'Upload your 3D model (.stl, .obj, .3mf, .zip)',  color: Color(0xFF5C6BC0), num: '01'),
        (icon: Iconsax.layer,           title: 'Choose Material',    desc: 'Pick a material and configure your print.',        color: Color(0xFF1E88E5), num: '02'),
        (icon: Iconsax.send_2,          title: 'Submit & Print',     desc: 'Review your quote, apply discounts, and submit.',  color: Color(0xFF43A047), num: '03'),
      ].asMap().entries.map((e) {
        final s = e.value;
        final isLast = e.key == 2;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 32, height: 32,
                decoration: BoxDecoration(color: s.color.withOpacity(0.1), borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: s.color.withOpacity(0.25), width: 1.5)),
                child: Icon(s.icon, size: 15, color: s.color)),
            if (!isLast) Container(width: 1.5, height: 28, color: Colors.grey.shade200),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(s.num, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: s.color, letterSpacing: 1)),
                const SizedBox(width: 6),
                Text(s.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1D23))),
              ]),
              const SizedBox(height: 3),
              Text(s.desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.4)),
            ]),
          )),
        ]);
      }),
      const SizedBox(height: 20),
      // Facility info
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_kPrimary.withOpacity(0.06), _kPrimary.withOpacity(0.02)]),
            borderRadius: BorderRadius.circular(12), border: Border.all(color: _kPrimary.withOpacity(0.12))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Iconsax.buildings, size: 13, color: _kPrimary),
            const SizedBox(width: 6),
            const Text('FACILITY INFO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kPrimary, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatItem(icon: Iconsax.cpu, label: 'Printers', value: '4 Units')),
            Container(width: 1, height: 36, color: _kPrimary.withOpacity(0.15)),
            Expanded(child: _StatItem(icon: Iconsax.timer_1, label: 'Turnaround', value: '24–48 hrs')),
          ]),
          const SizedBox(height: 10),
          Container(height: 1, color: _kPrimary.withOpacity(0.1)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _StatItem(icon: Iconsax.layer, label: 'Materials', value: '8 Types')),
            Container(width: 1, height: 36, color: _kPrimary.withOpacity(0.15)),
            Expanded(child: _StatItem(icon: Iconsax.clock, label: 'Hours', value: '8AM – 5PM')),
          ]),
        ]),
      ),
    ]);
  }

  Widget _buildMaterialBadge() {
    final cc = _QuoteStateMixin.categoryColor(currentItem!.material.category);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cc.withOpacity(0.06), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cc.withOpacity(0.15))),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: cc.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(_QuoteStateMixin.categoryIcon(currentItem!.material.category), size: 18, color: cc)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(currentItem!.material.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1D23))),
          Text(_QuoteStateMixin.categoryName(currentItem!.material.category),
              style: TextStyle(fontSize: 11, color: cc, fontWeight: FontWeight.w600)),
        ])),
        Text('₱${currentItem!.material.hourlyRate.toStringAsFixed(0)}/hr',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kPrimary)),
      ]),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Icon(Iconsax.copy, size: 13, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        const Text('Quantity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1D23))),
      ]),
      Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _QtyButton(icon: Iconsax.minus, onTap: decreaseQty),
          Container(width: 40, alignment: Alignment.center,
              child: Text('$quantity', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1D23)))),
          _QtyButton(icon: Iconsax.add, onTap: increaseQty),
        ]),
      ),
    ]);
  }

  Widget _buildCostBreakdown() {
    if (currentItem == null) return const SizedBox();
    final matCost  = currentItem!.materialCost;
    final machCost = currentItem!.hours * (selectedPrinter?.hourlyRate ?? currentItem!.material.hourlyRate);
    final elecCost = currentItem!.hours * 5.0;
    final svcFee   = matCost * 0.15;
    final sub1     = matCost + machCost + elecCost + svcFee;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        _CostRow(label: 'Material',       value: '₱${matCost.toStringAsFixed(2)}'),
        const SizedBox(height: 6),
        _CostRow(label: 'Machine Time',   value: '₱${machCost.toStringAsFixed(2)}'),
        const SizedBox(height: 6),
        _CostRow(label: 'Electricity',    value: '₱${elecCost.toStringAsFixed(2)}'),
        const SizedBox(height: 6),
        _CostRow(label: 'Service Fee (15%)', value: '₱${svcFee.toStringAsFixed(2)}'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
        _CostRow(label: 'Subtotal (1 unit)', value: '₱${sub1.toStringAsFixed(2)}', bold: true),
        if (quantity > 1) ...[
          const SizedBox(height: 6),
          _CostRow(label: 'Subtotal ($quantity units)', value: '₱${(sub1 * quantity).toStringAsFixed(2)}'),
        ],
        if (selectedDiscountType != null) ...[
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _CostRow(label: 'Discount ($selectedDiscountType 10%)', value: '-₱${discountAmount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF43A047)),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)]),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                color: Colors.white, letterSpacing: 0.5)),
            Text('₱${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDiscountSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Iconsax.discount_shape, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text('DISCOUNTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
            color: Colors.grey.shade500, letterSpacing: 0.8)),
      ]),
      const SizedBox(height: 10),
      Text('Select your discount category (10% off)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 6, children: _kDiscountTypes.map((type) {
        final isSel = selectedDiscountType == type;
        return ChoiceChip(label: Text(type), selected: isSel,
          onSelected: (s) => setState(() => selectedDiscountType = s ? type : null),
          backgroundColor: Colors.grey.shade100, selectedColor: _kPrimary,
          labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontSize: 12),
          visualDensity: VisualDensity.compact);
      }).toList()),
      if (selectedDiscountType != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200)),
          child: Row(children: [
            Icon(Iconsax.card, size: 18, color: _kPrimary),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(selectedDiscountType!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(uploadedIdName ?? 'ID required — tap to upload',
                  style: TextStyle(fontSize: 11,
                      color: uploadedIdName != null ? const Color(0xFF43A047) : Colors.grey.shade500)),
            ])),
            IconButton(icon: Icon(Iconsax.document_upload, color: _kPrimary, size: 18),
                onPressed: pickIdFile, tooltip: 'Upload ID',
                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
        ),
      ],
    ]);
  }

  Widget _buildPaymentBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _kPrimaryLight.withOpacity(0.4), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kPrimary.withOpacity(0.15))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _kPrimary.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
            child: const Icon(Iconsax.wallet, color: _kPrimary, size: 18)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pay at Admin Office', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A1D23))),
          SizedBox(height: 3),
          Text('Payment at admin office during scheduled appointment.',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _buildActionButtons() {
    final canRequest = currentItem != null && modelSizeWarning == null;
    return Row(children: [
      Expanded(child: OutlinedButton.icon(
        onPressed: currentItem != null ? saveDraft : null,
        icon: const Icon(Iconsax.save_2, size: 15),
        label: const Text('Draft'),
        style: OutlinedButton.styleFrom(foregroundColor: _kPrimary, side: const BorderSide(color: _kPrimary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      )),
      const SizedBox(width: 10),
      Expanded(flex: 2, child: ElevatedButton.icon(
        onPressed: canRequest ? submitRequest : null,
        icon: const Icon(Iconsax.send_2, size: 15),
        label: const Text('Submit Request'),
        style: ElevatedButton.styleFrom(
            backgroundColor: canRequest ? _kPrimary : Colors.grey.shade300,
            foregroundColor: Colors.white, elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      )),
    ]);
  }

  Widget _buildPrinterNotice() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFE082))),
        child: Row(children: [
          const Icon(Iconsax.clock, color: Color(0xFFFFB300), size: 15),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Printer ${selectedPrinter!.status == PrinterStatus.busy ? 'is busy' : 'under maintenance'}. '
                'Available: ${selectedPrinter!.nextAvailable}',
            style: const TextStyle(color: Color(0xFF795500), fontSize: 11, fontWeight: FontWeight.w500, height: 1.4))),
        ]),
      ),
    );
  }
}