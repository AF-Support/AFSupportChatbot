import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/MyTextField.dart';

class DataSetPage extends StatefulWidget {
  @override
  _DataSetPageState createState() => _DataSetPageState();
}

class _DataSetPageState extends State<DataSetPage> {
  late TextEditingController _promptController;
  late TextEditingController _completionController;

  String _uploadedFileName = '';
  String _uploadedFileContent = '';

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _completionController = TextEditingController();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  Future<void> _uploadFile() async {}

  void _clearFile() {
    setState(() {
      _uploadedFileName = '';
      _uploadedFileContent = '';
    });
  }

  void _saveData() {
    String prompt = _promptController.text;
    String completion = _completionController.text;

    //TODO Upload data as a fine tune

    _promptController.clear();
    _completionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Set Page',
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
                        children: [
                          const Text(
                            'Upload a File:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _uploadFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Choose File',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (_uploadedFileName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Uploaded File:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  Text('Name: $_uploadedFileName'),
                                  const Text('Content:'),
                                  Text(
                                    _uploadedFileContent ?? '',
                                    style: const TextStyle(
                                        fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _clearFile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'Clear File',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter Data Manually:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                MyTextField(
                  controller: _promptController,
                  hintText: 'Prompt',
                ),
                const SizedBox(height: 8),
                MyTextField(
                  controller: _completionController,
                  hintText: 'Completion',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Upload Data',
                    style: TextStyle(color: Colors.white),
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
