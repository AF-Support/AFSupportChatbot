import 'dart:convert';

import 'package:af_support_open_ai/constants/app_constants.dart';
import 'package:af_support_open_ai/helper/RecipesList.dart';
import 'package:af_support_open_ai/widgets/FileUploaderWidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:logger/logger.dart';

import '../helper/ZendeskQuestionArray.dart';

class ZDQResolverPage extends StatefulWidget {
  @override
  _ZDQResolverPageState createState() => _ZDQResolverPageState();
}

class _ZDQResolverPageState extends State<ZDQResolverPage> {
  String templateData = "";
  String zendeskQData = "";
  bool templateUploaded = false;
  bool ZDQUploaded = false;
  bool didCompleteTest = false;
  String testResults = "";
  var logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2,
        // Number of method calls to be displayed
        errorMethodCount: 8,
        // Number of method calls if stacktrace is provided
        lineLength: 120,
        // Width of the output
        colors: true,
        // Colorful log messages
        printEmojis: true,
        // Print an emoji for each log message
        printTime: false // Should each log print contain a timestamp
        ),
  );
  bool isLoading = false;
  bool zdqUploadedSuccessfully = false;
  String zdqResponseMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _uploadZDQFile() async {
    var picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
        allowMultiple: false);
    if (picked != null) {
      PlatformFile file = picked.files.first;
      String fileContent = utf8.decode(file.bytes as List<int>);
      zendeskQData = fileContent;
      setState(() {
        ZDQUploaded = true;
      });
    }
    sendZDQDataToServer();
  }

  Future<void> _uploadTemplateFile() async {
    var picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
      allowMultiple: false,
    );
    if (picked != null) {
      PlatformFile file = picked.files.first;
      String fileContent = utf8.decode(file.bytes as List<int>);
      templateData = fileContent;
      ;
      setState(() {
        templateUploaded = true;
      });
    }
    sendTemplateDataToServer();
  }

  /// webURL [Production] - https://af-chat-bot.fly.dev
  /// devURL [Development] - http://0.0.0.0:8080
  Future<void> sendZDQDataToServer() async {
    if (ZDQUploaded) {
      final url = Uri.parse('$webURL/upload-recipes');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      try {
        ZenDeskQuestionArray zendeskArray =
            ZenDeskQuestionArray.fromJson(jsonDecode(zendeskQData));
        logger.i("Zendesk Objects before sent to server");
        for (var zd in zendeskArray.zendeskArray) {
          logger.i(zd.toString());
        }

        final body = jsonEncode(zendeskArray.toJson());
        logger.i("Zendesk Objects after sent to server");
        logger.d(body);

        final response = await post(url, headers: headers, body: body);
        if (response.statusCode == 200) {
          logger.i('Success ${response.body}');
          setState(() {
            zdqUploadedSuccessfully = true;
            zdqResponseMessage = "ZedDesk Queries Data Uploaded Successfully ✅";
          });
        } else {
          setState(() {
            zdqUploadedSuccessfully = false;
            zdqResponseMessage =
                "ZedDesk Queries Data Failed to upload Successfully ❌\nError: ${response.statusCode} - ${response.reasonPhrase}";
          });
          logger.i('Error: ${response.statusCode} - ${response.reasonPhrase}');
          throw Exception('Failed to get response');
        }
      } on Exception catch (_, e) {
        setState(() {
          zdqUploadedSuccessfully = false;
          zdqResponseMessage =
              "ZedDesk Queries Data Failed to upload Successfully ❌";
        });
      }
    }
  }

  /// webURL [Production] - https://af-chat-bot.fly.dev
  /// devURL [Development] - http://0.0.0.0:8080
  Future<void> sendTemplateDataToServer() async {
    if (templateUploaded) {
      final url = Uri.parse('$webURL/upload-rules');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      final body = jsonEncode(templateData);

      final response = await post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Successful response, handle the result
        logger.i('Success ${response.body}');
      } else {
        // Error response, handle the error
        logger.i('Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to get response');
      }
    }
  }

  Future<void> runTestOnServer() async {
    setState(() {
      isLoading = true; // setting isLoading to true when the test starts
    });

    final url = Uri.parse('$webURL/run-test');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final response = await get(url, headers: headers);
    testResults = response.body;
    if (response.statusCode == 200) {
      // Successful response, handle the result
      logger.i('Success ${response.body}');
    } else {
      // Error response, handle the error
      logger.i(
          'Error runTestOnServer: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to get response in runTestOnServer');
    }

    setState(() {
      didCompleteTest = true;
      isLoading = false; // setting isLoading to false when the test completes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zendesk Query Resolver Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff434446),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              child: FileUploadWidget(
                                title: "Upload Zendesk Query File",
                                onPressed: _uploadZDQFile,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: FileUploadWidget(
                                title: "Upload Template File",
                                onPressed: _uploadTemplateFile,
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: ZDQUploaded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        zendeskQData,
                                        style: const TextStyle(
                                            fontFamily: 'monospace'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: zdqUploadedSuccessfully
                                    ? Text(
                                        zdqResponseMessage,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
                                      )
                                    : Text(
                                        zdqResponseMessage,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .red), // changed this line
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: templateUploaded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        templateData,
                                        style: const TextStyle(
                                            fontFamily: 'monospace'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  "Template Data Uploaded Successfully ✅",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Visibility(
                          visible: templateUploaded && ZDQUploaded,
                          child: Center(
                              child: isLoading
                                  ? JumpingDots(
                                      color: const Color(0xff220D4E),
                                      radius: 10,
                                      numberOfDots: 3,
                                    ) // if loading, show CircularProgressIndicator
                                  : OutlinedButton(
                                      onPressed: () {
                                        runTestOnServer();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.transparent,
                                        side: const BorderSide(
                                            color: Colors.black, width: 1.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Run Test',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    )),
                        ),
                        Visibility(
                          visible: didCompleteTest,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                "💡 Long press on the text will copy the information to your clipboard.",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: GestureDetector(
                                        onLongPress: () {
                                          Clipboard.setData(
                                              ClipboardData(text: testResults));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Copied to clipboard')),
                                          );
                                        },
                                        child: Text(
                                          testResults,
                                          style: const TextStyle(
                                              fontFamily: 'monospace'),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
