import 'package:flutter/material.dart';

class Snak {
  static Future<void> show({required BuildContext context, required String message, TextStyle? style, Color? backcolor, SnackBarAction? snackBarAction, Duration? duration}) async {
    var tcolor = backcolor??Theme.of(context).primaryColor;
    var tstyle = style??Theme.of(context).textTheme.bodyMedium;

    final snackBar = duration!=null
    ? SnackBar(
        content: Text(message, style: tstyle),
        action: snackBarAction,
        duration: duration,
        backgroundColor: tcolor,
      )
    : SnackBar(
        content: Text(message, style: tstyle),
        action: snackBarAction,
        backgroundColor: tcolor,
      );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}