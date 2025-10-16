import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../repository/database_helper.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => LogoutDialogState();
}

class LogoutDialogState extends State<LogoutDialog> {
  bool isPressingNo = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm Logout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: isPressingNo
                ? Icon(Icons.sentiment_satisfied, key: ValueKey('smile'), size: 48, color: Colors.green)
                : Icon(Icons.sentiment_dissatisfied, key: ValueKey('sad'), size: 48, color: Colors.red),
          ),
          SizedBox(height: 16),
          Text('Are you sure you want to logout?'),
        ],
      ),
      actions: [
        GestureDetector(
          onTapDown: (_) => setState(() => isPressingNo = true),
          onTapUp: (_) => setState(() => isPressingNo = false),
          onTapCancel: () => setState(() => isPressingNo = false),
          child: TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        TextButton(
          child: Text('Yes'),
          onPressed: () async {
            await DatabaseHelper().logout();
            /// close the alert dialog
            Navigator.of(context).pop();
            /// close the drawer
            Navigator.of(context).pop();
            context.pushReplacement('/');
          },
        ),
      ],
    );
  }
}
