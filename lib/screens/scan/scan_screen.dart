import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import '../analyze/analyze_image_screen.dart';

List<CameraDescription> cameras = [];

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  bool _isScanning = false;
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;
  XFile? _capturedImage; // Variable to store the captured image

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Reset camera initialization status
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
      });
    }
    
    // Dispose of previous controller if exists
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    if (cameras.isEmpty) {
      try {
        cameras = await availableCameras();
        debugPrint('Available cameras: ${cameras.length}');
        for (var i = 0; i < cameras.length; i++) {
          debugPrint('Camera $i: ${cameras[i].name}, ${cameras[i].lensDirection}');
        }
      } catch (e) {
        debugPrint('Error getting cameras: $e');
        return;
      }
    }

    if (cameras.isEmpty) {
      debugPrint('No cameras available');
      return;
    }

    try {
      // Select the appropriate camera based on availability
      CameraDescription selectedCamera = cameras[0]; // Default to first camera
      
      // On real devices, prefer the back camera for nature scanning
      // This will be skipped on emulators that typically only have one webcam
      if (cameras.length > 1) {
        for (var camera in cameras) {
          if (camera.lensDirection == CameraLensDirection.back) {
            selectedCamera = camera;
            break;
          }
        }
      }
      
      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg, // Works on most devices
      );

      _initializeControllerFuture = _cameraController!.initialize();
      
      await _initializeControllerFuture;
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          debugPrint('Camera initialized successfully: ${selectedCamera.name}');
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      // Show error in UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialisatie mislukt: $e'))
        );
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      // Ensure camera is initialized
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera is niet gereed')),
        );
        return;
      }

      // Take the picture
      final XFile image = await _cameraController!.takePicture();
      debugPrint('Image captured: ${image.path}');
      
      // Set the captured image
      setState(() {
        _capturedImage = image;
      });
      
      return;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij het nemen van een foto: $e')),
      );
    }
  }

  void _toggleScan() {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera is niet beschikbaar')),
      );
      return;
    }
    
    setState(() {
      _isScanning = !_isScanning;
    });
    
    if (_isScanning) {
      // Take picture first, then continue with process
      _takePicture().then((_) {
        // Add a small delay to show scanning is happening
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
            
            if (_capturedImage != null) {
              // Navigate to analyze screen instead of showing dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyzeImageScreen(imageFile: _capturedImage!),
                ),
              );
            } else {
              // Show error if image capture failed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geen afbeelding vastgelegd. Probeer opnieuw.')),
              );
            }
          }
        });
      });
    }
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              cameras.isEmpty ? 'Geen camera gevonden' : 'Camera initialiseren...',
              style: const TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: _initializeCamera,
              child: const Text('Opnieuw proberen', 
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    // Make camera fill the entire container without any borders or margins
    return CameraPreview(_cameraController!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scannen',
          style: TextStyle(fontFamily: 'Sniglet'),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          // Camera fills the entire screen
          Positioned.fill(
            child: _buildCameraPreview(),
          ),
          
          // Semi-transparent overlay (optional, for better text readability)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          
          // Content that floats over the camera
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(),
                  // Text floats above the camera
                  const Text(
                    'Richt je camera op een voorwerp in de natuur',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Sniglet',
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Button floats above the camera
                  ElevatedButton(
                    onPressed: _isCameraInitialized ? _toggleScan : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      _isScanning ? 'STOP' : 'START SCAN',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
