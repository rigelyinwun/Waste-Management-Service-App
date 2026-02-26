import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dumping_station_model.dart';

class DumpingStationService {
  final FirebaseFirestore _firestore;
  final String _collection = 'dumping_stations';

  DumpingStationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Add new station. Accepts either a full `DumpingStation` or named fields.
  Future<void> addStation({
    DumpingStation? station,
    List<String>? categories,
    String? location,
    String? companyId,
    String? stationId,
  }) async {
    if (station != null) {
      await _firestore
          .collection(_collection)
          .doc(station.stationId)
          .set(station.toMap());
      return;
    }

    final docRef = (stationId == null)
        ? _firestore.collection(_collection).doc()
        : _firestore.collection(_collection).doc(stationId);

    final data = <String, dynamic>{
      'stationId': docRef.id,
      'companyId': companyId,
      'categories': categories ?? [],
      'location': location
    };

    await docRef.set(data);
  }

  /// Edit station
  Future<void> updateStation(DumpingStation station) async {
    await _firestore
        .collection(_collection)
        .doc(station.stationId)
        .update(station.toMap());
  }

  /// Delete station
  Future<void> deleteStation(String stationId) async {
    await _firestore.collection(_collection).doc(stationId).delete();
  }

  /// Fetch single station
  Future<DumpingStation?> getStation(String stationId) async {
    final doc = await _firestore.collection(_collection).doc(stationId).get();
    if (!doc.exists) return null;
    return DumpingStation.fromMap(doc.data()!);
  }

  /// Fetch all stations for a company
  Stream<List<DumpingStation>> getStationsByCompany(String companyId) {
    return _firestore
        .collection(_collection)
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DumpingStation.fromMap(doc.data()))
            .toList());
  }

  /// Fetch all stations for certain category
  Stream<List<DumpingStation>> getStationsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('categories', arrayContains: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DumpingStation.fromMap(doc.data()))
            .toList());
  }

  /// Fetch all stations
  Stream<List<DumpingStation>> getAllStations() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DumpingStation.fromMap(doc.data()))
            .toList());
  }
}