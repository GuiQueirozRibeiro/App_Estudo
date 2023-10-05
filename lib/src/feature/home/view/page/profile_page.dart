import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/repository/user_model.dart';
import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/user_list.dart';
import '../widget/custom_avatar_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Uri _url = Uri.parse('https://github.com/GuiQueirozRibeiro');
  late UserModel? currentUser;
  late AuthViewModel authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of(context, listen: false);
    currentUser = authProvider.currentUser;
  }

  Future<void> _showConfirmationDialog() async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout_account'.i18n()),
          content: Text('are_you_sure'.i18n()),
          actions: [
            TextButton(
              child: Text('no'.i18n()),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('yes'.i18n()),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      authProvider.logout();
      Modular.to.navigate('/auth/');
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserList userList = Provider.of(context, listen: false);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.only(top: screenHeight * 0.06, bottom: 70),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAvatarProfile(
                onImageChanged: (newImage) {
                  authProvider.changeUserImage(newImage);
                },
                user: currentUser!,
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _launchUrl,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.014),
                    elevation: 4,
                  ),
                  child: Text(
                    'help_support'.i18n(),
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      userList.toggleUserList();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.014),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 4,
                  ),
                  child: Text(
                    currentUser!.isProfessor
                        ? 'students'.i18n()
                        : 'teachers'.i18n(),
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              Expanded(
                child: userList.showUserList && userList.users.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          currentUser!.isProfessor
                              ? 'no_students'.i18n()
                              : 'no_teachers'.i18n(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenHeight * 0.02),
                        ),
                      )
                    : ListView.builder(
                        itemCount:
                            userList.showUserList ? userList.usersCount : 0,
                        itemBuilder: (context, index) {
                          final user = userList.users[index];
                          return GestureDetector(
                            onTap: () => Modular.to
                                .pushNamed('profileDetails', arguments: user),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              margin: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01,
                                horizontal: 16,
                              ),
                              child: ListTile(
                                title: Text(
                                  user.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(user.classroom),
                                leading: Container(
                                  width: screenHeight * 0.061,
                                  height: screenHeight * 0.061,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      user.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "terms_conditions_title".i18n(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.025,
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                'terms_conditions_content'.i18n(),
                                style: TextStyle(fontSize: screenHeight * 0.02),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  'terms_conditions_title'.i18n(),
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 5,
        onPressed: () => _showConfirmationDialog(),
        child: Icon(
          Icons.exit_to_app,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
