import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/mission_model.dart';

class MissionService {
  // Get Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Default missions to create for new users
  List<MissionModel> _getDefaultMissions() {
    return [
      MissionModel(
        id: 'trees',
        title: 'Vind 5 verschillende bomen',
        description: 'Scan 5 verschillende bomen tijdens je wandeling',
        progress: 0,
        total: 5,
        type: 'Boom',
        icon: Icons.park,
        completed: false,
        reward: 20,
      ),
      MissionModel(
        id: 'animals',
        title: 'Ontdek 3 wilde dieren',
        description: 'Scan 3 wilde dieren in hun natuurlijke habitat',
        progress: 0,
        total: 3,
        type: 'Dier',
        icon: Icons.pets,
        completed: false,
        reward: 15,
      ),
      MissionModel(
        id: 'plants',
        title: 'Verzamel 10 plantsoorten',
        description: 'Scan 10 verschillende plantensoorten',
        progress: 0,
        total: 10,
        type: 'Plant',
        icon: Icons.local_florist,
        completed: false,
        reward: 30,
      ),
    ];
  }

  // Initialize missions for a new user
  Future<void> initializeMissions() async {
    if (_userId == null) return;

    // Check if user already has missions
    final missionsSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('missions')
        .get();

    // If no missions exist, create the default ones
    if (missionsSnapshot.docs.isEmpty) {
      final batch = _firestore.batch();

      for (var mission in _getDefaultMissions()) {
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('missions')
            .doc(mission.id);
        batch.set(docRef, mission.toFirestore());
      }

      await batch.commit();
    }
  }

  // Get all missions for the current user
  Stream<List<MissionModel>> getMissions() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('missions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MissionModel.fromFirestore(doc)).toList();
    });
  }

  // Update missions based on a discovery
  Future<void> updateMissionsForDiscovery(String category, String speciesName) async {
    if (_userId == null) return;

    // Get current missions
    final missionsSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('missions')
        .get();

    // Get user's discoveries to check for uniqueness
    final discoveriesSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('discoveries')
        .where('speciesName', isEqualTo: speciesName)
        .get();

    // If more than one result, this is not a new unique species (just re-discovered)
    bool isNewUniqueSpecies = discoveriesSnapshot.docs.length <= 1;

    // If it's not a new unique species, don't update missions
    if (!isNewUniqueSpecies) return;

    // Initialize a batch for all updates
    final batch = _firestore.batch();
    int totalPointsToAdd = 0;

    for (var doc in missionsSnapshot.docs) {
      final mission = MissionModel.fromFirestore(doc);
      
      // Skip if mission is already completed
      if (mission.completed) continue;

      // Check if the category matches the mission type
      bool shouldUpdateMission = false;
      
      // Handle different category formats and mission types
      if (mission.type == 'Boom' && (category == 'Boom' || category.toLowerCase().contains('boom'))) {
        shouldUpdateMission = true;
      } else if (mission.type == 'Dier' && 
                (category == 'Dier' || 
                 category.toLowerCase().contains('dier') || 
                 category.toLowerCase().contains('vogel') || 
                 category.toLowerCase().contains('insect'))) {
        shouldUpdateMission = true;
      } else if (mission.type == 'Plant' && (category == 'Plant' || category.toLowerCase().contains('plant'))) {
        shouldUpdateMission = true;
      }

      if (shouldUpdateMission) {
        // Calculate new progress (don't exceed total)
        int newProgress = mission.progress + 1;
        if (newProgress > mission.total) {
          newProgress = mission.total;
        }

        // Check if mission is now completed
        bool newCompleted = newProgress >= mission.total;
        
        // Add points if mission is completed
        if (newCompleted && !mission.completed) {
          totalPointsToAdd += mission.reward;
        }

        // Update the mission
        batch.update(doc.reference, {
          'progress': newProgress,
          'completed': newCompleted,
        });
      }
    }

    // Update user's points if any missions were completed
    if (totalPointsToAdd > 0) {
      final userRef = _firestore.collection('users').doc(_userId);
      final userSnapshot = await userRef.get();
      
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        int currentPoints = userData['totalPoints'] ?? 0;
        batch.update(userRef, {'totalPoints': currentPoints + totalPointsToAdd});
      }
    }

    // Commit all updates
    await batch.commit();
  }

  // Mark a mission as completed (useful if you need manual mission completion)
  Future<void> completeMission(String missionId) async {
    if (_userId == null) return;

    await _firestore
      .collection('users')
      .doc(_userId)
      .collection('missions')
      .doc(missionId)
      .update({
        'completed': true,
      });
  }

  // Reset a mission (for testing or if needed)
  Future<void> resetMission(String missionId) async {
    if (_userId == null) return;

    await _firestore
      .collection('users')
      .doc(_userId)
      .collection('missions')
      .doc(missionId)
      .update({
        'progress': 0,
        'completed': false,
      });
  }
}
