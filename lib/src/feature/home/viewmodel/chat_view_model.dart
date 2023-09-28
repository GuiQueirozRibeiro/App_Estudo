import 'package:flutter/material.dart';

import '../../auth/repository/user_model.dart';
import '../repository/chat.dart';
import '../usecase/api_service.dart';

class ChatViewModel extends ChangeNotifier {
  final UserModel? _currentUser;
  List<Chat> chatList;

  ChatViewModel([
    this._currentUser,
    this.chatList = const [],
  ]);

  List<Chat> get getChatList {
    return chatList;
  }

  List<Chat> getMyChatList(UserModel user) {
    return chatList.where((chatUser) => chatUser.uid == user.id).toList();
  }

  void clearMessages() {
    chatList = [];
    notifyListeners();
  }

  void addUserMessage({required String msg}) {
    chatList.add(Chat(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(String msg) async {
    chatList.addAll(
        await ApiService.sendMessageGPT(msg, 'gpt-3.5-turbo', _currentUser!));
    notifyListeners();
  }

  Future<void> loadMessages() async {
    chatList.addAll(await ApiService.loadMessage(_currentUser!));
    notifyListeners();
  }
}
