import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../usecase/chat_notification_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ChatNotificationService>(context);
    final items = service.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
      ),
      body: service.itemsCount != 0
          ? ListView.builder(
              itemCount: service.itemsCount,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(items[i].title),
                subtitle: Text(items[i].body),
                onTap: () => service.remove(i),
              ),
            )
          : const Center(child: Text('Sem dados')),
    );
  }
}
