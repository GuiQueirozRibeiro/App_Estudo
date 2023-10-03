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
      Map<String, Object?> data, UserModel professor) async {
    DateTime? dueDateTime;

    if (data['dueDate'] != null) {
      DateTime dueDate = data['dueDate'] as DateTime;
      dueDateTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 7, 30);
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final activityRef = firestore.collection('activities').doc();

    final activityData = {
      'classes': data['classes'],
      'description': data['description'],
      'assignedDate': Timestamp.fromDate(DateTime.now()),
      'dueDate': dueDateTime,
      'editDate': null,
      'subjectId': professor.classroom,
      'professorId': professor.id,
      'isEdit': false,
    };

    await activityRef.set(activityData);
    await loadActivity();
    notifyListeners();
  }

  Future<void> updateActivity(Map<String, Object?> data) async {
    DateTime? dueDateTime;

    if (data['dueDate'] != null) {
      DateTime dueDate = data['dueDate'] as DateTime;
      dueDateTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 7, 30);
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final activityRef =
        firestore.collection('activities').doc(data['id'] as String);

    final activityData = {
      'classes': data['classes'],
      'description': data['description'],
      'editDate': Timestamp.fromDate(DateTime.now()),
      'dueDate': dueDateTime,
      'isEdit': true,
    };

    await activityRef.update(activityData);
    await loadActivity();
    notifyListeners();
  }

  Future<void> deleteActivity(String activityId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final activityRef = firestore.collection('activities').doc(activityId);
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
      final professorId = doc['professorId'];
      final professorDoc =
          await firestore.collection('users').doc(professorId).get();
      final professor = UserModel(
        id: professorDoc.id,
        name: professorDoc['name'],
        imageUrl: professorDoc['imageUrl'],
        classroom: professorDoc['classroom'],
        isProfessor: professorDoc['isProfessor'],
      );

      final activity = Activity(
        id: doc.id,
        user: professor,
        subjectId: doc['subjectId'],
        classes: doc['classes'],
        description: doc['description'],
        assignedDate: doc['assignedDate'],
        dueDate: doc['dueDate'],
        editDate: doc['editDate'],
        isEdit: doc['isEdit'],
      );

      _activities.add(activity);
    }
    notifyListeners();
  }
}
