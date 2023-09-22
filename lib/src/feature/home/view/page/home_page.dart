import 'package:flutter/material.dart';
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
  late UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
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
    final subjectList = Provider.of<SubjectList>(context, listen: false);
    final cardHeight = MediaQuery.of(context).size.height * 0.21;

    return RefreshIndicator(
      onRefresh: () => _refreshSubjects(context),
      color: Theme.of(context).colorScheme.outlineVariant,
      child: Scaffold(
        body: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: subjectList.itemsCount,
            itemBuilder: (context, index) {
              return SubjectCard(
                cardHeight: cardHeight,
                subject: subjectList.items[index],
                user: currentUser!,
              );
            },
          ),
        ),
      ),
    );
  }
}
