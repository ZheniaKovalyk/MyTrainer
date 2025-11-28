import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class ClientsProvider extends ChangeNotifier {
  final FirestoreService _fs;
  final String trainerId;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];
  String query = '';

  ClientsProvider(this._fs, this.trainerId) {
    debugPrint('ClientsProvider: subscribing to clients for trainer: $trainerId');
    _fs.watchClients(trainerId).listen((snap) {
      docs = snap.docs;
      debugPrint('ClientsProvider: snapshot received (${docs.length} docs)');
      notifyListeners();
    }, onError: (e, st) {
      debugPrint('ClientsProvider: watchClients ERROR: $e\n$st');
    });
  }

  void setQuery(String q) {
    query = q.toLowerCase().trim();
    debugPrint('ClientsProvider.setQuery -> "$query"');
    notifyListeners();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get filtered {
    if (query.isEmpty) return docs;
    return docs.where((d) {
      final data = d.data();
      final lastName = data['lastName'] as String? ?? '';
      final firstName = data['firstName'] as String? ?? '';
      return '$lastName $firstName'.toLowerCase().contains(query);
    }).toList();
  }
}
