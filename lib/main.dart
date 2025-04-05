import 'package:flutter/material.dart';

void main() {
  runApp(WandelWijsApp());
}

class WandelWijsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WandelWijs',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to WandelWijs'),
      ),
      body: Center(
        child: Text(
          'Your hiking companion app 🌲🚶‍♂️',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
