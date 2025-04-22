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
        width: double.infinity,
        height: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.start, // Add this to align all child widgets to the left
                    children: [
                      // Add congratulatory text at the top with larger font
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Proficiat!",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Dynamic message - keep centered
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.category.toLowerCase().contains("dier") || 
                          widget.category.toLowerCase().contains("vogel") || 
                          widget.category.toLowerCase().contains("insect") ?
                            "Je hebt een nieuw dier ontdekt!" :
                            "Je hebt een nieuwe boom/plant ontdekt!",
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Feijoada',
                            color: Color(0xFF4785D2), // Changed to the requested color #4785D2
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Row to contain image on left and points on right
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 180,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.0, // Square aspect ratio
                                  child: Image.file(
                                    File(widget.imageFile.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Points display
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Points row with better alignment
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 40, // Fixed width container for icon
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 36, // Slightly adjusted
                                      ),
                                    ),
                                    Text(
                                      "$_pointsValue punten",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontFamily: 'Feijoada',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Discovery count row with matching alignment
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40, // Same fixed width as above
                                      child: Icon(
                                        widget.category.toLowerCase().contains("dier") || 
                                        widget.category.toLowerCase().contains("vogel") || 
                                        widget.category.toLowerCase().contains("insect") ? 
                                          Icons.pets : Icons.eco,
                                        color: Color(0xFF4785D2),
                                        size: 32, // Slightly adjusted
                                      ),
                                    ),
                                    Text(
                                      widget.category.toLowerCase().contains("dier") || 
                                      widget.category.toLowerCase().contains("vogel") || 
                                      widget.category.toLowerCase().contains("insect") ?
                                        "+ 1 dier" :
                                      widget.category.toLowerCase().contains("boom") ?
                                        "+ 1 boom" : 
                                        "+ 1 plant",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Feijoada',
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4785D2),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Text(
                        widget.speciesName,
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Feijoada',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4785D2), // Changed to the requested color #4785D2
                        ),
                        // No need for textAlign when parent column is left-aligned
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Left-align the description text (removed the Align wrapper)
                      Text(
                        _description,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Feijoada',
                          color: Colors.grey[800],
                        ),
                        // Removed textAlign: TextAlign.center
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Center the button
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            // Return to home screen or discovery collection
                            // TODO: Implement actual navigation or database recording
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18), // Increased padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Ontdekking Opslaan',
                            style: TextStyle(
                              fontFamily: 'Feijoada',
                              fontSize: 22, // Increased from 18
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
