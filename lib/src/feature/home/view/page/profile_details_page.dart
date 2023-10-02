import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/repository/user_model.dart';
import '../../repository/activity.dart';
import '../../repository/activity_list.dart';
import '../../repository/chat.dart';
import '../../viewmodel/chat_view_model.dart';
import '../widget/activity_card.dart';
import '../widget/chat_widget.dart';
import '../widget/custom_avatar_profile.dart';

class ProfileDetailsPage extends StatefulWidget {
  final UserModel user;
  const ProfileDetailsPage({super.key, required this.user});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late List<Activity> activityGroup;
  late List<Chat> chatList;
  final ScrollController _listScrollController = ScrollController();
  bool dataLoaded = false;

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData(BuildContext context) async {
    if (widget.user.isProfessor) {
      await Provider.of<ActivityList>(
        context,
        listen: false,
      ).loadActivity();
    } else {
      chatList = await Provider.of<ChatViewModel>(
        context,
        listen: false,
      ).loadMessagesFromUser(widget.user);
    }
    setState(() {
      dataLoaded = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!dataLoaded) {
      _loadData(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.isProfessor) {
      final ActivityList activityList = Provider.of(context, listen: false);
      activityGroup = activityList.getUserList(widget.user.id);
    }
    return Scaffold(
      appBar: AppBar(title: Text('profile_details'.i18n()), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAvatarProfile(user: widget.user),
            const SizedBox(height: 40),
            Text(
              'history'.i18n(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                color: Theme.of(context).colorScheme.outlineVariant,
                onRefresh: () => _loadData(context),
                child: dataLoaded
                    ? widget.user.isProfessor
                        ? activityGroup.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'no_activity'.i18n(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(5),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activityGroup.length,
                                itemBuilder: (context, index) {
                                  final activity = activityGroup[index];
                                  return ActivityCard(
                                    activity: activity,
                                    isProfessor: true,
                                    isForm: true,
                                  );
                                },
                              )
                        : chatList.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'no_message'.i18n(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                controller: _listScrollController,
                                itemCount: chatList.length,
                                itemBuilder: (context, index) {
                                  return ChatWidget(
                                    msg: chatList[index].msg,
                                    chatIndex: chatList[index].chatIndex,
                                    user: widget.user,
                                  );
                                },
                              )
                    : Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
