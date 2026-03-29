import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:innolab/src/common/loader/app_loader.dart';
import 'package:innolab/src/features/core/client/quote/quote_models.dart';
import 'package:innolab/src/features/core/client/quote/qoute_controller/qoute_controller.dart';
import 'package:innolab/src/features/core/controller/profileController/profile_controller.dart';

part 'user_quote_screen_web.dart';
part 'user_quote_screen_mobile.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _kPrimary = Color(0xFF5C6BC0);
const _kPrimaryDark = Color(0xFF3949AB);
const _kPrimaryLight = Color(0xFFEDEEFA);
const _kBackground = Color(0xFFF8F9FA);
const _kShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 12,
  offset: Offset(0, 4),
);
const _kShadowMd = BoxShadow(
  color: Color(0x12000000),
  blurRadius: 20,
  offset: Offset(0, 6),
);

const _kDiscountTypes = ['Student', 'Senior Citizen', 'PWD', 'Military'];

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class UserQuoteScreen extends StatelessWidget {
  const UserQuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        if (c.maxWidth >= 768) return const _WebQuoteView();
        return const _MobileQuoteView();
      },
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED STATE MIXIN
// ─────────────────────────────────────────────
mixin _QuoteStateMixin<T extends StatefulWidget> on State<T> {
  /// Firestore-backed catalog (see [QuoteController.loadCatalog]).
  List<PrinterModel> get printers => QuoteController.instance.printers;
  List<MaterialCategoryInfo> get materialCategories =>
      QuoteController.instance.materialCategories;
  List<MaterialOption> get materials => QuoteController.instance.materials;

  Future<void> loadQuoteCatalog() async {
    await QuoteController.instance.loadCatalog();
    if (mounted) setState(() {});
  }

  PrinterModel? selectedPrinter;

  /// `null` = all categories; otherwise matches [MaterialOption.categoryLabel] (normalized key).
  String? selectedCategoryKey;

  // Material / quote
  QuoteItem? currentItem;
  int quantity = 1;

  // File analysis
  String? selectedFileName;
  double? estimatedVolume;
  double? estimatedPrintTime;
  String? modelSizeWarning;
  double? modelWidth, modelDepth, modelHeight;
  int? triangleCount;

  // Discount
  String? selectedDiscountType;
  String? uploadedIdName;

  List<MaterialOption> get filteredMaterials {
    if (selectedCategoryKey == null) return materials;
    return materials
        .where(
          (m) => m.categoryLabel.trim().toLowerCase() == selectedCategoryKey,
        )
        .toList();
  }

  // ── File picking ──────────────────────────
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['stl', 'obj', '3mf', 'zip'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedFileName = result.files.first.name;
          _analyzeSTL();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File error: $e')));
    }
  }

  Future<void> pickIdFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          uploadedIdName = result.files.first.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File error: $e')));
    }
  }

  void _analyzeSTL() {
    triangleCount = 10000 + (DateTime.now().millisecondsSinceEpoch % 40000);
    estimatedVolume =
        10 + (DateTime.now().millisecondsSinceEpoch % 190).toDouble();
    modelWidth = 50 + (DateTime.now().millisecondsSinceEpoch % 200);
    modelDepth = 40 + (DateTime.now().millisecondsSinceEpoch % 180);
    modelHeight = 30 + (DateTime.now().millisecondsSinceEpoch % 220);
    if (selectedPrinter != null) _checkModelSize();
    estimatedPrintTime = (estimatedVolume! / 8) + 1.5;
    if (currentItem != null) _updateFromAnalysis();
  }

  void _checkModelSize() {
    if (selectedPrinter == null || modelWidth == null) return;
    if (modelWidth! > selectedPrinter!.buildVolume.width ||
        modelDepth! > selectedPrinter!.buildVolume.depth ||
        modelHeight! > selectedPrinter!.buildVolume.height) {
      modelSizeWarning =
          'Model exceeds printer build volume\n'
          'Max: ${selectedPrinter!.buildVolume.width.toInt()} × ${selectedPrinter!.buildVolume.depth.toInt()} × ${selectedPrinter!.buildVolume.height.toInt()} mm\n'
          'Your model: ${modelWidth!.toInt()} × ${modelDepth!.toInt()} × ${modelHeight!.toInt()} mm';
    } else {
      modelSizeWarning = null;
    }
  }

  void _updateFromAnalysis() {
    if (currentItem == null || estimatedVolume == null) return;
    final grams = estimatedVolume! * currentItem!.material.density;
    final hours = estimatedPrintTime ?? 2.0;
    _applyItemUpdate(grams: grams, hours: hours);
  }

  // Here!!!!!!
  void selectMaterial(MaterialOption material) {
    if (!material.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This material is out of stock or unavailable.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }
    setState(() {
      currentItem = QuoteItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        material: material,
        grams: estimatedVolume != null
            ? estimatedVolume! * material.density
            : 100.0,
        hours: estimatedPrintTime ?? 1.0,
        quantity: quantity,
        selectedFinish: material.surfaceFinishes?.first,
        selectedTolerance: material.tolerances?.first,
        selectedLayer: material.layerOptions?.first,
      );
      _updateFromAnalysis();
    });
  }

  void _applyItemUpdate({
    double? grams,
    double? hours,
    int? qty,
    String? finish,
    String? tolerance,
    String? layer,
  }) {
    if (currentItem == null) return;
    setState(() {
      currentItem = QuoteItem(
        id: currentItem!.id,
        material: currentItem!.material,
        grams: grams ?? currentItem!.grams,
        hours: hours ?? currentItem!.hours,
        quantity: qty ?? currentItem!.quantity,
        selectedFinish: finish ?? currentItem!.selectedFinish,
        selectedTolerance: tolerance ?? currentItem!.selectedTolerance,
        selectedLayer: layer ?? currentItem!.selectedLayer,
      );
    });
  }

  void updateFinish(String f) => _applyItemUpdate(finish: f);
  void updateTolerance(String t) => _applyItemUpdate(tolerance: t);
  void updateLayer(String l) => _applyItemUpdate(layer: l);
  void increaseQty() {
    quantity++;
    _applyItemUpdate(qty: quantity);
  }

  void decreaseQty() {
    if (quantity > 1) {
      quantity--;
      _applyItemUpdate(qty: quantity);
    }
  }

  Future<void> submitRequest() async {
    if (currentItem == null || modelSizeWarning != null) return;

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit a quote.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    String? profileName;
    String? profileEmail;
    try {
      final profile = Get.find<ProfileController>();
      profileName = profile.user?.fullName;
      profileEmail = profile.user?.email;
    } catch (_) {}
    profileEmail ??= authUser.email;

    final item = currentItem!;
    final matCost = item.materialCost;
    final machCost =
        item.hours * (selectedPrinter?.hourlyRate ?? item.material.hourlyRate);
    final elecCost = item.hours * 5.0;
    final svcFee = matCost * 0.15;

    final payload = QuoteRequestPayload(
      userId: authUser.uid,
      userEmail: profileEmail,
      userFullName: profileName,
      modelFileName: selectedFileName,
      estimatedVolumeCm3: estimatedVolume,
      estimatedPrintTimeHours: estimatedPrintTime,
      modelWidthMm: modelWidth,
      modelDepthMm: modelDepth,
      modelHeightMm: modelHeight,
      triangleCount: triangleCount,
      modelSizeWarning: modelSizeWarning,
      printerId: selectedPrinter?.id,
      printerName: selectedPrinter?.name,
      printerHourlyRate: selectedPrinter?.hourlyRate,
      printerStatus: selectedPrinter?.status.name,
      materialId: item.material.id,
      materialName: item.material.name,
      categoryLabel: item.material.categoryLabel,
      materialCategoryKey: item.material.category.name,
      grams: item.grams,
      hours: item.hours,
      quantity: item.quantity,
      selectedFinish: item.selectedFinish,
      selectedTolerance: item.selectedTolerance,
      selectedLayer: item.selectedLayer,
      materialCost: matCost,
      machineCost: machCost,
      electricityCost: elecCost,
      serviceFee: svcFee,
      subtotalPerUnit: subtotalPerUnit,
      discountType: selectedDiscountType,
      discountAmount: discountAmount,
      grandTotal: grandTotal,
      discountIdUploadName: uploadedIdName,
    );

    try {
      await AAppLoading.showWhile(
        context,
        () => QuoteController.instance.submitQuoteRequest(payload),
        message: 'Submitting request...',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quote submitted. Our team will review it and contact you.',
          ),
          backgroundColor: Color(0xFF43A047),
        ),
      );
      // Clear form and close sidebar after successful submission
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not submit: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      // Reset file analysis
      selectedFileName = null;
      estimatedVolume = null;
      estimatedPrintTime = null;
      modelSizeWarning = null;
      modelWidth = null;
      modelDepth = null;
      modelHeight = null;
      triangleCount = null;

      // Reset selections
      currentItem = null;
      selectedPrinter = null;
      selectedCategoryKey = null;
      quantity = 1;

      // Reset discount
      selectedDiscountType = null;
      uploadedIdName = null;
    });
  }

  void saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved'), backgroundColor: _kPrimary),
    );
  }

  // ── Computed costs ────────────────────────
  double get subtotalPerUnit {
    if (currentItem == null) return 0;
    final matCost = currentItem!.materialCost;
    final machCost =
        currentItem!.hours *
        (selectedPrinter?.hourlyRate ?? currentItem!.material.hourlyRate);
    final elecCost = currentItem!.hours * 5.0;
    final svcFee = matCost * 0.15;
    return matCost + machCost + elecCost + svcFee;
  }

  double get discountAmount =>
      selectedDiscountType != null ? subtotalPerUnit * quantity * 0.10 : 0.0;
  double get grandTotal => subtotalPerUnit * quantity - discountAmount;

  // ── Meta helpers ─────
  static String categoryName(MaterialCategory c) => c.quoteTitle;

  static Color categoryColor(MaterialCategory c) => c.quoteColor;

  static IconData categoryIcon(MaterialCategory c) => c.quoteIcon;
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS (used by both web and mobile)
// ─────────────────────────────────────────────
class _StepPill extends StatelessWidget {
  final int step;
  final String label;
  final bool done, active;
  const _StepPill({
    required this.step,
    required this.label,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: done
              ? _kPrimary
              : active
              ? _kPrimaryLight
              : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: done || active ? _kPrimary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : Text(
                  '$step',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? _kPrimary : Colors.grey.shade400,
                  ),
                ),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: active || done ? FontWeight.w600 : FontWeight.normal,
          color: done
              ? _kPrimary
              : active
              ? const Color(0xFF1A1D23)
              : Colors.grey.shade400,
        ),
      ),
    ],
  );
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      boxShadow: [_kShadow],
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _kPrimaryLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: _kPrimary),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D23),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    ],
  );
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isSelected ? Colors.white : color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PrinterCard extends StatefulWidget {
  final PrinterModel printer;
  final bool isSelected;
  final VoidCallback onTap;
  const _PrinterCard({
    required this.printer,
    required this.isSelected,
    required this.onTap,
  });
  @override
  State<_PrinterCard> createState() => _PrinterCardState();
}

