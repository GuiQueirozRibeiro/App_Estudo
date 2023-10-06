import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/user_model.dart';
import 'activity.dart';

class ActivityList with ChangeNotifier {
  final List<Activity> _activities;

  ActivityList([
    this._activities = const [],
  ]);

  List<Activity> get activities => [..._activities];

  List<Activity> getSubjectList(String subjectId) {
    return _activities
        .where((activity) => activity.subjectId == subjectId)
        .toList();
  }

  List<Activity> getUserList(String userId) {
    return _activities
        .where((activity) =>
            activity.user.id == userId && activity.dueDate != null)
        .toList();
  }

  Future<void> createActivity(
      Map<String, Object?> data, UserModel professor, String subjectId) async {
    DateTime? dueDateTime;

    if (data['dueDate'] != null) {
      DateTime dueDate = data['dueDate'] as DateTime;
      dueDateTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 7, 30);
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final activityRef = firestore
        .collection('activities')
        .doc(subjectId)
        .collection('subjectActivities')
        .doc();

    final activityData = {
      'classes': data['classes'],
      'description': data['description'],
      'assignedDate': Timestamp.fromDate(DateTime.now()),
      'dueDate': dueDateTime,
      'editDate': null,
      'professorId': professor.id,
    };

    await activityRef.set(activityData);
    await loadActivity();
    notifyListeners();
  }

  Future<void> updateActivity(
      Map<String, Object?> data, String subjectId) async {
    DateTime? dueDateTime;

    if (data['dueDate'] != null) {
      DateTime dueDate = data['dueDate'] as DateTime;
      dueDateTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 7, 30);
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final activityRef = firestore
        .collection('activities')
        .doc(subjectId)
        .collection('subjectActivities')
        .doc(data['id'] as String);

    final activityData = {
      'classes': data['classes'],
      'description': data['description'],
      'editDate': Timestamp.fromDate(DateTime.now()),
      'dueDate': dueDateTime,
    };

    await activityRef.update(activityData);
    await loadActivity();
    notifyListeners();
  }

  Future<void> deleteActivity(String subjectId, String activityId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final activityRef = firestore
        .collection('activities')
        .doc(subjectId)
        .collection('subjectActivities')
        .doc(activityId);
    await activityRef.delete();
    await loadActivity();
    notifyListeners();
  }

  Future<void> loadActivity() async {
    _activities.clear();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('activities').get();

    for (final doc in querySnapshot.docs) {
      QuerySnapshot subCollectionSnapshot =
          await doc.reference.collection('subjectActivities').get();

      for (final subDoc in subCollectionSnapshot.docs) {
        final activity =
            await buildActivityFromDocument(subDoc, firestore, doc.id);
        _activities.add(activity);
      }
    }
    notifyListeners();
  }

  Future<Activity> buildActivityFromDocument(QueryDocumentSnapshot subDoc,
      FirebaseFirestore firestore, String subjectId) async {
    final professorId = subDoc['professorId'];
    final professorDoc =
        await firestore.collection('users').doc(professorId).get();
    final professor = UserModel(
      id: professorDoc.id,
      name: professorDoc['name'],
      imageUrl: professorDoc['imageUrl'],
      classroom: professorDoc['classroom'],
      isProfessor: professorDoc['isProfessor'],
    );

    return Activity(
      id: subDoc.id,
      user: professor,
      subjectId: subjectId,
      classes: subDoc['classes'],
      description: subDoc['description'],
      assignedDate: subDoc['assignedDate'],
      dueDate: subDoc['dueDate'],
      editDate: subDoc['editDate'],
    );
  }
}
