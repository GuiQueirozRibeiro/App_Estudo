import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../auth/viewmodel/auth_view_model.dart';
import '../../repository/chat.dart';
import '../../viewmodel/chat_view_model.dart';
import '../widget/chat_widget.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  bool _isTyping = false;

  late TextEditingController _inputController;
  late ScrollController _listScrollController;
  late FocusNode _focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    _inputController = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> _sendMessage({required ChatViewModel chatProvider}) async {
    try {
      String msg = _inputController.text;
      setState(() {
        _isTyping = true;
        chatProvider.addUserMessage(msg: msg);
        _inputController.clear();
        _focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(msg: msg);
      setState(() {});
    } catch (error) {
      chatProvider.chatList.addAll(
        List.generate(
          1,
          (index) => Chat(
            msg: error.toString(),
            chatIndex: 1,
          ),
        ),
      );
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel authProvider = Provider.of<AuthViewModel>(context);
    final currentUser = authProvider.currentUser;
    final chatProvider = Provider.of<ChatViewModel>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'app_name'.i18n(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset('lib/assets/images/icon.png',
                    height: 60, width: 60),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: chatProvider.getChatList[index].msg,
                    chatIndex: chatProvider.getChatList[index].chatIndex,
                    user: currentUser,
                    shouldAnimate: chatProvider.getChatList.length - 1 == index,
                  );
                },
              ),
            ),
            if (_isTyping) ...[
              SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.tertiary,
                size: 18,
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _inputController,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'message_field'.i18n(),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    String messageText = _inputController.text.trim();
                    if (messageText.isNotEmpty) {
                      await _sendMessage(chatProvider: chatProvider);
                    } else {
                      _focusNode.unfocus();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
