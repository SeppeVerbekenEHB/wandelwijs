import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/auth.dart';

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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mijn Profiel',
          style: TextStyle(fontFamily: 'Sniglet'),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                      title: Text('Wandelingen', style: TextStyle(fontFamily: 'Sniglet')),
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
      ),
    );
  }
}
