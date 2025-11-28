import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class WorkoutsProvider extends ChangeNotifier {
  final FirestoreService _fs;
  final String trainerId;
  final String clientId;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];

  WorkoutsProvider(this._fs, this.trainerId, this.clientId) {
    _fs.watchWorkouts(trainerId, clientId).listen((snap) {
      docs = snap.docs;
      notifyListeners();
    });
  }
}
