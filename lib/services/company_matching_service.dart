import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyMatchingService {
  final FirebaseFirestore _firestore;

  CompanyMatchingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String?> findMatchingCompany(String category, {String? excludeCompanyId}) async {
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
      var query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'company')
          .where('wasteCategories', arrayContainsAny: cappedTerms);
      
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        // Filter out excluded company if needed
        final match = snapshot.docs.firstWhere(
          (doc) => doc.id != excludeCompanyId,
          orElse: () => snapshot.docs.first, // Fallback if no other matches, or just return null?
        );
        
        // If the only match is the excluded one, and we really want "others", return null
        if (match.id == excludeCompanyId && snapshot.docs.length == 1) {
          return null;
        }

        return match.id;
      }
    } catch (e) {
      print("Warning: keyword matching query failed or no matches: $e");
    }

    return null;
  }
}