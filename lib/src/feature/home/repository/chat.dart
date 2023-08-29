class Chat {
  final String msg;
  final int chatIndex;

  Chat({required this.msg, required this.chatIndex});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        msg: json['msg'],
        chatIndex: json['chatIndex'],
      );
}
