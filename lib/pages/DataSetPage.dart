import 'dart:convert';

import 'package:af_support_open_ai/constants/app_constants.dart';
import 'package:af_support_open_ai/helper/RecipesList.dart';
import 'package:af_support_open_ai/widgets/FileUploaderWidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';


class DataSetPage extends StatefulWidget {
  @override
  _DataSetPageState createState() => _DataSetPageState();
}

class _DataSetPageState extends State<DataSetPage> {
  List<String> rulesData = [];
  String recipesData = "";
  bool rulesUploaded = false;
  bool recipeUploaded = false;
  List<String> recipesInfo = [];
  List<String> rulesInfo = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _uploadRecipesFile() async {
    var picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
        allowMultiple: false);
    if (picked != null) {
      PlatformFile file = picked.files.first;
      recipesInfo.add("Name: ${file.name}");
      recipesInfo.add("Size: ${file.size}");
      recipesInfo.add("Extension: ${file.extension}");

      String fileContent = utf8.decode(file.bytes as List<int>);
      recipesData = fileContent;
      setState(() {
        recipeUploaded = true;
      });
    }
    sendRecipeDataToServer();
  }

  Future<void> _uploadRulesFile() async {
    var picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
      allowMultiple: false,
    );
    if (picked != null) {
      PlatformFile file = picked.files.first;
      rulesInfo.add("Name: ${file.name}");
      rulesInfo.add("Size: ${file.size}");
      rulesInfo.add("Extension: ${file.extension}");
      String fileContent = utf8.decode(file.bytes as List<int>);
      rulesData = fileContent.split('\n');
      setState(() {
        rulesUploaded = true;
      });
    }
    sendRulesDataToServer();
  }

  /// webURL [Production] - https://af-chat-bot.fly.dev
  /// devURL [Development] - http://0.0.0.0:8080
  Future<void> sendRecipeDataToServer() async {
    if (recipeUploaded) {
      final url = Uri.parse('$webURL/upload-recipes');
      final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

      // Parse the JSON string directly into a Recipe object
      //Recipe recipe = Recipe.fromJson(jsonDecode(recipesData));

      RecipesList recipesList = RecipesList.fromJson(jsonDecode(recipesData));
      final body = jsonEncode(recipesList.toJson());

      // Use jsonEncode to convert the Recipe object to a JSON string
      //final body = jsonEncode(recipe.toJson());

      print(body);
      final response = await post(url, headers: headers, body: body);
      print(response.body);

      if (response.statusCode == 200) {
        // Successful response, handle the result
        print('Success ${response}');
      } else {
        // Error response, handle the error
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to get response');
      }
    }
  }


  /// webURL [Production] - https://af-chat-bot.fly.dev
  /// devURL [Development] - http://0.0.0.0:8080
  Future<void> sendRulesDataToServer() async {
    if (rulesUploaded) {
      final url = Uri.parse('$webURL/upload-rules');
      final headers = {'Content-Type': 'application/json','Accept': 'application/json'};
      final body = jsonEncode(rulesData);

      final response = await post(url, headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        // Successful response, handle the result
        print('Success ${response}');
      } else {
        // Error response, handle the error
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to get response');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Data Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff434446),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FileUploadWidget(
                            title: "Upload Recipes File:",
                            onPressed: _uploadRecipesFile,
                          ),
                          FileUploadWidget(
                            title: "Upload Rules File:",
                            onPressed: _uploadRulesFile,
                          ),
                        ],
                      ),
                      Visibility(
                        visible: recipeUploaded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              "Recipes Data: ${recipesInfo.toString()}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 150,
                              // Set a fixed height or use constraints to limit the box size
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      recipesData,
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: rulesUploaded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              "Rules Data ${rulesInfo.toString()}:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 150,
                              // Set a fixed height or use constraints to limit the box size
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: rulesData.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      rulesData[index],
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
