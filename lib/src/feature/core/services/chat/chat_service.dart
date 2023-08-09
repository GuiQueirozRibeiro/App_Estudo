import '../../models/chat_message.dart';
import '../../models/chat_user.dart';
import 'chat_firebase_service.dart';

abstract class ChatService {
  Stream<List<ChatMessage>> messagesStream();
  Future<ChatMessage?> save(String texto, ChatUser user);

  factory ChatService() {
    return ChatFirebaseService();
  }
}
