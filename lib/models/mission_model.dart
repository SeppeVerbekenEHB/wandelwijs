import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MissionModel {
  final String id;
  final String title;
  final String description;
  final int progress;
  final int total;
  final String type;
  final IconData icon;
  final bool completed;
  final int reward;
  final List<String> discoveryIds; // New field

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
    required this.type,
    required this.icon,
    required this.completed,
    required this.reward,
    this.discoveryIds = const [], // Default to empty list
  });

  // Convert Firestore document to MissionModel
  factory MissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Map string icon names to IconData (you can expand this map as needed)
    final iconMap = {
      'nature': Icons.nature,
      'pets': Icons.pets,
      'local_florist': Icons.local_florist,
      'forest': Icons.forest,
      'park': Icons.park,
    };

    return MissionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      progress: data['progress'] ?? 0,
      total: data['total'] ?? 1,
      type: data['type'] ?? 'general',
      icon: iconMap[data['icon']] ?? Icons.emoji_events,
      completed: data['completed'] ?? false,
      reward: data['reward'] ?? 5,
      discoveryIds: List<String>.from(data['discoveryIds'] ?? []), // Convert to List<String>
    );
  }

  // Convert MissionModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    // Convert IconData to string representation
    String iconString = 'emoji_events';
    if (icon == Icons.nature) iconString = 'nature';
    else if (icon == Icons.pets) iconString = 'pets';
    else if (icon == Icons.local_florist) iconString = 'local_florist';
    else if (icon == Icons.forest) iconString = 'forest';
    else if (icon == Icons.park) iconString = 'park';

    return {
      'title': title,
      'description': description,
      'progress': progress,
      'total': total,
      'type': type,
      'icon': iconString,
      'completed': completed,
      'reward': reward,
      'discoveryIds': discoveryIds, // Add discoveryIds to the map
    };
  }

  // Create a copy of the mission with updated progress
  MissionModel copyWith({
    String? id,
    String? title,
    String? description,
    int? progress,
    int? total,
    String? type,
    IconData? icon,
    bool? completed,
    int? reward,
    List<String>? discoveryIds,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      total: total ?? this.total,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      completed: completed ?? this.completed,
      reward: reward ?? this.reward,
      discoveryIds: discoveryIds ?? this.discoveryIds,
    );
  }
}
