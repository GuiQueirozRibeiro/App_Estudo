import 'package:flutter/material.dart';

import '../repository/chat.dart';
import '../usecase/api_service.dart';

class ChatViewModel extends ChangeNotifier {
  List<Chat> chatList = [];
  List<Chat> get getChatList {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList.add(Chat(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers({required String msg}) async {
    chatList.addAll(await ApiService.sendMessageGPT(
      message: msg,
      modelId: 'gpt-3.5-turbo',
    ));
    notifyListeners();
  }
}
