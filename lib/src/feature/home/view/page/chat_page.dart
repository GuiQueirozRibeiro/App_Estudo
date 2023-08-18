import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/usecase/auth_use_case.dart';
import '../widget/messages.dart';
import '../widget/new_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<void> _showConfirmationDialog() async {
    final authProvider = Provider.of<AuthUseCase>(context, listen: false);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudo Chat'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _showConfirmationDialog(),
          ),
        ],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Expanded(child: Messages()),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}