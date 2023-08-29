import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/repository/user_model.dart';

class Activity {
  final DateTime assignedDate;
  final List classes;
  final String description;
  final DateTime? dueDate;
  final String? status;
  final String title;
  String? subject;
  UserModel? user;

  Activity({
    required Timestamp assignedDate,
    required this.classes,
    required this.description,
    Timestamp? dueDate,
    this.status,
    this.user,
    this.subject,
    required this.title,
  })  : assignedDate = assignedDate.toDate(),
        dueDate = dueDate?.toDate();
}
