import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../common/utils/constants.dart';
import '../../auth/repository/user_model.dart';
import '../repository/chat.dart';

class ApiService {
  static Future<List<Chat>> loadMessages(UserModel user) async {
    List<Chat> chatList = [];
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot querySnapshot = await firestore
          .collection('chats')
          .doc(user.id)
          .collection('userChats')
          .orderBy('date')
          .get();

      for (final doc in querySnapshot.docs) {
        final uid = user.id;
        final msg = doc["msg"];
        final response = doc["response"];

        chatList.addAll(
          List.generate(
            2,
            (index) => Chat(
              msg: index == 0 ? msg : response,
              chatIndex: index == 0 ? 0 : 1,
              uid: uid,
            ),
          ),
        );
      }

      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  static Future<void> saveMessage(
    String message,
    List<Chat> response,
    UserModel user,
  ) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final chatRef = firestore
        .collection('chats')
        .doc(user.id)
        .collection('userChats')
        .doc();

    final chatData = {
      'msg': message,
      'response': response.last.msg,
      'date': Timestamp.fromDate(DateTime.now()),
    };

    chatRef.set(chatData);
  }

  static Future<List<Chat>> sendMessageGPT(
    String message,
    String modelId,
    UserModel user,
  ) async {
    List<Chat> chatList = [];
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("${Constants.baseUrl}/chat/completions"),
        headers: {
          'Authorization': 'Bearer ${Constants.openaiApiKey}',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "messages": [
              {
                "role": "user",
                "content": message,
              }
            ]
          },
        ),
      );

      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      if (jsonResponse["choices"].length > 0) {
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => Chat(
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }
      saveMessage(message, chatList, user);
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
