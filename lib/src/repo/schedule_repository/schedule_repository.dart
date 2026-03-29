import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innolab/src/features/models/schedule_model.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';

class ScheduleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(DatabaseTable.schedule);

  Stream<List<ScheduleEvent>> getScheduleEvents() {
    return _ref.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ScheduleEvent.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      return list;
    });
  }

  Future<String> addEvent(ScheduleEvent event) async {
    final docRef = await _ref.add(event.toMap());
    return docRef.id;
  }

  Future<void> updateEvent(ScheduleEvent event) async {
    await _ref.doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _ref.doc(id).delete();
  }
}
