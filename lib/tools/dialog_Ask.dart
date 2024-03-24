import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogAsk {
  static void show({required BuildContext context, required String title, required Widget content, required Function onYes, required Function onNo}) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: content,
          actions: [
            CupertinoButton(
              child: const Text('No'), 
              onPressed: () {
                onNo();
                Navigator.of(context).pop();
              }
            ),
            CupertinoButton(
              child: const Text('Yes'),
              onPressed: () {
                onYes();
                Navigator.of(context).pop();
              }
            ),
          ],
        );
      }
    );
  }

  static void simple({required BuildContext context, required String title, required Widget content, required Function onOk}) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: content,
          actions: [
            CupertinoButton(
              child: const Text('Aceptar'), 
              onPressed: () {
                onOk();
                Navigator.of(context).pop();
              }
            ),
          ],
        );
      }
    );
  }
}