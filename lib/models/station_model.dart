import 'package:cloud_firestore/cloud_firestore.dart';

class DumpingStationModel {
  final String id;
  final String name;
  final GeoPoint location;
  final String type; // e.g., 'plastic', 'metal', 'general'
  final String status; // 'active', 'inactive'
  final String state; // For filtering by region

  DumpingStationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'type': type,
      'status': status,
      'state': state,
    };
  }

  factory DumpingStationModel.fromMap(Map<String, dynamic> map) {
    return DumpingStationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'],
      type: map['type'] ?? '',
      status: map['status'] ?? 'active',
      state: map['state'] ?? '',
    );
  }
}
