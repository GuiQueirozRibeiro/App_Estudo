import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../auth/repository/user_model.dart';

class ChatWidget extends StatelessWidget {
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

  ImageProvider _getImageProvider() {
    if (chatIndex != 0) {
      return const AssetImage("lib/assets/images/chat_logo.png");
    } else if (user?.imageUrl != null) {
      return NetworkImage(user!.imageUrl);
    } else {
      return const AssetImage("lib/assets/images/avatar.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: chatIndex == 0 ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: chatIndex == 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
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
              child: chatIndex == 0
                  ? Text(
                      msg,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : shouldAnimate
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
                                msg.trim(),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          msg.trim(),
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
