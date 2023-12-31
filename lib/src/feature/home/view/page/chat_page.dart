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
  bool _isAnimating = false;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _listScrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> _sendMessage(ChatViewModel chatProvider) async {
    try {
      String msg = _inputController.text;
      setState(() {
        _isTyping = true;
        _isAnimating = true;
        _inputController.clear();
        _focusNode.unfocus();
        chatProvider.addUserMessage(msg: msg);
      });
      await chatProvider.sendMessageAndGetAnswers(msg);
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
        _isTyping = false;
        scrollListToEnd();
      });
    }
  }

  Future<void> _refreshChat(BuildContext context) {
    return Provider.of<ChatViewModel>(
      context,
      listen: false,
    ).loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel authProvider = Provider.of(context);
    final ChatViewModel chatProvider = Provider.of(context);
    final currentUser = authProvider.currentUser;
    final chatList = chatProvider.chatList;

    return RefreshIndicator(
      onRefresh: () => _refreshChat(context),
      color: Theme.of(context).colorScheme.outlineVariant,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
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
                Expanded(
                  child: chatList.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'welcome_message'.i18n(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          controller: _listScrollController,
                          itemCount: chatList.length,
                          itemBuilder: (context, index) {
                            final shouldAnimate =
                                index == chatList.length - 1 && _isAnimating;
                            return ChatWidget(
                              key: UniqueKey(),
                              msg: chatList[index].msg,
                              chatIndex: chatList[index].chatIndex,
                              user: currentUser,
                              shouldAnimate: shouldAnimate,
                            );
                          },
                        ),
                ),
                if (_isTyping) ...[
                  SpinKitThreeBounce(
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Theme.of(context).colorScheme.shadow,
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
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        String messageText = _inputController.text.trim();
                        if (messageText.isNotEmpty) {
                          await _sendMessage(chatProvider);
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
        ),
      ),
    );
  }
}