class _PrinterCardState extends State<_PrinterCard> {
  bool _hovered = false;

  Color get _statusColor => switch (widget.printer.status) {
    PrinterStatus.available => const Color(0xFF43A047),
    PrinterStatus.busy => const Color(0xFFFFB300),
    PrinterStatus.underMaintenance => const Color(0xFFE53935),
  };

  String get _statusLabel => switch (widget.printer.status) {
    PrinterStatus.available => 'Available',
    PrinterStatus.busy => 'Busy',
    PrinterStatus.underMaintenance => 'Maintenance',
  };

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isSelected ? _kPrimaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isSelected
                ? _kPrimary
                : _hovered
                ? _kPrimary.withOpacity(0.3)
                : Colors.grey.shade200,
            width: widget.isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? _kPrimary.withOpacity(0.12)
                  : Colors.black.withOpacity(0.03),
              blurRadius: widget.isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? _kPrimary.withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Iconsax.cpu,
                    size: 15,
                    color: widget.isSelected ? _kPrimary : Colors.grey.shade600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.printer.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: widget.isSelected
                    ? _kPrimaryDark
                    : const Color(0xFF1A1D23),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.printer.buildVolume.width.toInt()}×${widget.printer.buildVolume.depth.toInt()}×${widget.printer.buildVolume.height.toInt()} mm',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Iconsax.flash_1,
                  size: 11,
                  color: widget.isSelected ? _kPrimary : Colors.grey.shade400,
                ),
                const SizedBox(width: 3),
                Text(
                  '${widget.printer.speedFactor}x · ₱${widget.printer.hourlyRate.toStringAsFixed(0)}/hr',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: widget.isSelected ? _kPrimary : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            if (widget.isSelected) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 13, color: _kPrimary),
                  const SizedBox(width: 4),
                  const Text(
                    'Selected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _kPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _MaterialCard extends StatefulWidget {
  final MaterialOption material;
  final Color categoryColor;
  final IconData categoryIcon;
  final String categoryName;
  final bool isSelected;
  final VoidCallback onAdd;
  const _MaterialCard({
    required this.material,
    required this.categoryColor,
    required this.categoryIcon,
    required this.categoryName,
    required this.isSelected,
    required this.onAdd,
  });
  @override
  State<_MaterialCard> createState() => _MaterialCardState();
}

