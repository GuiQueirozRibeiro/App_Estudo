import 'package:flutter/material.dart';

import '../repository/chat_model.dart';
import '../usecase/api_service.dart';

class ChatViewModel extends ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
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
