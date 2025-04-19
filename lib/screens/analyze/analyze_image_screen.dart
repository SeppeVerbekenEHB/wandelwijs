import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import '../../config/api_config.dart';

class AnalyzeImageScreen extends StatefulWidget {
  final XFile imageFile;

  const AnalyzeImageScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<AnalyzeImageScreen> createState() => _AnalyzeImageScreenState();
}

class _AnalyzeImageScreenState extends State<AnalyzeImageScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _result = "";
  String _detectedObject = "";
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _analyzeImage();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _analyzeImage() async {
    try {
      final apiKey = ApiConfig.openaiApiKey;
      
      
      // Convert image file to base64
      final bytes = await widget.imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a nature identification assistant that helps identify plants, trees, or animals in images. '
                  'Tell me what type of plant, tree or animal is in this image.'
                    'If you detected more then 1 object in the image, give me the respons of what you are most certain about. Do not use scientific names, only simple names of species.'
                    'your response should ook like this: species - tree/plant/animal'
                    'the species name shoudl be in common dutch names, not in latin or english. '
                    'If you cannot identify it with certainty, just say "Niet herkend".'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'What plant, tree or animal is in this image?'
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  }
                }
              ]
            }
          ],
          'max_tokens': 300,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        
        // Parse the result to extract the name of the detected object
        String detectedObject = 'Onbekend object';
        if (content != null && content.isNotEmpty) {
          // Assuming the first line contains the name
          final lines = content.split('\n');
          if (lines.isNotEmpty) {
            detectedObject = lines[0].replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
            // If it's longer than a typical name, take just the first few words
            if (detectedObject.split(' ').length > 3) {
              detectedObject = detectedObject.split(' ').take(2).join(' ');
            }
          }
        }
        
        setState(() {
          _isLoading = false;
          _result = content;
          _detectedObject = detectedObject;
        });
      } else {
        setState(() {
          _isLoading = false;
          _result = "Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = "An error occurred: $e";
      });
      print("Error details: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analyseren',
          style: TextStyle(fontFamily: 'Feijoada', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Seamlessbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                              ),
                            ),
                            child: Image.file(
                              File(widget.imageFile.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        _isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  children: [
                                    RotationTransition(
                                      turns: _animationController,
                                      child: Image.asset(
                                        'assets/images/Seamlessbackground.png',
                                        height: 60,
                                        width: 60,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Even geduld, we analyseren de afbeelding...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Feijoada',
                                        color: Colors.green[700],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _detectedObject,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontFamily: 'Feijoada',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _result,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Feijoada',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Terug',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Feijoada',
                    ),
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
