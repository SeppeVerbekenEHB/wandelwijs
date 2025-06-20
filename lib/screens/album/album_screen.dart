import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../scan/scan_screen.dart';
import '../missions/missions_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<Map<String, dynamic>> _categories = [
    {
      'name': 'Bomen',
      'icon': Icons.park,
      'items': [],
    },
    {
      'name': 'Dieren',
      'icon': Icons.pets,
      'items': [],
    },
    {
      'name': 'Planten',
      'icon': Icons.local_florist,
      'items': [],
    },
  ];

  int _currentCategory = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSpeciesData();
  }

  Future<void> _loadSpeciesData() async {
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _error = "User not logged in";
          _isLoading = false;
        });
        return;
      }

      // Get all species from Firestore
      final QuerySnapshot speciesSnapshot = await FirebaseFirestore.instance
          .collection('species')
          .get();

      // Get user discoveries to track which species are discovered
      final userDiscoveries = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('discoveries')
          .get();

      // Create a map of discovered species with their image paths
      final Map<String, String> discoveredSpeciesImages = {};
      final Set<String> discoveredSpeciesNames = {};
      
      for (var doc in userDiscoveries.docs) {
        final data = doc.data();
        final speciesName = data['speciesName'] as String;
        final imagePath = data['localImagePath'] as String?;
        
        discoveredSpeciesNames.add(speciesName);
        
        // Only store the image path if it exists and we don't already have one for this species
        // (this keeps the first image a user captured of each species)
        if (imagePath != null && !discoveredSpeciesImages.containsKey(speciesName)) {
          discoveredSpeciesImages[speciesName] = imagePath;
        }
      }

      // Clear existing items
      for (var category in _categories) {
        category['items'] = [];
      }

      // Categorize each species based on its category field
      for (var doc in speciesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String name = data['name'] ?? 'Unknown';
        final String category = data['category'] ?? 'Unknown';
        final String? imageUrl = data['imageUrl'];
        final bool discovered = discoveredSpeciesNames.contains(name);
        final String? discoveredImagePath = discoveredSpeciesImages[name];

        final Map<String, dynamic> item = {
          'name': name,
          'discovered': discovered,
          'image': imageUrl,
          'discoveredImagePath': discoveredImagePath,
          'description': data['description'] ?? '',
          'points': data['points'] ?? 5,
        };

        // Add to appropriate category
        if (category == 'Boom') {
          _categories[0]['items'].add(item);
        } else if (category == 'Dier') {
          _categories[1]['items'].add(item);
        } else if (category == 'Plant') {
          _categories[2]['items'].add(item);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Method to show species details in a popup dialog
  void _showSpeciesDetails(Map<String, dynamic> item, IconData categoryIcon) {
    bool isExpanded = false;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final description = item['description'] != '' 
              ? item['description'] 
              : 'Geen beschrijving beschikbaar voor deze soort.';
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Species name header
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Sniglet',
                          color: Color(0xFF4785D2),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Image section - prioritize user's discovered image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: item['discoveredImagePath'] != null
                          ? Image.file(
                              File(item['discoveredImagePath']),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to database image if file not found
                                return item['image'] != null 
                                  ? Image.network(
                                      item['image'],
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          color: Colors.green[100],
                                          child: Icon(
                                            categoryIcon,
                                            size: 80,
                                            color: Colors.green[700],
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      height: 200,
                                      color: Colors.green[100],
                                      child: Icon(
                                        categoryIcon,
                                        size: 80,
                                        color: Colors.green[700],
                                      ),
                                    );
                              },
                            )
                          : item['image'] != null 
                            ? Image.network(
                                item['image'],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.green[100],
                                    child: Icon(
                                      categoryIcon,
                                      size: 80,
                                      color: Colors.green[700],
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 200,
                                color: Colors.green[100],
                                child: Icon(
                                  categoryIcon,
                                  size: 80,
                                  color: Colors.green[700],
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Points display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${item['points']} punten",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Sniglet',
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: isExpanded ? 320 : 80,
                            ),
                            child: SingleChildScrollView(
                              physics: isExpanded 
                                ? const AlwaysScrollableScrollPhysics() 
                                : const NeverScrollableScrollPhysics(),
                              child: Text(
                                description,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Sniglet',
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.left,
                                maxLines: isExpanded ? null : 4,
                                overflow: isExpanded ? TextOverflow.visible : TextOverflow.fade,
                              ),
                            ),
                          ),
                          if (description.length > 100)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Text(
                                isExpanded ? 'Minder' : 'Meer',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontFamily: 'Sniglet',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Close button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Sluiten',
                          style: TextStyle(
                            fontFamily: 'Sniglet',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Seamlessbackground.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.green[700],
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ),
          ),
        ),
        body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green[700],
              ),
            )
          : _error != null 
            ? Center(
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Sniglet',
                    fontSize: 16,
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 8.0),
                    child: Text(
                      'Album',
                      style: TextStyle(
                        fontFamily: 'CherryBombOne',
                        fontSize: 46,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_categories.length, (index) {
                        final isSelected = _currentCategory == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentCategory = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green[700] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _categories[index]['icon'],
                              color: isSelected ? Colors.white : Colors.green[700],
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: (_categories[_currentCategory]['items'] as List).isEmpty
                        ? Center(
                            child: Text(
                              'Geen ${_categories[_currentCategory]['name'].toString().toLowerCase()} gevonden',
                              style: TextStyle(
                                fontFamily: 'Sniglet',
                                fontSize: 18,
                                color: Colors.green[700],
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: (_categories[_currentCategory]['items'] as List).length,
                            itemBuilder: (context, index) {
                              final item = _categories[_currentCategory]['items'][index];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    item['discovered']
                                        ? GestureDetector(
                                            onTap: () => _showSpeciesDetails(
                                              item, 
                                              _categories[_currentCategory]['icon'],
                                            ),
                                            child: (item['discoveredImagePath'] != null
                                                ? Image.file(
                                                    File(item['discoveredImagePath']),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      // Fallback to database image or icon
                                                      return item['image'] != null 
                                                        ? Image.network(
                                                            item['image'],
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return Container(
                                                                color: Colors.green[100],
                                                                child: Icon(
                                                                  _categories[_currentCategory]['icon'],
                                                                  size: 50,
                                                                  color: Colors.green[700],
                                                                ),
                                                              );
                                                            },
                                                            loadingBuilder: (context, child, loadingProgress) {
                                                              if (loadingProgress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  color: Colors.green[700],
                                                                  value: loadingProgress.expectedTotalBytes != null
                                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : Container(
                                                            color: Colors.green[100],
                                                            child: Icon(
                                                              _categories[_currentCategory]['icon'],
                                                              size: 50,
                                                              color: Colors.green[700],
                                                            ),
                                                          );
                                                    },
                                                  )
                                                : item['image'] != null
                                                    ? Image.network(
                                                        item['image'],
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            color: Colors.green[100],
                                                            child: Icon(
                                                              _categories[_currentCategory]['icon'],
                                                              size: 50,
                                                              color: Colors.green[700],
                                                            ),
                                                          );
                                                        },
                                                        loadingBuilder: (context, child, loadingProgress) {
                                                          if (loadingProgress == null) return child;
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              color: Colors.green[700],
                                                              value: loadingProgress.expectedTotalBytes != null
                                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                  : null,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(
                                                        color: Colors.green[100],
                                                        child: Icon(
                                                          _categories[_currentCategory]['icon'],
                                                          size: 50,
                                                          color: Colors.green[700],
                                                        ),
                                                      ))
                                        )
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.grey[200]!, Colors.grey[400]!],
                                              ),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  _categories[_currentCategory]['icon'],
                                                  size: 80,
                                                  color: Colors.grey[600]!.withOpacity(0.4),
                                                ),
                                                // Small lock icon in the corner
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[600]!.withOpacity(0.7),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.lock,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        color: Colors.black54,
                                        child: Text(
                                          item['discovered'] 
                                            ? item['name'] 
                                            : _currentCategory == 1 
                                                ? "Onbekend ${_getCategoryInDutch(_currentCategory)}" 
                                                : "Onbekende ${_getCategoryInDutch(_currentCategory)}",
                                          style: const TextStyle(
                                            fontFamily: 'Sniglet',
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    if (item['discovered'])
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.green[700],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            "${item['points']}pt",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
        floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(24),
            shape: const CircleBorder(),
            elevation: 8,
          ),
          child: Icon(
            Icons.home_rounded,
            size: 52,
            color: Colors.green[700],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.green[700]!.withOpacity(0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),  // Changed padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Missions button (left)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MissionsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                    elevation: 5,
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    size: 36,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 80),
                // Album button (right)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                    elevation: 5,
                  ),
                  child: const Icon(
                    Icons.photo_album_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to get singular Dutch name for category
  String _getCategoryInDutch(int categoryIndex) {
    switch(categoryIndex) {
      case 0: return "Boom";
      case 1: return "Dier";
      case 2: return "Plant";
      default: return "";
    }
  }
}
