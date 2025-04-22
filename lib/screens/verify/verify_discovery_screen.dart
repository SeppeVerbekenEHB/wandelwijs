import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifyDiscoveryScreen extends StatefulWidget {
  final String speciesName;
  final String category;
  final XFile imageFile;

  const VerifyDiscoveryScreen({
    Key? key,
    required this.speciesName,
    required this.category,
    required this.imageFile,
  }) : super(key: key);

  @override
  State<VerifyDiscoveryScreen> createState() => _VerifyDiscoveryScreenState();
}

class _VerifyDiscoveryScreenState extends State<VerifyDiscoveryScreen> {
  bool _isLoading = true;
  int _pointsValue = 0;
  String _description = "";

  @override
  void initState() {
    super.initState();
    _checkSpeciesInDatabase();
  }

  Future<void> _checkSpeciesInDatabase() async {
  try {
    // Query Firestore for the species
    final speciesDoc = await FirebaseFirestore.instance
        .collection('species')
        .where('name', isEqualTo: widget.speciesName)
        .limit(1)
        .get();

    if (speciesDoc.docs.isNotEmpty) {
      // Species found in database
      final data = speciesDoc.docs.first.data();
      setState(() {
        _isLoading = false;
        _pointsValue = data['points'] ?? 5;
        _description = data['description'] ?? 
          "Dit is een beschrijving van ${widget.speciesName}. "
          "Meer details over deze soort worden binnenkort toegevoegd.";
      });
    } else {
      // Species not found in database - use default values
      setState(() {
        _isLoading = false;
        _pointsValue = 5; // Default points
        _description = "Dit is een ${widget.speciesName}. "
            "Deze soort staat nog niet in onze database met gedetailleerde informatie.";
      });
    }
  } catch (e) {
    print('Error querying database: $e');
    setState(() {
      _isLoading = false;
      _pointsValue = 5;
      _description = "Er is een fout opgetreden bij het ophalen van informatie over ${widget.speciesName}.";
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ontdekking Verifiëren',
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
            child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.green[700],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Even geduld, we verifiëren je ontdekking...',
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Display the species image in a smaller size
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                child: Image.file(
                                  File(widget.imageFile.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.speciesName,
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: 'Feijoada',
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            if (widget.category.isNotEmpty)
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
                                  widget.category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Feijoada',
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "$_pointsValue punten",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Feijoada',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _description,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Feijoada',
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          // Return to home screen or discovery collection
                          // TODO: Implement actual navigation or database recording
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Ontdekking Opslaan',
                          style: TextStyle(
                            fontFamily: 'Feijoada',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
