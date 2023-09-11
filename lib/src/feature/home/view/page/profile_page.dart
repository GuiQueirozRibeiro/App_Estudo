import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/viewmodel/auth_view_model.dart';
import '../widget/circle_avatar_edit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _showConfirmationDialog() async {
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    bool confirmed = await showDialog(
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

    if (confirmed) {
      authProvider.logout();
      Modular.to.navigate('/auth/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatarWithEditButton(
                onImageChanged: (newImage) {
                  authProvider.changeUserImage(newImage);
                },
                userImageUrl: authProvider.currentUser?.imageUrl,
              ),
              const SizedBox(height: 20),
              Text(
                authProvider.currentUser?.name ?? '',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                authProvider.currentUser!.isProfessor
                    ? 'teacher'.i18n()
                    : authProvider.currentUser?.classroom ?? '',
                style: const TextStyle(fontSize: 16),
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
