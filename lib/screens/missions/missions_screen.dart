import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../services/mission_service.dart';
import '../scan/scan_screen.dart';
import '../album/album_screen.dart';

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
      // Make sure missions are initialized for the user
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
        appBar: AppBar(
          title: const Text(
            'Missies',
            style: TextStyle(fontFamily: 'Sniglet'),
          ),
          backgroundColor: Colors.green[700],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jouw Missies',
                style: TextStyle(
                  fontFamily: 'RetroChild',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
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
                          itemCount: missions.length,
                          itemBuilder: (context, index) {
                            final mission = missions[index];
                            return Card(
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.all(24),
            shape: const CircleBorder(),
            elevation: 8,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 52,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Missions button (left) - disabled since we're on missions screen
              ElevatedButton(
                onPressed: null, // Disabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.all(16),
                  shape: const CircleBorder(),
                  elevation: 0,
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 80), // Space for scan button
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
    );
  }
}
