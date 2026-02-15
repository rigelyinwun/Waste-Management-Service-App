import 'package:cloud_firestore/cloud_firestore.dart';

class DumpingStation {
  final String stationId;
  final String companyId;
  final List<String> categories; // multiple waste categories
  final GeoPoint location;

  DumpingStation({
    required this.stationId,
    required this.companyId,
    required this.categories,
    required this.location,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'stationId': stationId,
      'companyId': companyId,
      'categories': categories,
      'location': location
    };
  }

  /// Convert from Firestore map
  factory DumpingStation.fromMap(Map<String, dynamic> map) {
    return DumpingStation(
      stationId: map['stationId'],
      companyId: map['companyId'],
      categories: List<String>.from(map['categories']),
      location: map['location']
    );
  }
}