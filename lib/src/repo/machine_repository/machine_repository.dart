import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innolab/src/features/models/machine_model.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';

class MachineRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // final String _collection = 'machines';

  Stream<List<MachineModel>> getMachines() {
    return _db.collection(DatabaseTable.machine).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MachineModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addMachine(MachineModel machine) async {
    await _db.collection(DatabaseTable.machine).add(machine.toMap());
  }

  Future<void> updateMachine(MachineModel machine) async {
    await _db
        .collection(DatabaseTable.machine)
        .doc(machine.id)
        .update(machine.toMap());
  }

  Future<void> deleteMachine(String id) async {
    await _db.collection(DatabaseTable.machine).doc(id).delete();
  }

}