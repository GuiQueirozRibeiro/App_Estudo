import 'package:estudo/src/feature/core/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/view/widget/auth.dart';
import '../../../core/services/chat/chat_service.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String _message = '';
  final _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    Auth auth = Provider.of(context, listen: false);
    final user = auth.user;

    if (user != null) {
      await ChatService().save(_message, user as ChatUser);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            onChanged: (msg) => setState(() => _message = msg),
            decoration: const InputDecoration(
              labelText: 'Enviar mensagem...',
            ),
            onSubmitted: (_) {
              if (_message.trim().isNotEmpty) {
                _sendMessage();
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _message.trim().isEmpty ? null : _sendMessage,
        ),
      ],
    );
  }
}
