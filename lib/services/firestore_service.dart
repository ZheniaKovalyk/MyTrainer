import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  // Paths
  DocumentReference<Map<String, dynamic>> trainerDoc(String trainerId) =>
      _db.collection('user').doc(trainerId);
  CollectionReference<Map<String, dynamic>> clientsCol(String trainerId) =>
      trainerDoc(trainerId).collection('clients');
  DocumentReference<Map<String, dynamic>> clientDoc(
          String trainerId, String clientId) =>
      clientsCol(trainerId).doc(clientId);
  CollectionReference<Map<String, dynamic>> trainingsCol(
          String trainerId, String clientId) =>
      clientDoc(trainerId, clientId).collection('trainings');

  // Trainer
  Future<void> setTrainer(String trainerId, Map<String, dynamic> data) async {
    await trainerDoc(trainerId).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTrainer(
          String trainerId) async =>
      trainerDoc(trainerId).get();

  // Clients
  Future<String> addClient(String trainerId, Map<String, dynamic> data) async {
    try {
      debugPrint('FirestoreService.addClient -> trainer: $trainerId, data: $data');
      final doc = await clientsCol(trainerId).add(data);
      debugPrint('FirestoreService.addClient -> created client id: ${doc.id}');
      return doc.id;
    } catch (e, st) {
      debugPrint('FirestoreService.addClient ERROR: $e\n$st');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchClients(String trainerId) =>
      clientsCol(trainerId).orderBy('lastName').snapshots();
  Future<void> updateClient(
      String trainerId, String clientId, Map<String, dynamic> data) async {
    try {
      debugPrint('FirestoreService.updateClient -> trainer: $trainerId, client: $clientId, data: $data');
      await clientDoc(trainerId, clientId).set(data, SetOptions(merge: true));
      debugPrint('FirestoreService.updateClient -> success for client: $clientId');
    } catch (e, st) {
      debugPrint('FirestoreService.updateClient ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> deleteClient(String trainerId, String clientId) async {
    try {
      debugPrint('FirestoreService.deleteClient -> trainer: $trainerId, client: $clientId');
      await clientDoc(trainerId, clientId).delete();
      debugPrint('FirestoreService.deleteClient -> deleted client: $clientId');
    } catch (e, st) {
      debugPrint('FirestoreService.deleteClient ERROR: $e\n$st');
      rethrow;
    }
  }

  // Workouts
  Future<String> addWorkout(
      String trainerId, String clientId, Map<String, dynamic> data) async {
    final doc = await trainingsCol(trainerId, clientId).add(data);
    return doc.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchWorkouts(
          String trainerId, String clientId) =>
      trainingsCol(trainerId, clientId)
          .orderBy('date', descending: true)
          .snapshots();
  Future<void> updateWorkout(String trainerId, String clientId,
      String workoutId, Map<String, dynamic> data) async {
    await trainingsCol(trainerId, clientId)
        .doc(workoutId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteWorkout(
      String trainerId, String clientId, String workoutId) async {
    await trainingsCol(trainerId, clientId).doc(workoutId).delete();
  }
}
