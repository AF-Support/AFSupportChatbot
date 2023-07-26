import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jumping_dot/jumping_dot.dart';

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
  }*/

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

  Future<String> sendChatConversation(
      List<Map<String, String>> conversation) async {
    final url = Uri.parse('http://localhost:8080/chat');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(conversation);

    final response = await post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Successful response, handle the result
      return response.body;
    } else {
      // Error response, handle the error
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to get response');
    }
  }

  //On this endpoint the server is using the completion capability
  Future<String> sendQuestion(String question) async {
    final uri = Uri.parse('http://localhost:8080/askQuestion')
        .replace(queryParameters: {'query': question});

    final response = await post(uri);

    if (response.statusCode == 200) {
      return response.body;
    } else {
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
                          _handleSendButtonPressed();
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
                    onPressed: _handleSendButtonPressed,
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

//Testing the chat capabilities
/*
 "recipes" : [
   {
      "issueTitle":"Discrepancy with Facebook in SKAN",
      "relevantMessages":"There is a discrepancy between the number of re-engagement events in AppsFlyer and Facebook. There are more events in AppsFlyer.\nWhat is causing this discrepancy",
      "linkToRecipe":"<TBD>",
      "domain":"SKAN",
      "issueDescription":"Discrepancy with Facebook in SKAN - we show more as FB does not present SKAN conversion of impressions",
      "comments":"Not a common ticket, but without the recipe team member might waste time in performing non-required analysis",
      "addedBy":"Arnon"
   },
   {
      "issueTitle":"Discrepency with an SRN",
      "relevantMessages":"There is a discrepency between Appsflyer and an SRN",
      "linkToRecipe":"https://docs.google.com/document/d/1MyyHnKVk25BJ8BvvkXb_0x2HISbNb4Ig5LfGj1yd8po/edit",
      "domain":"Core-SRN",
      "issueDescription":"The client is reporting a differetn in installs/ events to the SRN (usually less)",
      "comments":"",
      "addedBy":"Shaun"
   },
   {
      "issueTitle":"Discrepency with a store",
      "relevantMessages":"There is a discrepency between Appsflyer and a store",
      "linkToRecipe":"https://docs.google.com/document/d/1MyyHnKVk25BJ8BvvkXb_0x2HISbNb4Ig5LfGj1yd8po/edit",
      "domain":"Core",
      "issueDescription":"The client is reporting a differetn in installs/ events to the store",
      "comments":"",
      "addedBy":"Shaun"
   },
   {
      "issueTitle":"Missing postbacks",
      "relevantMessages":"Seeing a different number of installs/ events on a partner’s platform (non SRN), while their data replays on psotbacks sent from AF",
      "linkToRecipe":"https://docs.google.com/document/d/1MyyHnKVk25BJ8BvvkXb_0x2HISbNb4Ig5LfGj1yd8po/edit",
      "domain":"Core",
      "issueDescription":"",
      "comments":"",
      "addedBy":"Shaun"
   },
   {
      "issueTitle":"Error when downloading data via API",
      "relevantMessages":"The API call is not working or I am getting unexpected results",
      "linkToRecipe":"https://docs.google.com/document/d/1MyyHnKVk25BJ8BvvkXb_0x2HISbNb4Ig5LfGj1yd8po/edit",
      "domain":"Analytics",
      "issueDescription":"",
      "comments":"",
      "addedBy":"Shaun"
   },
   {
      "issueTitle":"Cannot see events in the dasharbod",
      "relevantMessages":"I cannot see an event in the dashabrod that was triggered",
      "linkToRecipe":"https://docs.google.com/document/d/1MyyHnKVk25BJ8BvvkXb_0x2HISbNb4Ig5LfGj1yd8po/edit",
      "domain":"Mobile",
      "issueDescription":"",
      "comments":"",
      "addedBy":"Shaun"
   },
   {
      "issueTitle":"No coversions are recorded",
      "relevantMessages":"<TBD>",
      "linkToRecipe":"<TBD>",
      "domain":"Core",
      "issueDescription":"Zero package customers do not see conversions - only deeplinks are available",
      "comments":"We need to provide the account package from zendesk to ChatGPT for supporting this recipe",
      "addedBy":"Arnon"
   },
   {
      "issueTitle":"Cost discrepancy",
      "relevantMessages":"<TBD>",
      "linkToRecipe":"<TBD>",
      "domain":"ROI360",
      "issueDescription":"Cost discrepancies in cost with networks",
      "comments":"List all the possibilities in the guide: 1. lost connections 2. duplications by change in campaign name 3. duplications by agency 4. other errors, get a report from ad network to compare",
      "addedBy":"Linda"
   },
   {
      "issueTitle":"SKAN CV updated by other SDKs",
      "relevantMessages":"Discrepancy in in-app events and revenue",
      "linkToRecipe":"<TBD>",
      "domain":"SKAN",
      "issueDescription":"There are other SDKs update the CV value than our SDK, which leads to discrepancy of in-app event and revenue",
      "comments":"Not a very common ticket, but would be nice if there is a tool helps in finding this or indicate this",
      "addedBy":"Lapat"
   },
   {
      "issueTitle":"Ad revenue discrepancy",
      "relevantMessages":"Sometimes client complaining about the Ad revenue between AppsFlyer and the Monetization/Mediation network",
      "linkToRecipe":"http://www.google.com",
      "domain":"ROI360",
      "issueDescription":"Ad revenue discrepancy between AppsFlyer and network",
      "comments":"What we can check: 1. Ask for ad revenue report from the network breakdown by date to compare. 2. Check Looker - ad revenue collector status. 3. Manually pull the ad revenue from the network if possible (sometimes the revenue provided by the network by the API is different from the one they presented in their dashboard)",
      "addedBy":"Nasib"
   },
   {
      "issueTitle":"Cannot send IAE for hybrid app",
      "relevantMessages":"They implemented IAE but no data are shown in the SDK logs.",
      "linkToRecipe":"<TBD>",
      "domain":"Mobile",
      "issueDescription":"The most frequent case is that the event is not passed from the web",
      "comments":"There are many clients who have different engineers for web and mobile, so their communication is not going well. We need to share where they can fix with checking both web and mobile.",
      "addedBy":"Wakana"
   },
   {
      "issueTitle":"ASA Best Practices",
      "relevantMessages":"Discrepancy with ASA",
      "linkToRecipe":"<TBD>",
      "domain":"CORE-SRN",
      "issueDescription":"The client is describing ASA issues/discrepancies",
      "comments":"",
      "addedBy":"Justin"
   },
   {
      "issueTitle":"Audience size issue",
      "relevantMessages":"The estimated size/actual size of audience seems wrong",
      "linkToRecipe":"<TBD>",
      "domain":"Audiences",
      "issueDescription":"How to validate the audience size/estimated size",
      "comments":"One of the most challenging types of audience question. We don't really have a tool to \"prove\" the size if the logic is complex. What action can we take in this case to address the concern?",
      "addedBy":"Linda"
   }
],
  */
