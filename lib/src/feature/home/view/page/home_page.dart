import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
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
  late Future<List<Subject>> subjectsFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    currentUser = authProvider.currentUser;

    subjectsFuture = _fetchSubjects();
  }

  Future<List<Subject>> _fetchSubjects() async {
    return await FirestoreService().fetchSubjects(currentUser!);
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      body: Center(
        child: Text('error_occurred'.i18n()),
      ),
    );
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
        setState(() {
          subjectsFuture = _fetchSubjects();
        });
      },
      color: Theme.of(context).colorScheme.outlineVariant,
      child: FutureBuilder<List<Subject>>(
        future: subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: _buildLoadingIndicator(context));
          } else if (snapshot.hasError) {
            return Scaffold(body: _buildError());
          } else {
            final List<Subject> subjectsList = snapshot.data ?? [];

            return Scaffold(
              body: _buildSubjectListView(subjectsList, cardHeight),
              floatingActionButton: (currentUser?.classroom.length ?? 0) > 2
                  ? FloatingActionButton(
                      elevation: 5,
                      onPressed: () => Modular.to.pushNamed('subjectFormPage'),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    )
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          }
        },
      ),
    );
  }
}
