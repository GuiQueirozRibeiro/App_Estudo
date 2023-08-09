import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/custom_text_field.dart';
import '../../../auth/view/widget/auth.dart';
import '../../../core/services/chat/chat_service.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String _message = '';

  Future<void> _sendMessage() async {
    Auth auth = Provider.of(context, listen: false);
    final user = auth.currentUser;

    if (user != null) {
      await ChatService().save(_message, user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Expanded(
        child: CustomTextField(
          text: 'Enviar mensagem...',
          onChanged: (msg) => setState(() => _message = msg!),
          onFieldSubmitted: (_) {
            if (_message.trim().isNotEmpty) {
              _sendMessage();
            }
          },
        ),
      ),
    );
  }
}
