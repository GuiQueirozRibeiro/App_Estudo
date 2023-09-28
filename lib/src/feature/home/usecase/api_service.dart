import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../common/utils/constants.dart';
import '../../auth/repository/user_model.dart';
import '../repository/chat.dart';

class ApiService {
  static Future<List<Chat>> loadMessage(UserModel user) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Chat> chatList = [];
    try {
      final QuerySnapshot querySnapshot =
          await firestore.collection('chat').get();

      for (final doc in querySnapshot.docs) {
        final message =
            Chat(msg: doc["msg"], chatIndex: doc["index"], uid: doc["uid"]);
        if (message.uid == user.id) {
          chatList.add(message);
        }
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  static Future<void> saveMessage(
    List<Chat> chatList,
    UserModel user,
  ) async {
    debugPrint('3');

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    debugPrint('4');

    final chatRef = firestore.collection('chat').doc();
    debugPrint(chatList.first.msg);
    debugPrint(chatList.first.chatIndex.toString());

    debugPrint(chatList.last.msg);
    debugPrint(chatList.last.chatIndex.toString());

    final chatDataUser = {
      'msg': chatList.first.msg,
      'index': chatList.first.chatIndex,
      'uid': user.id,
    };

    final chatDataGPT = {
      'msg': chatList.last.msg,
      'index': chatList.last.chatIndex,
      'uid': user.id,
    };

    chatRef.set(chatDataUser);
    chatRef.set(chatDataGPT);
  }

  static Future<List<Chat>> sendMessageGPT(
    String message,
    String modelId,
    UserModel user,
  ) async {
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
      List<Chat> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => Chat(
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }
      saveMessage(chatList, user);
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
