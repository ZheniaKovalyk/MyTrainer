import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class WorkoutsProvider extends ChangeNotifier {
  final FirestoreService _fs;
  final String trainerId;
  final String clientId;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];
  String query = '';
  // sortMode:
  // 0 = date desc (default)
  // 1 = date asc
  // 2 = description A->Z
  // 3 = description Z->A
  // 4 = duration desc (longest first)
  // 5 = duration asc (shortest first)
  int sortMode = 0;

  WorkoutsProvider(this._fs, this.trainerId, this.clientId) {
    _fs.watchWorkouts(trainerId, clientId).listen((snap) {
      docs = snap.docs;
      notifyListeners();
    });
  }

  void setQuery(String q) {
    query = q.toLowerCase().trim();
    notifyListeners();
  }

  void setSortMode(int mode) {
    sortMode = mode;
    notifyListeners();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get filtered {
    var list = docs;
    if (query.isNotEmpty) {
      list = list.where((d) {
        final data = d.data();
        final desc = (data['description'] as String?)?.toLowerCase() ?? '';
        final type = (data['type'] as String?)?.toLowerCase() ?? '';
        return desc.contains(query) || type.contains(query);
      }).toList();
    }

    final sorted = List.of(list);
    sorted.sort((a, b) {
      final ad = a.data();
      final bd = b.data();
      switch (sortMode) {
        case 1:
          // date asc
          return (ad['date'] as String?)?.compareTo(bd['date'] as String? ?? '') ?? 0;
        case 2:
          final adesc = (ad['description'] as String?) ?? '';
          final bdesc = (bd['description'] as String?) ?? '';
          return adesc.toLowerCase().compareTo(bdesc.toLowerCase());
        case 3:
          final adesc = (ad['description'] as String?) ?? '';
          final bdesc = (bd['description'] as String?) ?? '';
          return -adesc.toLowerCase().compareTo(bdesc.toLowerCase());
        case 4:
          // duration desc
          final aDur = (ad['duration'] is int) ? (ad['duration'] as int) : int.tryParse('${ad['duration'] ?? 0}') ?? 0;
          final bDur = (bd['duration'] is int) ? (bd['duration'] as int) : int.tryParse('${bd['duration'] ?? 0}') ?? 0;
          return bDur.compareTo(aDur);
        case 5:
          // duration asc
          final aDur2 = (ad['duration'] is int) ? (ad['duration'] as int) : int.tryParse('${ad['duration'] ?? 0}') ?? 0;
          final bDur2 = (bd['duration'] is int) ? (bd['duration'] as int) : int.tryParse('${bd['duration'] ?? 0}') ?? 0;
          return aDur2.compareTo(bDur2);
        case 0:
        default:
          // date desc
          return (bd['date'] as String?)?.compareTo(ad['date'] as String? ?? '') ?? 0;
      }
    });
    return sorted;
  }
}
