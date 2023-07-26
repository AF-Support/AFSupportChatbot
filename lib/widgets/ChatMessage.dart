import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatMessage extends StatelessWidget {
  final String role;
  final String message;

  const ChatMessage({required this.role, required this.message});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      message: json['message'] as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForRole(role);
    final bgColor = _getBackgroundColorForRole(role);
    final textColor = _getTextColorForRole(role);
    final copyButtonColor = _getCopyButtonColor(role);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        trailing: InkWell(
          child: Icon(
            Icons.copy,
            color: copyButtonColor,
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: message)).then((value) =>
                Fluttertoast.showToast(
                    msg: "Copied to clipboard.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    textColor: Colors.white,
                    fontSize: 16.0));
          },
        ),
        title: SelectableText(
          message,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  IconData _getIconForRole(String role) {
    switch (role) {
      case 'user':
        return Icons.question_mark;
      case 'assistant':
        return Icons.question_answer;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getCopyButtonColor(String role) {
    switch (role) {
      case 'user':
        return Colors.white;
      case 'assistant':
        return Colors.grey[800]!;
      case 'error':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  Color _getBackgroundColorForRole(String role) {
    switch (role) {
      case 'user':
        return Colors.grey[800]!;
      case 'assistant':
        return Colors.grey[300]!;
      case 'error':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  Color _getTextColorForRole(String role) {
    switch (role) {
      case 'user':
        return Colors.white;
      case 'assistant':
        return Colors.black;
      case 'error':
        return Colors.white;
      default:
        return Colors.black;
    }
  }
}

