import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      // Create a set of discovered species names for quick lookup
      final Set<String> discoveredSpeciesNames = {};
      for (var doc in userDiscoveries.docs) {
        discoveredSpeciesNames.add(doc['speciesName']);
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

        final Map<String, dynamic> item = {
          'name': name,
          'discovered': discovered,
          'image': imageUrl,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                      fontFamily: 'Feijoada',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4785D2),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Image section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: item['image'] != null 
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
                          fontFamily: 'Feijoada',
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description text
                  Text(
                    item['description'] != '' 
                      ? item['description'] 
                      : 'Geen beschrijving beschikbaar voor deze soort.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Feijoada',
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
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
                        fontFamily: 'Feijoada',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verzamelalbum',
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
        child: _isLoading 
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
                    fontFamily: 'Feijoada',
                    fontSize: 16,
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ChoiceChip(
                              label: Row(
                                children: [
                                  Icon(
                                    _categories[index]['icon'],
                                    color: _currentCategory == index
                                        ? Colors.white
                                        : Colors.green[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${_categories[index]['name']} (${(_categories[index]['items'] as List).length})",
                                    style: TextStyle(
                                      fontFamily: 'Feijoada',
                                      color: _currentCategory == index
                                          ? Colors.white
                                          : Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              selected: _currentCategory == index,
                              selectedColor: Colors.green[700],
                              onSelected: (bool selected) {
                                setState(() {
                                  _currentCategory = selected ? index : _currentCategory;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: (_categories[_currentCategory]['items'] as List).isEmpty
                        ? Center(
                            child: Text(
                              'Geen ${_categories[_currentCategory]['name'].toString().toLowerCase()} gevonden',
                              style: TextStyle(
                                fontFamily: 'Feijoada',
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
                                    // Make discovered items clickable
                                    item['discovered']
                                        ? GestureDetector(
                                            onTap: () => _showSpeciesDetails(
                                              item, 
                                              _categories[_currentCategory]['icon'],
                                            ),
                                            child: (item['image'] != null
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
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(
                                                Icons.lock,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
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
                                          item['name'],
                                          style: const TextStyle(
                                            fontFamily: 'Feijoada',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
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
                                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
