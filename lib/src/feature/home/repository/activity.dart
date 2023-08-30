import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../auth/repository/user_model.dart';

class Activity {
  final String id;
  final List classes;
  final String description;
  final DateTime assignedDate;
  final DateTime? dueDate;
  String? status;
  String? subject;
  UserModel? user;

  Activity({
    required this.id,
    required this.classes,
    required this.description,
    required Timestamp assignedDate,
    Timestamp? dueDate,
    this.status,
    this.subject,
    this.user,
  })  : assignedDate = assignedDate.toDate(),
        dueDate = dueDate?.toDate();

  String formatDateTime(DateTime dateTime) {
    final formattedDate = DateFormat("d 'de' MMM 'às' HH:mm").format(dateTime);
    return formattedDate;
  }

  String formattedAssignedDate() {
    return formatDateTime(assignedDate);
  }

  String formattedDueDate() {
    if (dueDate != null) {
      return formatDateTime(dueDate!);
    } else {
      return "Sem prazo";
    }
  }
}
