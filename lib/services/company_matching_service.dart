import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> findMatchingCompany(String category) async {
    final snapshot = await _firestore
        .collection('companies')
        .where('categories', arrayContains: category)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.id;
  }
}