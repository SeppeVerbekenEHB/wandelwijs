import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/mission_service.dart';

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
  bool _isSaving = false;
  int _pointsValue = 0;
  String _description = "";
  bool _isNewDiscovery = true; // New state variable to track if this is a new discovery
  final MissionService _missionService = MissionService();

  @override
  void initState() {
    super.initState();
    _checkSpeciesInDatabase();
  }

  Future<void> _checkSpeciesInDatabase() async {
    try {
      // Convert the search term to lowercase for case-insensitive comparison
      String searchName = widget.speciesName.toLowerCase();
      
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception("User not logged in");
      }
      
      // Check if user has already discovered this species
      final previousDiscoveries = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('discoveries')
          .where('speciesName', isEqualTo: widget.speciesName)
          .get();
      
      bool alreadyDiscovered = previousDiscoveries.docs.isNotEmpty;
      
      // Query Firestore for species data
      final QuerySnapshot speciesSnapshot = await FirebaseFirestore.instance
          .collection('species')
          .get();
      
      // Find matching species using partial match (contains) and case insensitive
      final matchingDocs = speciesSnapshot.docs.where((doc) {
        // Get the database species name and convert to lowercase
        String dbSpeciesName = doc['name'].toString().toLowerCase();
        
        // Check if either string contains the other
        return dbSpeciesName.contains(searchName) || searchName.contains(dbSpeciesName);
      }).toList();
      
      if (matchingDocs.isNotEmpty) {
        // Species found in database
        final data = matchingDocs.first.data() as Map<String, dynamic>;
        
        // Calculate points - if already discovered, they get 1/4 of the points
        int fullPoints = data['points'] ?? 5;
        int adjustedPoints = alreadyDiscovered ? (fullPoints / 4).round() : fullPoints;
        
        setState(() {
          _isLoading = false;
          _pointsValue = adjustedPoints;
          _description = data['description'] ?? 
            "Dit is een beschrijving van ${widget.speciesName}. "
            "Meer details over deze soort worden binnenkort toegevoegd.";
          _isNewDiscovery = !alreadyDiscovered;
        });
      } else {
        // Species not found in database - use default values
        // Still check if user already discovered it
        int adjustedPoints = alreadyDiscovered ? 1 : 5; // 1/4 of default 5 = ~1
        
        setState(() {
          _isLoading = false;
          _pointsValue = adjustedPoints;
          _description = "Dit is een ${widget.speciesName}. "
              "Deze soort staat nog niet in onze database met gedetailleerde informatie.";
          _isNewDiscovery = !alreadyDiscovered;
        });
      }
    } catch (e) {
      print('Error querying database: $e');
      setState(() {
        _isLoading = false;
        _pointsValue = 5;
        _description = "Er is een fout opgetreden bij het ophalen van informatie over ${widget.speciesName}.";
        // Assuming it's new if we can't check
        _isNewDiscovery = true;
      });
    }
  }

  // Function to save discovery to Firestore without Firebase Storage
  Future<void> _saveDiscovery() async {
    if (_isSaving) return; // Prevent multiple saves
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception("User not logged in");
      }
      
      // Only add the discovery to Firestore if it's new
      if (_isNewDiscovery) {
        // Create discovery data - storing the local image path temporarily
        final discoveryData = {
          'speciesName': widget.speciesName,
          'category': widget.category,
          'description': _description,
          'points': _pointsValue,
          'localImagePath': widget.imageFile.path, // Store local path instead of URL
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
        };
        
        // Add to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('discoveries')
            .add(discoveryData);
      }
      
      // Update user points in a transaction - do this regardless of whether it's a new discovery
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get user document
        DocumentSnapshot userSnapshot = await transaction.get(
          FirebaseFirestore.instance.collection('users').doc(user.uid)
        );
        
        // Check if user document exists
        if (!userSnapshot.exists) {
          // Create user document if it doesn't exist
          transaction.set(
            FirebaseFirestore.instance.collection('users').doc(user.uid), 
            {
              'totalPoints': _pointsValue,
              'discoveriesCount': _isNewDiscovery ? 1 : 0  // Only increment count if it's new
            }
          );
        } else {
          // User exists, update points and only increment discoveries count if it's new
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
          int currentPoints = userData['totalPoints'] ?? 0;
          int currentDiscoveries = userData['discoveriesCount'] ?? 0;
          
          transaction.update(
            FirebaseFirestore.instance.collection('users').doc(user.uid), 
            {
              'totalPoints': currentPoints + _pointsValue,
              'discoveriesCount': _isNewDiscovery ? currentDiscoveries + 1 : currentDiscoveries
            }
          );
        }
      });
      
      // Update missions if this is a new discovery
      if (_isNewDiscovery) {
        await _missionService.updateMissionsForDiscovery(widget.category, widget.speciesName);
      }
      
      // Show success message with different text based on whether it's a new discovery
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isNewDiscovery 
                ? 'Nieuwe ontdekking succesvol opgeslagen!'
                : 'Je hebt ${_pointsValue} punten ontvangen!',
              style: const TextStyle(
                fontFamily: 'Sniglet', // Changed font to Sniglet
              ),
            ),
            backgroundColor: Colors.green[700],
          )
        );
      }
      
      // Return to home screen
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Error saving discovery: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij opslaan van ontdekking: $e'),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ontdekking Verifiëren',
          style: TextStyle(fontFamily: 'Sniglet'),
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
                          fontFamily: 'Sniglet',
                          color: Colors.green[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _isSaving 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.green[700],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Je ontdekking wordt opgeslagen...',
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
                          _isNewDiscovery
                              ? (widget.category.toLowerCase().contains("dier") || 
                                 widget.category.toLowerCase().contains("vogel") || 
                                 widget.category.toLowerCase().contains("insect")
                                     ? "Je hebt een nieuw dier ontdekt!"
                                     : "Je hebt een nieuwe boom/plant ontdekt!")
                              : "Je hebt deze soort opnieuw gevonden!",
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Sniglet',
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
                                        fontFamily: 'Sniglet',
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Discovery count row with matching alignment
                                if (_isNewDiscovery)
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
                                          fontFamily: 'Sniglet',
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
                          fontFamily: 'Sniglet',
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
                          fontFamily: 'Sniglet',
                          color: Colors.grey[800],
                        ),
                        // Removed textAlign: TextAlign.center
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Center the button
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: _saveDiscovery, // Changed from navigation to saving function
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
                              fontFamily: 'Sniglet',
                              fontSize: 22, // Increased from 18
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
