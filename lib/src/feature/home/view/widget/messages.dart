import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/view/widget/auth.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/services/chat/chat_service.dart';
import 'message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of(context, listen: false);
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
