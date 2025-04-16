import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;
    });
    
    if (_isScanning) {
      // Simulate scanning process
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          _showScanResult();
        }
      });
    }
  }
  
  void _showScanResult() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Gevonden!',
            style: TextStyle(fontFamily: 'Feijoada', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/Seamlessbackground.png',
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Je hebt een Eik gevonden!',
                style: TextStyle(fontFamily: 'Feijoada'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deze is toegevoegd aan je album.',
                style: TextStyle(fontFamily: 'Feijoada', fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.green[700],
                  fontFamily: 'Feijoada',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scannen',
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(24),
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isScanning ? Colors.green : Colors.white,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: _isScanning
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 80,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Richt je camera op een voorwerp in de natuur',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Feijoada',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _toggleScan,
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
            ],
          ),
        ),
      ),
    );
  }
}
