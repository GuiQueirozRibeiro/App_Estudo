import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

import '../../auth/repository/user_model.dart';

class Activity {
  final String id;
  final UserModel user;
  final String subjectId;
  List classes;
  String description;
  DateTime assignedDate;
  DateTime? dueDate;
  DateTime? editDate;
  bool isEdit;

  Activity({
    required this.id,
    required this.user,
    required this.subjectId,
    required this.classes,
    required this.description,
    required this.isEdit,
    required Timestamp assignedDate,
    Timestamp? editDate,
    Timestamp? dueDate,
  })  : assignedDate = assignedDate.toDate(),
        dueDate = dueDate?.toDate(),
        editDate = editDate?.toDate();

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatDateTime(DateTime dateTime, String language) {
    final agora = DateTime.now();

    if (isSameDate(agora, dateTime)) {
      final formattedTime = DateFormat("HH:mm").format(dateTime);
      return formattedTime;
    } else if (isSameDate(agora.subtract(const Duration(days: 1)), dateTime)) {
      return "yesterday".i18n();
    } else {
      final formattedDate = DateFormat("d 'de' MMM", language).format(dateTime);
      return formattedDate;
    }
  }

  String formattedAssignedDate(String language) {
    return formatDateTime(assignedDate, language);
  }

  String formattedEditDate(String language) {
    return ' (${'edit'.i18n()} ${formatDateTime(editDate!, language)})';
  }

  String formattedDueDate(String language) {
    if (dueDate != null) {
      return formatDateTime(dueDate!, language);
    } else {
      return "whitout_deadline".i18n();
    }
  }
}
