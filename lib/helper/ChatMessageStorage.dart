import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/ChatMessage.dart';

class ChatMessagesStorage {
  static const String _key = 'chatMessages';

  static Future<void> saveChatMessages(List<ChatMessage> chatMessages) async {
    final prefs = await SharedPreferences.getInstance();
    final chatMessagesJson = jsonEncode(chatMessages);
    await prefs.setString(_key, chatMessagesJson);
  }

  static Future<List<ChatMessage>> getChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final chatMessagesJson = prefs.getString(_key);

    if (chatMessagesJson != null) {
      final List<dynamic> decodedList = jsonDecode(chatMessagesJson);
      final List<ChatMessage> chatMessages = decodedList.map<ChatMessage>((dynamic item) {
        final Map<String, dynamic> jsonMap = item as Map<String, dynamic>;
        return ChatMessage.fromJson(jsonMap);
      }).toList();
      return chatMessages;
    } else {
      return [];
    }
  }


}
