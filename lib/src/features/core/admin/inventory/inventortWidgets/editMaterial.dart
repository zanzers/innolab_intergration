import 'package:flutter/material.dart';
import 'package:innolab/src/common/loader/app_loader.dart';
import 'package:innolab/src/features/core/admin/home/screens/home_tab_screen.dart';
import 'package:innolab/src/features/core/admin/inventory/inventortWidgets/materialPanel.dart';
import 'package:innolab/src/features/core/admin/inventory/screens/inventory_screen.dart'
    hide AppColors;

class EditMaterialPanel extends StatefulWidget {
  const EditMaterialPanel({
    super.key,
    required this.item,
    required this.onClose,
    required this.onSave,
    required this.onDelete,
  });

  final InventoryItem item;
  final VoidCallback onClose;
  final ValueChanged<InventoryItem> onSave;
  final Future<bool> Function(InventoryItem) onDelete;

  @override
  State<EditMaterialPanel> createState() => EditMaterialPanelState();
}

class EditMaterialPanelState extends State<EditMaterialPanel> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _maxCtrl;
  late final TextEditingController _costUnitCtrl;
  late final TextEditingController _costHourCtrl;
  late final TextEditingController _supplierCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _brandCtrl = TextEditingController(text: widget.item.brand);
    _qtyCtrl = TextEditingController(text: widget.item.currentStock.toString());
    _maxCtrl = TextEditingController(text: widget.item.maxStock.toString());
    _costUnitCtrl = TextEditingController(
      text: widget.item.costPerUnit.toString(),
    );
    _costHourCtrl = TextEditingController(
      text: widget.item.costPerHour.toString(),
    );
    _supplierCtrl = TextEditingController(text: widget.item.supplier);
  }

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

Future<void> _handleSave() async {
  final updated = widget.item.copyWith(
    name: _nameCtrl.text.trim(),
    brand: _brandCtrl.text.trim(),
    currentStock: double.tryParse(_qtyCtrl.text) ?? widget.item.currentStock,
    maxStock: double.tryParse(_maxCtrl.text) ?? widget.item.maxStock,
    costPerUnit: double.tryParse(_costUnitCtrl.text) ?? widget.item.costPerUnit,
    costPerHour: double.tryParse(_costHourCtrl.text) ?? widget.item.costPerHour,
    supplier: _supplierCtrl.text.trim(),
  );

  await AAppLoading.showWhile<void>(
    context,
    () async => widget.onSave(updated), 
    message: 'Saving...',
  );

  if (!mounted) return;

  await AAppLoading.showSuccess(context, 'Material saved');
  if (!mounted) return;

  widget.onClose();
}

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Material'),
        content: const Text(
          'Are you sure you want to delete this material?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AAppLoading.showWhile(
      context,
      () async => await widget.onDelete(widget.item),
      message: 'Deleting material...',
    );

    if (!mounted) return;

    await AAppLoading.showSuccess(context, 'Material deleted');

    if (!mounted) return;

    widget.onClose();
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
              Text(
                'Edit Material',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AEditField(label: 'Material Name', controller: _nameCtrl),
          AEditField(label: 'Brand', controller: _brandCtrl),
          AEditField(
            label: 'Current Quantity',
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
          ),

          Row(
            children: [
              Expanded(
                child: AEditField(
                  label: 'Cost Per Unit (₱)',
                  controller: _costUnitCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AEditField(
                  label: 'Cost Per Hour (₱)',
                  controller: _costHourCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          AEditField(label: 'Supplier', controller: _supplierCtrl),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Material',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
