import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../screens/auth.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/missions/missions_screen.dart';
import '../../screens/album/album_screen.dart';
import '../../screens/scan/scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  User? _getUser() {
    return Auth().currentUser;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await Auth().signOut();
      // Navigate to login page after successful sign out
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget _userUid() {
    final user = _getUser();
    return Text(user?.email ?? 'User email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context),
          ),
        ],
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
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Transform.translate(
                  offset: const Offset(0, -150),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Wandelwijs',
                        style: TextStyle(
                          fontFamily: 'RetroChild',
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 0),
                      const Text(
                        'Wandelen wordt een avontuur',
                        style: TextStyle(
                          fontFamily: 'Sniglet',
                          fontSize: 18,
                          fontWeight: FontWeight.normal,  // Changed to normal weight
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Missies button (left)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MissionsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.all(16),
                        shape: const CircleBorder(),
                        elevation: 5,
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    // Profile button (center)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.all(16),
                        shape: const CircleBorder(),
                        elevation: 5,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    // Album button (right)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AlbumScreen()),
                        );
                      },
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
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 200),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.all(24), // Increased padding
            shape: const CircleBorder(),
            elevation: 8,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 52, // Increased icon size
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