class _MaterialCardState extends State<_MaterialCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isSelected
              ? widget.categoryColor
              : _hovered
              ? widget.categoryColor.withOpacity(0.35)
              : Colors.grey.shade200,
          width: widget.isSelected ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? widget.categoryColor.withOpacity(0.12)
                : Colors.black.withOpacity(0.04),
            blurRadius: widget.isSelected ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 4, color: widget.categoryColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: widget.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          widget.categoryIcon,
                          size: 15,
                          color: widget.categoryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.material.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1D23),
                              ),
                            ),
                            Text(
                              widget.categoryName,
                              style: TextStyle(
                                fontSize: 10,
                                color: widget.categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.material.description,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Print',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Text(
                            '₱${widget.material.hourlyRate.toStringAsFixed(0)}/hr',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1D23),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Material',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Text(
                            '₱${(widget.material.ratePerGram * 1000).toStringAsFixed(0)}/kg',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1D23),
                            ),
                          ),
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      GestureDetector(
                        onTap: widget.onAdd,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? const Color(0xFF43A047)
                                : widget.categoryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isSelected ? Icons.check : Iconsax.add,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.isSelected ? 'Selected' : 'Add',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ModelInfoChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ModelInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _kPrimary.withOpacity(0.15)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _kPrimary),
        const SizedBox(width: 5),
        Text(
          '$label ',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D23),
          ),
        ),
      ],
    ),
  );
}

class _CostRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _CostRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: bold ? const Color(0xFF1A1D23) : Colors.grey.shade600,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color:
              valueColor ??
              (bold ? const Color(0xFF1A1D23) : Colors.grey.shade700),
        ),
      ),
    ],
  );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, size: 16, color: Colors.grey.shade700),
    ),
  );
}

class _OptionsLabel extends StatelessWidget {
  final String label;
  const _OptionsLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade500,
      letterSpacing: 0.8,
    ),
  );
}

class _RightDivider extends StatelessWidget {
  const _RightDivider();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 14),
    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
  );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        Icon(icon, size: 14, color: _kPrimary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D23),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _FmtChip extends StatelessWidget {
  final String ext;
  final Color color;
  const _FmtChip({required this.ext, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: color.withOpacity(0.2), width: 1.2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Iconsax.document_text, size: 11, color: color),
        const SizedBox(width: 4),
        Text(
          '.$ext',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}
