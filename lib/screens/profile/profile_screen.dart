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

  @override
  void initState() {
    super.initState();
    _loadDiscoveryCount();
    _loadCompletedMissionsCount();
    _loadProfilePicture();
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

  void _showProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kies een profielfoto', 
            style: TextStyle(fontFamily: 'Sniglet'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfilePictureOption('assets/images/Cat_Profile.png', 'Kat'),
                _buildProfilePictureOption('assets/images/Dino_Profile.png', 'Dino'),
                _buildProfilePictureOption('assets/images/Flower_Profile.png', 'Bloem'),
                _buildProfilePictureOption('assets/images/Robot_Profile.png', 'Robot'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePictureOption(String imagePath, String name) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imagePath),
      ),
      title: Text(name, style: const TextStyle(fontFamily: 'Sniglet')),
      onTap: () {
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(_selectedProfilePicture),
                        backgroundColor: Colors.green,
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
