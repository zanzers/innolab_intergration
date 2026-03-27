// ignore: file_names
import 'package:flutter/material.dart';
import 'package:innolab/src/common/loader/app_loader.dart';
import 'package:innolab/src/features/core/admin/inventory/inventortWidgets/materialPanel.dart';
import 'package:innolab/src/features/core/admin/inventory/screens/inventory_screen.dart';
import 'package:innolab/src/features/models/inventory_model.dart';



class AddMaterialPanel extends StatefulWidget {
  const AddMaterialPanel({super.key, required this.onClose, required this.onAdd});

  final VoidCallback onClose;
  final Future<bool> Function(InventoryModel) onAdd;

  @override
  State<AddMaterialPanel> createState() => AddMaterialPanelState();
}

class AddMaterialPanelState extends State<AddMaterialPanel> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '');
  final _costUnitCtrl = TextEditingController(text: '');
  final _costHourCtrl = TextEditingController(text: '');
  final _supplierCtrl = TextEditingController();
  MaterialCategory _category = MaterialCategory.filament;
  String _unit = 'rolls';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _qtyCtrl.dispose();
    _costUnitCtrl.dispose();
    _costHourCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Material name is required")),
      );
      return;
    }

    final newItem = InventoryModel(
      id: '',
      materialName: _nameCtrl.text.trim().toUpperCase(),
      brand: _brandCtrl.text.trim(),
      category: _category.name,
      unit: _unit,
      currentQuantity: double.tryParse(_qtyCtrl.text) ?? 0,
      costPerUnit: double.tryParse(_costUnitCtrl.text) ?? 0,
      costPerHour: double.tryParse(_costHourCtrl.text) ?? 0,
      supplier: _supplierCtrl.text.trim(),
    );

    print('_handle Add material ${newItem}');

    final result = await AAppLoading.showWhile<bool>(context, () async => 
      await widget.onAdd(newItem), message: 'Saving material...',
    );

    if (!mounted) return;

    if (!result) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Material already exists')));
      return;
    }

    
    await AAppLoading.showSuccess(context, 'Material saved');
    if(!mounted) return;

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Add Material',
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

          AEditField(label: 'Material Name *', controller: _nameCtrl),
          AEditField(label: 'Brand', controller: _brandCtrl),

          // Category picker
          const APanelLabel('Category'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: MaterialCategory.values.map((c) {
              final active = _category == c;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.indigo
                        : AppColors.indigo.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? AppColors.indigo
                          : AppColors.indigo.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    categoryLabel(c),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.indigo,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Unit picker
          const APanelLabel('Unit'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Rolls', 'pcs', 'bottles'].map((
              u,
            ) {
              final active = _unit == u;
              return GestureDetector(
                onTap: () => setState(() => _unit = u),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.violet
                        : AppColors.violet.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? AppColors.violet
                          : AppColors.violet.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    u,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.violet,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

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


          //[FUTURE] how about we add any error here and where it is...
   
  
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleAdd,
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
                    'Add Material',
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