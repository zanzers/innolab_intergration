import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:innolab/src/features/core/client/quote/quote_models.dart';
import 'package:innolab/src/features/core/client/quote/quote_service/quote_catalog_service.dart';
import 'package:innolab/src/repo/auth_repo/db_tableNames.dart';

class QuoteController {
  QuoteController._();
  static final QuoteController instance = QuoteController._();

  final List<PrinterModel> printers = [];
  final List<MaterialCategoryInfo> materialCategories = [];
  final List<MaterialOption> materials = [];
 
  bool isLoadingCatalog = false;
  String? catalogError;

  
  Future<void> loadCatalog() async {
    if (isLoadingCatalog) return;
    if (kDebugMode) print('QuoteController.loadCatalog: start');

    isLoadingCatalog = true;
    catalogError = null;
    try {
      final result = await QuoteService.loadCatalog();

      printers
        ..clear()
        ..addAll(result.printers);

      materials
        ..clear()
        ..addAll(result.materials);

      materialCategories
        ..clear()
        ..addAll(result.categories);
        
    } catch (e, st) {
      catalogError = e.toString();
      if (kDebugMode) {
        print('QuoteController.loadCatalog: $e\n$st');
      }
    } finally {
      isLoadingCatalog = false;
    }
  }

  Future<String> uploadSTL(PlatformFile file) async {
    final storage = FirebaseStorage.instance;

    final ref = storage.ref().child('stl_uploads/${file.name}');
    await ref.putData(file.bytes!);

    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  /// Persists a quote request to [DatabaseTable.quoteRequests] for the signed-in user.
  Future<void> submitQuoteRequest(QuoteRequestPayload payload) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to submit a quote.');
    }
    if (user.uid != payload.userId) {
      throw StateError('Session user does not match quote payload.');
    }

    await FirebaseFirestore.instance.collection(DatabaseTable.quoteRequests).add({
      ...payload.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) {
      print('QuoteController.submitQuoteRequest: saved for uid=${payload.userId}');
    }
  }
}
