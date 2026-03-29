import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';

class UserRequestController {
  UserRequestController._();
  static final UserRequestController instance = UserRequestController._();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserQuoteRequests(
    String userId,
  ) {
    return FirebaseFirestore.instance
        .collection(DatabaseTable.quoteRequests)
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchUserQuoteRequests(String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to fetch your quote requests.');
    }
    if (user.uid != userId) {
      throw StateError('Session user does not match requested userId.');
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection(DatabaseTable.quoteRequests)
        .where('userId', isEqualTo: userId)
        .get();

    final sortedDocs = querySnapshot.docs
      ..sort((a, b) {
        final aTime = a.data()['createdAt'] as Timestamp?;
        final bTime = b.data()['createdAt'] as Timestamp?;
        return (bTime?.toDate() ?? DateTime(1970)).compareTo(
          aTime?.toDate() ?? DateTime(1970),
        );
      });

    return sortedDocs;
  }

  Future<void> deleteQuoteRequest(String requestId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to delete a quote request.');
    }

    await FirebaseFirestore.instance
        .collection(DatabaseTable.quoteRequests)
        .doc(requestId)
        .delete();

    if (kDebugMode) {
      print(
        'UserRequestController.deleteQuoteRequest: deleted request $requestId for user ${user.uid}',
      );
    }
  }
}
