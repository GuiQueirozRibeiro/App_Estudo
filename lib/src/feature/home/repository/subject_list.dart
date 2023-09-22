import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/user_model.dart';
import 'subject.dart';

class SubjectList with ChangeNotifier {
  final UserModel? _currentUser;
  final List<Subject> _items;

  SubjectList([
    this._currentUser,
    this._items = const [],
  ]);

  int get itemsCount {
    return _items.length;
  }

  List<Subject> get items => [..._items];

  Future<void> loadSubjects() async {
    _items.clear();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final QuerySnapshot querySnapshot =
        await firestore.collection('subjects').get();

    for (final doc in querySnapshot.docs) {
      final subject = Subject(
        id: doc.id,
        name: doc['name'],
        imageUrl: doc['imageUrl'],
        classes: doc['classes'],
        teacher: doc['teacher'],
      );

      if (subject.classes.contains(_currentUser!.classroom) ||
          (_currentUser!.isProfessor &&
              subject.id == _currentUser!.classroom)) {
        _items.add(subject);
      }
    }
    notifyListeners();
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
