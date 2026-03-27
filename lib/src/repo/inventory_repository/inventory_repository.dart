import 'package:innolab/src/features/models/inventory_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';

class InventoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _materialsRef =>
      _db.collection(DatabaseTable.materials);

  Future<List<InventoryModel>> getAll() async {
    final snapshot = await _materialsRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return InventoryModel.fromMap(data);
    }).toList();
  }

  Future<bool> materialNameExists({
    required String materialName,
  }) async {
    final nameKey = materialName.trim().toLowerCase();

    final snapshot = await _materialsRef
        .where('materialNameLower', isEqualTo: nameKey)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<String> addItem(InventoryModel item) async {
    final docRef = await _materialsRef.add(item.toMap());
    return docRef.id;
  }

  Future<void> updateItem(InventoryModel updatedItem) async {
    await _materialsRef.doc(updatedItem.id).update(updatedItem.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _materialsRef.doc(id).delete();
  }
}
