import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';
import 'package:innolab/src/features/models/material_model.dart';

class MaterialRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MaterialOption>> getMaterials() {
    return _db.collection(DatabaseTable.materials).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MaterialOption.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ADD
  Future<void> addMaterial(MaterialOption material) async {
    try {
      await _db.collection(DatabaseTable.materials).add(material.toMap());
    } catch (e) {
      print('Error adding materila: $e');
      rethrow;
    }
  }

  // UPDATE
  Future<void> updateMaterial(MaterialOption material) async {
    await _db
        .collection(DatabaseTable.materials)
        .doc(material.id)
        .update(material.toMap());
  }

  // DELETE
  Future<void> deleteMaterial(String id) async {
    await _db.collection(DatabaseTable.materials).doc(id).delete();
  }
}
