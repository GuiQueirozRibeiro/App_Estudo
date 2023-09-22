import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/user_model.dart';

class UserList with ChangeNotifier {
  bool _showUserList;
  final UserModel? _currentUser;
  final List<UserModel> _items;

  UserList([
    this._currentUser,
    this._showUserList = false,
    this._items = const [],
  ]);

  bool get showUserList => _showUserList;

  int get itemsCount {
    return _items.length;
  }

  List<UserModel> get items => [..._items];

  void toggleUserList() {
    _showUserList = !_showUserList;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    _items.clear();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final QuerySnapshot querySnapshot =
        await firestore.collection('users').get();

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

      if (user.id != _currentUser!.id &&
          !user.isProfessor == _currentUser!.isProfessor) {
        _items.add(user);
      }
    }

    notifyListeners();
  }
}
