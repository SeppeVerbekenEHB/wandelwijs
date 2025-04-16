import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../screens/auth.dart';


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
                          fontFamily: 'Feijoada',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Missies button (left)
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement missies functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Missies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Album button (right)
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement album functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Album',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
            // TODO: Implement scan functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
          child: const Text(
            'SCAN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
