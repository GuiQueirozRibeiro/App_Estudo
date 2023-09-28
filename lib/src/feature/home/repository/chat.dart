class Chat {
  final String msg;
  final int chatIndex;
  final String? uid;

  Chat({required this.msg, required this.chatIndex, this.uid});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        msg: json['msg'],
        chatIndex: json['chatIndex'],
      );
}
