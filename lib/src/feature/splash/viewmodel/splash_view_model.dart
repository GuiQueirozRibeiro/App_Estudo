import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:provider/provider.dart';

import '../../home/repository/activity_list.dart';
import '../../home/repository/subject_list.dart';
import '../../home/repository/user_list.dart';
import '../../home/viewmodel/chat_view_model.dart';

class SplashViewModel extends ChangeNotifier {
  Future<String?> loadData(BuildContext context) async {
    try {
      Map<String, List<String>> classroomSubjects = {};
      Provider.of<ChatViewModel>(context, listen: false).clearMessages();
      classroomSubjects =
          await Provider.of<SubjectList>(context, listen: false).loadSubjects();
      // ignore: use_build_context_synchronously
      Provider.of<UserList>(context, listen: false)
          .loadUsers(classroomSubjects)
          .then((_) => {
                Provider.of<ActivityList>(
                  context,
                  listen: false,
                ).loadActivity().then((_) => {
                      Provider.of<ChatViewModel>(
                        context,
                        listen: false,
                      )
                          .loadMessages()
                          .then((_) => Modular.to.navigate('/home/'))
                    })
              });
    } catch (error) {
      rethrow;
    }
    return null;
  }
}
