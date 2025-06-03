import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/auth.dart';
import '../missions/missions_screen.dart';
import '../album/album_screen.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _discoveryCount = 0;
  int _completedMissionsCount = 0;
  String _selectedProfilePicture = 'assets/images/Cat_Profile.png';
  int _totalPoints = 0;
  final Map<String, int> _profilePicturePoints = {
    'assets/images/Cat_Profile.png': 0,
    'assets/images/Dino_Profile.png': 100,
    'assets/images/Flower_Profile.png': 500,
    'assets/images/Robot_Profile.png': 1000,
  };

  @override
  void initState() {
    super.initState();
    _loadDiscoveryCount();
    _loadCompletedMissionsCount();
    _loadProfilePicture();
    _loadTotalPoints();
  }

  Future<void> _loadDiscoveryCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final discoveries = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('discoveries')
          .get();

      // Create a set of unique species names
      final uniqueSpecies = discoveries.docs
          .map((doc) => doc.data()['speciesName'] as String)
          .toSet();

      setState(() {
        _discoveryCount = uniqueSpecies.length;
      });
    }
  }

  Future<void> _loadCompletedMissionsCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final missions = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('missions')
          .where('completed', isEqualTo: true)
          .get();

      setState(() {
        _completedMissionsCount = missions.docs.length;
      });
    }
  }

  Future<void> _loadProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      setState(() {
        _selectedProfilePicture = userData.data()?['profilePicture'] ?? 'assets/images/Cat_Profile.png';
      });
    }
  }

  Future<void> _updateProfilePicture(String picturePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'profilePicture': picturePath}, SetOptions(merge: true));
      
      setState(() {
        _selectedProfilePicture = picturePath;
      });
    }
  }

  Future<void> _loadTotalPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      setState(() {
        _totalPoints = userData.data()?['totalPoints'] ?? 0;
      });
    }
  }

  void _showProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              const Text('Kies een profielfoto', 
                style: TextStyle(fontFamily: 'Sniglet'),
              ),
              const SizedBox(height: 8),
              Text(
                'Je hebt $_totalPoints punten',
                style: const TextStyle(
                  fontFamily: 'Sniglet',
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _profilePicturePoints.entries.map((entry) {
                bool isLocked = entry.value > _totalPoints;
                return _buildProfilePictureOption(
                  entry.key,
                  _getProfileName(entry.key),
                  isLocked,
                  entry.value,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  String _getProfileName(String path) {
    switch (path) {
      case 'assets/images/Cat_Profile.png':
        return 'Kat';
      case 'assets/images/Dino_Profile.png':
        return 'Dino (100 punten)';
      case 'assets/images/Flower_Profile.png':
        return 'Bloem (500 punten)';
      case 'assets/images/Robot_Profile.png':
        return 'Robot (1000 punten)';
      default:
        return '';
    }
  }

  Widget _buildProfilePictureOption(String imagePath, String name, bool isLocked, int points) {
    return ListTile(
      leading: Stack(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(isLocked ? [
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 1, 0,
              ] : [
                1, 0, 0, 0, 0,
                0, 1, 0, 0, 0,
                0, 0, 1, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: Image.asset(imagePath),
            ),
          ),
          if (isLocked)
            const Positioned(
              right: 0,
              bottom: 0,
              child: Icon(Icons.lock, color: Colors.grey, size: 20),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          fontFamily: 'Sniglet',
          color: isLocked ? Colors.grey : Colors.black,
        ),
      ),
      onTap: isLocked ? null : () {
        _updateProfilePicture(imagePath);
        Navigator.pop(context);
      },
    );
  }

  User? _getUser() {
    return Auth().currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUser();
    
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
          leading: null,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _showProfilePictureDialog,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(_selectedProfilePicture),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.displayName ?? 'Wandelaar',
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Sniglet',
                      ),
                    ),
                    Text(
                      user?.email ?? 'Geen e-mail',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Sniglet',
                      ),
                    ),
                    const SizedBox(height: 30),
                    ListTile(
                      leading: const Icon(Icons.emoji_events, color: Colors.green),
                      title: const Text('Voltooide Missies', style: TextStyle(fontFamily: 'Sniglet')),
                      trailing: Text(
                        '$_completedMissionsCount',
                        style: const TextStyle(fontFamily: 'Sniglet')
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_album, color: Colors.green),
                      title: const Text('Ontdekkingen', style: TextStyle(fontFamily: 'Sniglet')),
                      trailing: Text(
                        '$_discoveryCount',
                        style: const TextStyle(fontFamily: 'Sniglet')
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AlbumScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                    elevation: 5,
                  ),
                  child: Icon(
                    Icons.photo_album_rounded,
                    size: 36,
                    color: Colors.green[700],
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
