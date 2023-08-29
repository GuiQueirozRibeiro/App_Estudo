import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/repository/user_model.dart';
import '../repository/activity.dart';
import '../repository/subject.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        teachers: doc['teachers'],
      );

      if (subject.classes.contains(user.classroom) ||
          (user.isProfessor && subject.name == user.classroom)) {
        subjects.add(subject);
      }
    }

    return subjects;
  }

  Future<List<Activity>> fetchActivities(
    String? subjectId,
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
          title: doc['title'],
          assignedDate: doc['assignedDate'],
          classes: doc['classes'],
          description: doc['description'],
          dueDate: doc['dueDate'],
          status: doc['status'],
          user: professor,
        );

        activities.add(activity);
      }
    }

    return activities;
  }
}
