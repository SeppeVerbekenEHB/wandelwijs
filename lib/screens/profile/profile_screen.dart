import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
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
                    const ListTile(
                      leading: Icon(Icons.hiking, color: Colors.green),
                      title: Text('Stappen', style: TextStyle(fontFamily: 'Sniglet')),
                      trailing: Text('0', style: TextStyle(fontFamily: 'Sniglet')),
                    ),
                    const ListTile(
                      leading: Icon(Icons.emoji_events, color: Colors.green),
                      title: Text('Voltooide Missies', style: TextStyle(fontFamily: 'Sniglet')),
                      trailing: Text('0', style: TextStyle(fontFamily: 'Sniglet')),
                    ),
                    const ListTile(
                      leading: Icon(Icons.photo_album, color: Colors.green),
                      title: Text('Verzamelde Items', style: TextStyle(fontFamily: 'Sniglet')),
                      trailing: Text('0', style: TextStyle(fontFamily: 'Sniglet')),
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
