import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/user_model.dart';
import '../repository/activity.dart';
import '../repository/subject.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateSubject(Subject subject) async {
    try {
      final subjectRef = _firestore.collection('subjects').doc(subject.id);

      final subjectData = {
        'name': subject.name,
        'imageUrl': subject.imageUrl,
        'classes': subject.classes,
      };

      await subjectRef.update(subjectData);
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<List<Subject>> fetchSubjects(UserModel user) async {
    final QuerySnapshot querySnapshot =
        await _firestore.collection('subjects').get();

    final List<Subject> subjects = [];

    for (final doc in querySnapshot.docs) {
      final subject = Subject(
        id: doc.id,
        name: doc['name'],
        imageUrl: doc['imageUrl'],
        classes: doc['classes'],
        teacher: doc['teacher'],
      );

      if (subject.classes.contains(user.classroom) ||
          (user.isProfessor && subject.id == user.classroom)) {
        subjects.add(subject);
      }
    }

    return subjects;
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
    try {
      final activityRef = _firestore.collection('activities').doc();

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
    } catch (e) {
      return;
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      final subjectRef = _firestore.collection('activities').doc(activity.id);

      final subjectData = {
        'classes': activity.classes,
        'description': activity.description,
        'dueDate': activity.dueDate != null
            ? Timestamp.fromDate(activity.dueDate!)
            : null,
      };

      await subjectRef.update(subjectData);
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<List<Activity>> fetchActivities(
    String subjectId,
    UserModel user,
  ) async {
    final QuerySnapshot querySnapshot =
        await _firestore.collection('activities').get();

    final List<Activity> activities = [];

    for (final doc in querySnapshot.docs) {
      final professorId = doc['professorId'];
      final professorDoc =
          await _firestore.collection('users').doc(professorId).get();
      final professor = UserModel(
        id: professorDoc.id,
        name: professorDoc['name'],
        imageUrl: professorDoc['imageUrl'],
        classroom: professorDoc['classroom'],
        isProfessor: professorDoc['isProfessor'],
      );

      if (doc['subjectId'] == subjectId &&
          (doc['classes'].contains(user.classroom) || user.isProfessor)) {
        final activity = Activity(
          id: doc.id,
          user: professor,
          subjectId: subjectId,
          classes: doc['classes'],
          description: doc['description'],
          assignedDate: doc['assignedDate'],
          dueDate: doc['dueDate'],
        );

        activities.add(activity);
      }
    }

    return activities;
  }
}
