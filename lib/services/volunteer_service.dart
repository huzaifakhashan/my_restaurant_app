import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/volunteer_task.dart';

class VolunteerService {
  static final CollectionReference<Map<String, dynamic>> _tasksRef =
      FirebaseFirestore.instance.collection('volunteerTasks');

  static Stream<List<VolunteerTask>> streamAvailableTasks() {
    return _tasksRef
        .where('status', isEqualTo: VolunteerTaskStatus.available.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VolunteerTask.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Stream<List<VolunteerTask>> streamMyTasks(String volunteerId) {
    return _tasksRef
        .where('volunteerId', isEqualTo: volunteerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VolunteerTask.fromMap(doc.id, doc.data()))
              .where((task) => task.status != VolunteerTaskStatus.cancelled)
              .toList(),
        );
  }

  static Future<void> acceptTask(VolunteerTask task, String volunteerId) {
    return _tasksRef.doc(task.id).update({
      'volunteerId': volunteerId,
      'status': VolunteerTaskStatus.accepted.name,
    });
  }

  static Future<void> markPickedUp(VolunteerTask task) {
    return _tasksRef.doc(task.id).update({
      'status': VolunteerTaskStatus.pickedUp.name,
    });
  }

  static Future<void> markDelivered(VolunteerTask task) {
    return _tasksRef.doc(task.id).update({
      'status': VolunteerTaskStatus.delivered.name,
    });
  }

  static Future<void> completeTask(VolunteerTask task) {
    return _tasksRef.doc(task.id).update({
      'status': VolunteerTaskStatus.completed.name,
    });
  }
}
