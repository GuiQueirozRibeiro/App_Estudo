import 'dart:math';

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
    return _activities.where((activity) => activity.user.id == userId).toList();
  }

  Future<void> saveActivity(Map<String, Object?> data, UserModel professor) {
    bool hasId = data['id'] != null;
    DateTime? dueDateTime;

    if (data['dueDate'] != null) {
      DateTime dueDate = data['dueDate'] as DateTime;
      dueDateTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 7, 30);
    }

    final activity = Activity(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      classes: data['classes'] as List,
      description: data['description'] as String,
      assignedDate: Timestamp.fromDate(DateTime.now()),
      dueDate: dueDateTime != null ? Timestamp.fromDate(dueDateTime) : null,
      subjectId: professor.classroom,
      user: professor,
    );

    if (hasId) {
      return updateActivity(activity);
    } else {
      return createActivity(activity);
    }
  }

  Future<void> createActivity(Activity activity) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final activityRef = firestore.collection('activities').doc();

    final activityData = {
      'classes': activity.classes,
      'description': activity.description,
      'assignedDate': activity.assignedDate,
      'dueDate': activity.dueDate != null
          ? Timestamp.fromDate(activity.dueDate!)
          : null,
      'subjectId': activity.subjectId,
      'professorId': activity.user.id,
    };

    await activityRef.set(activityData);
    notifyListeners();
  }

  Future<void> updateActivity(Activity activity) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final subjectRef = firestore.collection('activities').doc(activity.id);

    final subjectData = {
      'classes': activity.classes,
      'description': activity.description,
      'dueDate': activity.dueDate != null
          ? Timestamp.fromDate(activity.dueDate!)
          : null,
    };

    await subjectRef.update(subjectData);
    notifyListeners();
  }

  Future<void> deleteActivity(String activityId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final activityRef = firestore.collection('activities').doc(activityId);
    await activityRef.delete();
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
      );

      _activities.add(activity);
    }
    notifyListeners();
  }
}
