import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WandelWijs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'RetroChild', // Set default font family
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Seamlessbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Transform.translate(
              offset: const Offset(0, -100), // Move up by 50 pixels
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Wandelwijs',
                    style: TextStyle(
                      fontFamily: 'RetroChild',
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    'Wandelen wordt een avontuur',
                    style: TextStyle(
                      fontFamily: 'Feijoada',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}