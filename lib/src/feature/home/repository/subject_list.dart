import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/user_model.dart';
import 'subject.dart';

class SubjectList with ChangeNotifier {
  final UserModel? _currentUser;
  final List<Subject> _subjects;

  SubjectList([
    this._currentUser,
    this._subjects = const [],
  ]);

  List<Subject> get subjects => [..._subjects];

  List<Subject> subjectById(String subjecyId) {
    return _subjects.where((subject) => subject.id == subjecyId).toList();
  }

  Future<Map<String, List<String>>> loadSubjects() async {
    _subjects.clear();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final QuerySnapshot querySnapshot =
        await firestore.collection('subjects').get();

    Map<String, List<String>> classroomSubjects = {};

    for (final doc in querySnapshot.docs) {
      final subject = Subject(
        id: doc.id,
        name: doc['name'],
        imageUrl: doc['imageUrl'],
        classes: doc['classes'],
        teacher: doc['teacher'],
      );

      for (final classroom in subject.classes) {
        if (!classroomSubjects.containsKey(classroom)) {
          classroomSubjects[classroom] = [];
        }
        classroomSubjects[classroom]!.add(subject.name);
      }

      if (subject.classes.contains(_currentUser!.classroom) ||
          (_currentUser!.isProfessor &&
              subject.id == _currentUser!.classroom)) {
        _subjects.add(subject);
      }
    }

    notifyListeners();
    return classroomSubjects;
  }

  Future<void> updateSubject(Subject subject) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final subjectRef = firestore.collection('subjects').doc(subject.id);

    final subjectData = {
      'name': subject.name,
      'imageUrl': subject.imageUrl,
      'classes': subject.classes,
    };

    await subjectRef.update(subjectData);
    notifyListeners();
  }
}
