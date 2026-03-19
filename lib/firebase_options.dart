

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyArsQmEiGeEcJ1g5AT4_7rL6ywQXyijTnE',
    appId: '1:418582348458:web:b910aa82c75c470fedc6d3',
    messagingSenderId: '418582348458',
    projectId: 'innolab-c5ab1',
    authDomain: 'innolab-c5ab1.firebaseapp.com',
    storageBucket: 'innolab-c5ab1.firebasestorage.app',
    measurementId: 'G-0R4VPCG8P8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnwImQsH3HW4Gkr-XxOmEfDMaj12YtOMs',
    appId: '1:418582348458:android:179d9e8972a456e2edc6d3',
    messagingSenderId: '418582348458',
    projectId: 'innolab-c5ab1',
    storageBucket: 'innolab-c5ab1.firebasestorage.app',
  );

}


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example method to add data
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  // Example method to get data
  Stream<QuerySnapshot> getData(String collection) {
    return _firestore.collection(collection).snapshots();
  }
}