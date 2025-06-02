import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../screens/auth.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/missions/missions_screen.dart';
import '../../screens/album/album_screen.dart';
import '../../screens/scan/scan_screen.dart';
import '../../services/mission_service.dart';
import '../../models/mission_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  User? _getUser() {
    return Auth().currentUser;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await Auth().signOut();
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
    final MissionService _missionService = MissionService();

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
                icon: const Icon(Icons.person, color: Colors.white ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => signOut(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Decorative images
            Positioned(
              top: 80,
              left: -8,
              child: Transform.rotate(
                angle: 0.42, // ~15 degrees
                child: Image.asset('assets/images/Mushroom.png', width: 50),
              ),
            ),
            Positioned(
              top: 250,
              right: 40,
              child: Image.asset('assets/images/Flower.png', width: 40),
            ),
            Positioned(
              bottom: 120,
              left: 370,
              child: Transform.rotate(
                angle: -1.3, // ~15 degrees
                child: Image.asset('assets/images/Mushroom.png', width: 50),
              ),
            ),
            Positioned(
              bottom: 190,
              left: -10,
              child: Image.asset('assets/images/Flower.png', width: 50),
            ),
            Positioned(
              top: 450,
              left: 250,
              child: Image.asset('assets/images/Flower.png', width: 30),
            ),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Transform.translate(
                  offset: const Offset(0, -80), // Changed from -150 to -80
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Wandelwijs',
                        style: TextStyle(
                          fontFamily: 'CherryBombOne',
                          fontSize: 60,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Wandelen wordt een avontuur',
                        style: TextStyle(
                          fontFamily: 'Sniglet',
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      SizedBox(
                        height: 150,
                        child: StreamBuilder<List<MissionModel>>(
                          stream: _missionService.getMissions(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final missions = snapshot.data!;
                            final incompleteMissions = missions
                                .where((m) => !m.completed)
                                .take(2)
                                .toList();

                            return Column(
                              children: incompleteMissions.map((mission) => Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 16,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green[700],
                                    child: Icon(mission.icon, color: Colors.white),
                                  ),
                                  title: Text(
                                    mission.title,
                                    style: const TextStyle(fontFamily: 'Sniglet'),
                                  ),
                                  trailing: Text(
                                    '${mission.progress}/${mission.total}',
                                    style: const TextStyle(fontFamily: 'Sniglet'),
                                  ),
                                ),
                              )).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(24),
            shape: const CircleBorder(
            ),
            elevation: 8,
          ),
          child: Icon(
            Icons.camera_alt_rounded,
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
