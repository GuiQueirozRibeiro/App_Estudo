import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';

import '../../../auth/repository/user_model.dart';
import '../../repository/subject.dart';

class SubjectCard extends StatelessWidget {
  final double cardHeight;
  final Subject subject;
  final UserModel user;
  final bool isForm;

  const SubjectCard({
    super.key,
    required this.cardHeight,
    required this.subject,
    required this.user,
    this.isForm = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () => isForm
            ? () {}
            : Modular.to.pushNamed('details/', arguments: subject),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: SizedBox(
            height: cardHeight,
            child: subject.imageUrl == ''
                ? Center(
                    child: Text(
                      'no_image'.i18n(),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            subject.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      if (user.isProfessor)
                        Positioned(
                          top: 25,
                          right: 25,
                          child: GestureDetector(
                            onTap: () => Modular.to.pushNamed('subjectFormPage',
                                arguments: subject),
                            child: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      if (!user.isProfessor)
                        Positioned(
                          top: 50,
                          left: 20,
                          child: Text(
                            user.classroom,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Text(
                          subject.teacher,
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
