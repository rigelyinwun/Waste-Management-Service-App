import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyMatchingService {
  final FirebaseFirestore _firestore;

  CompanyMatchingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String?> findMatchingCompany(String category) async {
    // 1. Prepare keywords from category
    final categoryLower = category.toLowerCase();
    final words = categoryLower.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();
    
    // 2. Add synonyms and case variations
    final Set<String> searchTerms = {category, categoryLower};
    
    for (var word in words) {
      searchTerms.add(word);
      if (word.isNotEmpty) {
        searchTerms.add(word[0].toUpperCase() + word.substring(1).toLowerCase());
      }
      searchTerms.add(word.toUpperCase());
    }

    if (categoryLower.contains('textile') || categoryLower.contains('fabric') || categoryLower.contains('cloth')) {
      searchTerms.addAll(['Fabric', 'textiles', 'Textiles', 'clothes', 'Clothes', 'fabric']);
    }
    if (categoryLower.contains('metal')) {
      searchTerms.addAll(['Metal', 'metal', 'Recyclable Metal', 'Scrap Metal']);
    }

    // 3. Query 'users' collection for 'company' role with matching categories
    // Note: arrays-contains-any has a limit of 10 elements.
    final termsList = searchTerms.where((t) => t.isNotEmpty).toSet().toList();
    final cappedTerms = termsList.length > 10 ? termsList.sublist(0, 10) : termsList;

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'company')
          .where('wasteCategories', arrayContainsAny: cappedTerms)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
    } catch (e) {
      print("Warning: keyword matching query failed or no matches: $e");
    }

    return null;
  }
}