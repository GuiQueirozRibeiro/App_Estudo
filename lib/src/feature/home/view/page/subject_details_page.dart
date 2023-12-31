import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/activity_list.dart';
import '../../repository/subject.dart';
import '../widget/activity_card.dart';

class SubjectDetailsPage extends StatefulWidget {
  final Subject subject;

  const SubjectDetailsPage({
    Key? key,
    required this.subject,
  }) : super(key: key);

  @override
  State<SubjectDetailsPage> createState() => _SubjectDetailsPageState();
}

class _SubjectDetailsPageState extends State<SubjectDetailsPage> {
  late final UserModel? user;

  @override
  void initState() {
    super.initState();
    final AuthViewModel authProvider = Provider.of(context, listen: false);
    user = authProvider.currentUser;
  }

  Future<void> _refreshActivities(BuildContext context) {
    return Provider.of<ActivityList>(
      context,
      listen: false,
    ).loadActivity();
  }

  @override
  Widget build(BuildContext context) {
    final ActivityList activityList = Provider.of(context);
    final activityGroup = activityList.getSubjectList(widget.subject.id);

    return RefreshIndicator(
      onRefresh: () => _refreshActivities(context),
      color: Theme.of(context).colorScheme.outlineVariant,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.subject.name),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'image_${widget.subject.name}',
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.subject.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0, 0.8),
                          end: Alignment(0, 0),
                          colors: [
                            Color.fromRGBO(0, 0, 0, 0.6),
                            Color.fromRGBO(0, 0, 0, 0)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (activityGroup.isEmpty) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 60),
                      child: Text(
                        user!.isProfessor
                            ? 'no_activity_prof'.i18n()
                            : 'no_activity'.i18n(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ActivityCard(
                        activity: activityGroup[index],
                        isProfessor: user!.isProfessor,
                        subject: widget.subject,
                      ),
                    );
                  }
                },
                childCount: activityGroup.isEmpty ? 1 : activityGroup.length,
              ),
            ),
          ],
        ),
        floatingActionButton: user!.isProfessor
            ? FloatingActionButton(
                elevation: 5,
                onPressed: () => Modular.to.pushNamed('activityFormPage'),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
