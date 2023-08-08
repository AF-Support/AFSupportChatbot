import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jumping_dot/jumping_dot.dart';
import '../constants/app_constants.dart';
import '../widgets/ChatMessage.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _questionController = TextEditingController();
  List<ChatMessage> _chatMessages = [];
  bool _isLoading = false;
  bool _enableChat = true;

  @override
  initState() {
    super.initState();
    //loadChatMessages();
  }

  @override
  void dispose() {
    super.dispose();
    _questionController.dispose();
  }

  List<Map<String, String>> convertChatMessages(
      List<ChatMessage> chatMessages) {
    List<Map<String, String>> convertedMessages = [];
    for (var m in chatMessages) {
      Map<String, String> currentMessage = {
        'role': m.role,
        'content': m.message
      };
      convertedMessages.add(currentMessage);
    }
    return convertedMessages;
  }

  void _handleSendPressed() async {
    String question = _questionController.text;
    // Asking a question
    if (question.isNotEmpty) {
      _questionController.clear();
      setState(() {
        _chatMessages.add(ChatMessage(role: "user", message: question.trim()));
      });
      setState(() {
        _isLoading = true;
        _enableChat = false;
      });
      try {
        // Retrieving answer from Chat Completion
        print("In _handleSendPressed function");
        String response = await sendChatMessage(question);
        response = response.trim();
        setState(() {
          _chatMessages.add(ChatMessage(role: "assistant", message: response));
        });
      } catch (e) {
        setState(() {
          _chatMessages.add(ChatMessage(role: "error", message: '$e'));
        });
      } finally {
        setState(() {
          _isLoading = false;
          _enableChat = true;
        });
      }
    }
  }

  Future<String> sendChatMessage(String message) async {
    final url = Uri.parse('https://dry-frost-4900.fly.dev/embedded_chat');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({"message": message});

    final response = await post(url, headers: headers, body: body);
    print(response.body);
    if (response.statusCode == 200) {
      // Successful response, handle the result
      return response.body;
    } else {
      // Error response, handle the error
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to get response');
    }
  }

  Future<String> sendChatConversation(
      List<Map<String, String>> conversation) async {
    final url = Uri.parse('https://dry-frost-4900.fly.dev/chat');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(conversation);

    final response = await post(url, headers: headers, body: body);
    print(response.body);
    if (response.statusCode == 200) {
      // Successful response, handle the result
      return response.body;
    } else {
      // Error response, handle the error
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to get response');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OpenAI Chat Tester',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff434446),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 8,
        shadowColor: Colors.grey[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  return _chatMessages[index];
                },
              ),
            ),
          ),
          if (_isLoading)
            JumpingDots(
              color: const Color(0xff220D4E),
              radius: 10,
              numberOfDots: 3,
            ), // Show loading indicator if _isLoading is true
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[200],
                      ),
                      child: TextField(
                        enabled: _enableChat,
                        controller: _questionController,
                        onSubmitted: (value) {
                          _handleSendPressed();
                        },
                        textInputAction: TextInputAction.send,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Send a message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _handleSendPressed, //_handleSendButtonPressed,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
  void loadChatMessages() async {
    List<ChatMessage> savedChatMessages =
    await ChatMessagesStorage.getChatMessages();
    setState(() {
      _chatMessages = savedChatMessages;
    });
    print(savedChatMessages);
  }

  void saveChatMessages() async {
    await ChatMessagesStorage.saveChatMessages(_chatMessages);
  }

  ///  Flow:
  /// 1. The user sends a question through the chat.
  /// 2. The question is processed and added to the _chatMessages list, with the user's role.
  /// 3. The _chatMessages list is converted into a list of Map<String, String> called messagesToServer.
  /// 4. The messagesToServer list is sent to the server using the sendChatConversation function, which performs an HTTP POST request with the converted messages.
  /// 5. The server calculates the response based on the received messages and returns it as the response body.
  /// 6. The response is extracted from the response body and added to the _chatMessages list with the assistant's role.
  /// 7. If an error occurs during the process, an error message is added to the _chatMessages list with the error details.
  void _handleSendButtonPressed() async {
    String question = _questionController.text;
    //Asking a questions
    if (question.isNotEmpty) {
      _questionController.clear();
      setState(() {
        _chatMessages.add(ChatMessage(role: "user", message: question));
      });
      setState(() {
        _isLoading = true;
        _enableChat = false;
      });
      try {
        //Retrieving answer from Chat Completion
        List<Map<String, String>> messagesToServer =
            convertChatMessages(_chatMessages);
        String response = await sendChatConversation(messagesToServer);

        //Retrieving answer from Completion
        // String alteredQuestion = '$question , In your answer only use the training data you have! If you dont know the answer please return I don\'t know!';
        // String response = await sendQuestion(alteredQuestion);

        response = response.trim();
        setState(() {
          _chatMessages.add(ChatMessage(role: "assistant", message: response));
        });
      } catch (e) {
        setState(() {
          _chatMessages.add(ChatMessage(role: "error", message: '$e'));
        });
      } finally {
        setState(() {
          _isLoading = false;
          _enableChat = true;
        });
      }
    }
  } */