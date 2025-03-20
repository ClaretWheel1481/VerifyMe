import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showNotification(String content) {
  final snackBar = SnackBar(
    content: Text(content),
    duration: const Duration(milliseconds: 3000),
    behavior: SnackBarBehavior.floating,
  );

  scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
}
