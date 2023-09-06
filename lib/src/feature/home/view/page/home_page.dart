import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/subject.dart';
import '../../usecase/firestore_service.dart';
import '../widget/subejct_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserModel? currentUser;
  late FirestoreService firestoreProvider;
  List<Subject> subjectsList = [];
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    currentUser = authProvider.currentUser;
    firestoreProvider = Provider.of<FirestoreService>(context, listen: false);

    _fetchSubjects();

    firestoreProvider.addListener(_handleFirestoreChange);
  }

  @override
  void dispose() {
    firestoreProvider.removeListener(_handleFirestoreChange);
    super.dispose();
  }

  void _handleFirestoreChange() {
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    final subjects = await firestoreProvider.fetchSubjects(currentUser!);
    setState(() {
      subjectsList = subjects;
      isDataLoaded = true;
    });
  }

  Widget _buildSubjectListView(List<Subject> subjectsList, double cardHeight) {
    return ListView.builder(
      itemCount: subjectsList.length,
      itemBuilder: (context, index) {
        return SubjectCard(
          cardHeight: cardHeight,
          subject: subjectsList[index],
          user: currentUser!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = MediaQuery.of(context).size.height * 0.21;

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchSubjects();
      },
      color: Theme.of(context).colorScheme.outlineVariant,
      child: Scaffold(
        body: _buildSubjectListView(subjectsList, cardHeight),
      ),
    );
  }
}
