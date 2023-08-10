import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/usecase/auth_use_case.dart';
import '../../repository/chat_message.dart';
import '../../usecase/chat_service.dart';
import 'message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    AuthUseCase auth = Provider.of(context, listen: false);
    final currentUser = auth.user;
    return StreamBuilder<List<ChatMessage>>(
      stream: ChatService().messagesStream(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Sem dados. Vamos conversar?'));
        } else {
          final msgs = snapshot.data!;
          return ListView.builder(
            reverse: true,
            itemCount: msgs.length,
            itemBuilder: (ctx, i) => MessageBubble(
              key: ValueKey(msgs[i].id),
              message: msgs[i],
              belongsToCurrentUser: currentUser?.uid == msgs[i].userId,
            ),
          );
        }
      },
    );
  }
}
