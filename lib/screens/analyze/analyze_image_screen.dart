import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import '../../config/api_config.dart';
import '../verify/verify_discovery_screen.dart';

class AnalyzeImageScreen extends StatefulWidget {
  final XFile imageFile;

  const AnalyzeImageScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<AnalyzeImageScreen> createState() => _AnalyzeImageScreenState();
}

class _AnalyzeImageScreenState extends State<AnalyzeImageScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _result = "";
  String _speciesName = "";
  String _speciesType = "";
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
                  'Tell me what type of plant, tree or animal is in this image. '
                  'If you detected more then 1 object in the image, give me the respons of what you are most certain about. Do not use scientific names, only simple names of species. '
                  'your response should look like this: species - Boom/Plant/Dier '
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
        
        // Parse the result to extract species name and type
        String speciesName = 'Niet herkend';
        String speciesType = '';
        
        if (content != null && content.isNotEmpty) {
          // Extract from format "SpeciesName - Type"
          final lines = content.split('\n');
          if (lines.isNotEmpty) {
            final parts = lines[0].split('-');
            if (parts.length >= 2) {
              speciesName = parts[0].trim();
              speciesType = parts[1].trim();
              print('Parsed species: $speciesName, type: $speciesType');
            } else {
              speciesName = lines[0].trim();
              print('Only species name found: $speciesName');
            }
          }
        }
        
        print('Setting state with: speciesName=$speciesName, type=$speciesType');
        setState(() {
          _isLoading = false;
          _result = content;
          _speciesName = speciesName;
          _speciesType = speciesType;
        });
      } else {
        print('Error response from API');
        setState(() {
          _isLoading = false;
          _result = "Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e, stackTrace) {
      print('Error in _analyzeImage: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _result = "An error occurred: $e";
      });
    }
  }
  
  void _verifyAndContinue() {
    // Navigate to the verify discovery screen with the species information
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerifyDiscoveryScreen(
          speciesName: _speciesName,
          category: _speciesType,
          imageFile: widget.imageFile,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analyseren',
          style: TextStyle(fontFamily: 'Sniglet'),
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
                                        fontFamily: 'Sniglet',
                                        color: Colors.green[700],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(20),
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _speciesName,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontFamily: 'Sniglet',
                                          color: Colors.green[700],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      if (_speciesType.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _speciesType,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Sniglet',
                                              color: Colors.green[800],
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Is deze identificatie correct?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Sniglet',
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: Colors.green[600]!, width: 2),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Text(
                                                'Nee, opnieuw',
                                                style: TextStyle(
                                                  fontFamily: 'Sniglet',
                                                  fontSize: 18,
                                                  color: Colors.green[600],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _verifyAndContinue,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green[600],
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Text(
                                                'Ja, correct',
                                                style: TextStyle(
                                                  fontFamily: 'Sniglet',
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
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
