import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/user_model.dart';

class UserList with ChangeNotifier {
  bool _showUserList;
  final UserModel? _currentUser;
  final List<UserModel> _users;

  UserList([
    this._currentUser,
    this._showUserList = false,
    this._users = const [],
  ]);

  bool get showUserList => _showUserList;

  int get usersCount {
    return _users.length;
  }

  List<UserModel> get users => [..._users];

  void toggleUserList() {
    _showUserList = !_showUserList;
    notifyListeners();
  }

  Future<void> loadUsers(Map<String, List<String>> classroomSubjects) async {
    _users.clear();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final QuerySnapshot querySnapshot =
        await firestore.collection('users').get();

    String currenteUserClass = _currentUser!.classroom;
    if (_currentUser!.isProfessor) {
      final classroomDoc =
          await firestore.collection('subjects').doc(currenteUserClass).get();
      currenteUserClass = classroomDoc['name'];
    }

    for (final doc in querySnapshot.docs) {
      String classroomName = doc['classroom'];
      if (!_currentUser!.isProfessor && doc['isProfessor']) {
        final classroomDoc =
            await firestore.collection('subjects').doc(classroomName).get();
        classroomName = classroomDoc['name'];
      }
      final user = UserModel(
        id: doc.id,
        name: doc['name'],
        imageUrl: doc['imageUrl'],
        classroom: classroomName,
        isProfessor: doc['isProfessor'],
      );

      if (_currentUser!.isProfessor) {
        if (!user.isProfessor &&
            classroomSubjects.containsKey(classroomName) &&
            classroomSubjects[classroomName]!.contains(currenteUserClass)) {
          _users.add(user);
        }
      } else {
        if (user.isProfessor &&
            classroomSubjects.containsKey(_currentUser!.classroom) &&
            classroomSubjects[currenteUserClass]!.contains(classroomName)) {
          _users.add(user);
        }
      }
    }
    notifyListeners();
  }
}
