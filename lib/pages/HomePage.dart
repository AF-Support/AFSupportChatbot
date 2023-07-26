import 'package:flutter/material.dart';
import 'DataSetPage.dart';
import 'package:af_support_open_ai/pages/ChatPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedOption = 'Home';

  final Map<String, Widget> _pages = {
    'Home': ChatPage(),
    'Upload Data Set': DataSetPage(),
  };

  Widget _buildSidebarOption(String option) {
    bool isSelected = _selectedOption == option;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        title: Text(
          option,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
        ),
        selected: isSelected,
        onTap: () {
          setState(() {
            _selectedOption = option;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300,
            color: const Color(0xff220D4E), // Sidebar background color
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const Divider(),
                for (String option in _pages.keys) _buildSidebarOption(option),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _pages[_selectedOption]!,
          ),
        ],
      ),
    );
  }
}
