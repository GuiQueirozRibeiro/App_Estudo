import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/subject.dart';
import '../widget/subejct_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthViewModel authProvider = Provider.of<AuthViewModel>(context);
    final currentUser = authProvider.currentUser;

    double cardHeight = MediaQuery.of(context).size.height * 0.21;

    return Scaffold(
      body: ListView.builder(
        itemCount: Subject.subjects.length,
        itemBuilder: (context, index) {
          return SubjectCard(
            cardHeight: cardHeight,
            subject: Subject.subjects[index],
          );
        },
      ),
      floatingActionButton: (currentUser?.classroom.length ?? 0) > 2
          ? FloatingActionButton(
              elevation: 5,
              onPressed: () {},
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
