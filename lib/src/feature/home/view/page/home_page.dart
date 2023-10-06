import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/subject_list.dart';
import '../widget/subejct_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    final AuthViewModel authProvider = Provider.of(context, listen: false);
    currentUser = authProvider.currentUser;
  }

  Future<void> _refreshSubjects(BuildContext context) {
    return Provider.of<SubjectList>(
      context,
      listen: false,
    ).loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    final SubjectList subjectProvider = Provider.of(context);
    final subjectList = subjectProvider.subjects;
    final cardHeight = MediaQuery.of(context).size.height * 0.21;

    return RefreshIndicator(
      onRefresh: () => _refreshSubjects(context),
      color: Theme.of(context).colorScheme.outlineVariant,
      child: Scaffold(
        body: SafeArea(
          minimum: const EdgeInsets.only(top: 35),
          child: subjectList.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                  child: Text(
                    'no_subject'.i18n(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: subjectList.length,
                  itemBuilder: (context, index) {
                    return SubjectCard(
                      cardHeight: cardHeight,
                      subject: subjectList[index],
                      user: currentUser!,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
