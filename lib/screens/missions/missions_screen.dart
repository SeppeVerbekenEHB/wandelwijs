import 'package:flutter/material.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final List<Map<String, dynamic>> _missions = [
    {
      'title': 'Vind 5 verschillende bomen',
      'description': 'Scan 5 verschillende bomen tijdens je wandeling',
      'progress': 0,
      'total': 5,
      'icon': Icons.nature,
    },
    {
      'title': 'Ontdek 3 wilde dieren',
      'description': 'Scan 3 wilde dieren in hun natuurlijke habitat',
      'progress': 0,
      'total': 3,
      'icon': Icons.pets,
    },
    {
      'title': 'Verzamel 10 plantsoorten',
      'description': 'Scan 10 verschillende plantensoorten',
      'progress': 0,
      'total': 10,
      'icon': Icons.local_florist,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Missies',
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
        child: Padding(
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
                child: ListView.builder(
                  itemCount: _missions.length,
                  itemBuilder: (context, index) {
                    final mission = _missions[index];
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
                                  backgroundColor: Colors.green[700],
                                  child: Icon(mission['icon'], color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    mission['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Feijoada',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mission['description'],
                              style: TextStyle(
                                fontFamily: 'Feijoada',
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: mission['progress'] / mission['total'],
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green[700]!),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${mission['progress']}/${mission['total']}',
                              style: const TextStyle(fontFamily: 'Feijoada'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
