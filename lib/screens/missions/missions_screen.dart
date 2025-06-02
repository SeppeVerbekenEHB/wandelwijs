import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../services/mission_service.dart';
import '../scan/scan_screen.dart';
import '../album/album_screen.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final MissionService _missionService = MissionService();
  bool _isLoading = true;
  List<MissionModel> _missions = [];

  @override
  void initState() {
    super.initState();
    _initializeMissions();
  }

  Future<void> _initializeMissions() async {
    try {
      await _missionService.initializeMissions();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing missions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showMissionDetails(MissionModel mission) async {
    late final OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () => overlayEntry.remove(),
          child: Stack(
            children: [
              // Close button at the top
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => overlayEntry.remove(),
                ),
              ),
              // Mission details content
              Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent taps from closing overlay
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                      maxWidth: 600,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mission header
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: mission.completed 
                                  ? Colors.amber 
                                  : Colors.green[700],
                              child: mission.completed
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : Icon(mission.icon, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mission.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Sniglet',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          mission.description,
                          style: TextStyle(
                            fontFamily: 'Sniglet',
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Progress indicator
                        LinearProgressIndicator(
                          value: mission.progress / mission.total,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            mission.completed ? Colors.amber : Colors.green[700]!,
                          ),
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${mission.progress}/${mission.total}',
                          style: const TextStyle(
                            fontFamily: 'Sniglet',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Discoveries section
                        if (mission.discoveryIds.isNotEmpty) ...[
                          const Text(
                            'Ontdekkingen:',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Sniglet',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .collection('discoveries')
                                  .where(FieldPath.documentId, whereIn: mission.discoveryIds)
                                  .snapshots(),
                              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'Geen ontdekkingen gevonden',
                                      style: TextStyle(fontFamily: 'Sniglet'),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var discovery = snapshot.data!.docs[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      child: ListTile(
                                        leading: discovery['localImagePath'] != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.file(
                                                  File(discovery['localImagePath']),
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const Icon(Icons.image_not_supported),
                                        title: Text(
                                          discovery['speciesName'] ?? 'Onbekende soort',
                                          style: const TextStyle(fontFamily: 'Sniglet'),
                                        ),
                                        subtitle: Text(
                                          discovery['timestamp'] != null
                                              ? DateTime.fromMillisecondsSinceEpoch(
                                                  discovery['timestamp'].millisecondsSinceEpoch
                                                ).toString().split('.')[0]
                                              : 'Onbekende datum',
                                          style: const TextStyle(fontFamily: 'Sniglet'),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Nog geen ontdekkingen voor deze missie.',
                            style: TextStyle(
                              fontFamily: 'Sniglet',
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      
      ),
      );

    // Show overlay
    Overlay.of(context).insert(overlayEntry);
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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Missies',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CherryBombOne',
                    fontSize: 46,
                    color: Colors.green[800],
                  ),
                ),
              ),
              const SizedBox(height: 0),
              Expanded(
                child: _isLoading 
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.green[700],
                      ),
                    )
                  : StreamBuilder<List<MissionModel>>(
                      stream: _missionService.getMissions(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Er is iets misgegaan: ${snapshot.error}',
                              style: TextStyle(
                                fontFamily: 'Sniglet',
                                color: Colors.red[700],
                              ),
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.green[700],
                            ),
                          );
                        }

                        final missions = snapshot.data ?? [];

                        if (missions.isEmpty) {
                          return const Center(
                            child: Text(
                              'Geen missies gevonden',
                              style: TextStyle(
                                fontFamily: 'Sniglet',
                                fontSize: 18,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 70),
                          itemCount: missions.length,
                          itemBuilder: (context, index) {
                            final mission = missions[index];
                            return GestureDetector(
                              onTap: () => _showMissionDetails(mission),
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: mission.completed 
                                                ? Colors.amber 
                                                : Colors.green[700],
                                            child: mission.completed
                                                ? const Icon(Icons.check, color: Colors.white)
                                                : Icon(mission.icon, color: Colors.white),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              mission.title,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'Sniglet',
                                                color: mission.completed 
                                                    ? Colors.grey[700]
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          if (mission.completed)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[100],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '+${mission.reward}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Sniglet',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        mission.description,
                                        style: TextStyle(
                                          fontFamily: 'Sniglet',
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      LinearProgressIndicator(
                                        value: mission.progress / mission.total,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          mission.completed ? Colors.amber : Colors.green[700]!,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${mission.progress}/${mission.total}',
                                        style: const TextStyle(fontFamily: 'Sniglet'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
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
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Missions button (left)
                ElevatedButton(
                  onPressed: () {},
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
                const SizedBox(width: 80),
                // Album button (right)
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
