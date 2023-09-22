import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../auth/repository/user_model.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
    required this.msg,
    required this.chatIndex,
    required this.user,
    this.shouldAnimate = false,
  });

  final String msg;
  final int chatIndex;
  final UserModel? user;
  final bool shouldAnimate;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _isAnimating = widget.shouldAnimate;
  }

  ImageProvider _getImageProvider() {
    if (widget.chatIndex != 0) {
      return const AssetImage("lib/assets/images/chat_logo.png");
    } else if (widget.user?.imageUrl != null) {
      return NetworkImage(widget.user!.imageUrl);
    } else {
      return const AssetImage("lib/assets/images/avatar.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          widget.chatIndex == 0 ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: widget.chatIndex == 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.shadow,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: _getImageProvider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: widget.chatIndex == 0
                  ? Text(
                      widget.msg,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : _isAnimating
                      ? DefaultTextStyle(
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          child: AnimatedTextKit(
                            isRepeatingAnimation: false,
                            repeatForever: false,
                            displayFullTextOnTap: true,
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TyperAnimatedText(
                                widget.msg.trim(),
                                speed: const Duration(milliseconds: 20),
                              ),
                            ],
                            onFinished: () {
                              setState(() {
                                _isAnimating = false;
                              });
                            },
                          ),
                        )
                      : Text(
                          widget.msg.trim(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
