import 'package:flutter/material.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.title});

  final String title;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
    );
  }
}
