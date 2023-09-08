import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/activity.dart';
import '../../repository/activity_group.dart';
import '../../repository/subject.dart';
import '../../usecase/firestore_service.dart';
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
  late Future<List<Activity>> activitiesFuture;
  late UserModel? user;

  Widget _buildLoadingIndicator(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
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

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    user = authProvider.currentUser;
    activitiesFuture =
        FirestoreService().fetchActivities(widget.subject.id, user!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity>>(
      future: activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(context);
        } else if (snapshot.hasError) {
          return _buildError();
        } else {
          final activities = snapshot.data ?? [];

          final groupedActivities = groupActivities(activities);

          return Scaffold(
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
                      final activityGroup = groupedActivities[index];
                      return SafeArea(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(5),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activityGroup.activities.length,
                          itemBuilder: (context, index) {
                            final activity = activityGroup.activities[index];
                            return ActivityCard(
                              activity: activity,
                              user: activity.user,
                              isProfessor: user!.isProfessor,
                            );
                          },
                        ),
                      );
                    },
                    childCount: groupedActivities.length,
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        }
      },
    );
  }

  List<ActivityGroup> groupActivities(List<Activity> activities) {
    final Map<String, Map<String, List<Activity>>> groupedActivities = {};

    for (final activity in activities) {
      final subject = activity.user.classroom;
      final classes = activity.classes.join(', ');

      if (!groupedActivities.containsKey(subject)) {
        groupedActivities[subject] = {};
      }

      if (!groupedActivities[subject]!.containsKey(classes)) {
        groupedActivities[subject]![classes] = [];
      }

      groupedActivities[subject]![classes]!.add(activity);
    }

    final List<ActivityGroup> activityGroups = [];
    for (final subject in groupedActivities.keys) {
      for (final classes in groupedActivities[subject]!.keys) {
        final activitiesForGroup = groupedActivities[subject]![classes]!;
        activityGroups.add(ActivityGroup(
          subject: subject,
          classes: classes,
          activities: activitiesForGroup,
        ));
      }
    }

    return activityGroups;
  }
}
