import 'package:get/get.dart';
import 'package:innolab/src/features/models/inventory_model.dart';
import 'package:innolab/src/repo/inventory_repository/inventory_repository.dart';

class InventoryController extends GetxController {
  static InventoryController get instance => Get.find();

  final repo = InventoryRepository();
  final items = <InventoryModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      final result = await repo.getAll();
      items.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addItem(InventoryModel item) async {
    try {
      isSaving.value = true;
      print(
        '[InventoryController.addItem] Received item: '
        'materialName=${item.materialName}, brand=${item.brand}, id=${item.id}',
      );

      final exists = await repo.materialNameExists(
        materialName: item.materialName,
      );
      print('[InventoryController.addItem] Duplicate exists: $exists');
      if (exists) return false;

      final id = await repo.addItem(item);

      final newItem = item.copyWith(id: id);
      items.add(newItem);

      print( '[InventoryController.addItem] Save complete. Total items: ${items.length}',);

      return true;
    } catch (e) {
      print('[InventoryController.addItem] ERROR: $e');
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }



  Future<void> updateItem(InventoryModel item) async {
    await repo.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await repo.deleteItem(id);
    items.removeWhere((e) => e.id == id);
  }
}
