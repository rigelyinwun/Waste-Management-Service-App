import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyMatchingService {
  final FirebaseFirestore _firestore;

  CompanyMatchingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String?> findMatchingCompany(String category, {String? excludeCompanyId}) async {
    // 1. Prepare keywords from category
    final categoryLower = category.toLowerCase();
    
    // Split by non-alphanumeric to handle "Paper-based" etc.
    final words = categoryLower.split(RegExp(r'[^a-zA-Z0-9]+')).where((w) => w.length > 2).toList();
    
    // 2. Add synonyms and case variations
    final Set<String> searchTerms = {category, categoryLower};
    
    for (var word in words) {
      searchTerms.add(word);
      if (word.isNotEmpty) {
        searchTerms.add(word[0].toUpperCase() + word.substring(1).toLowerCase());
      }
      searchTerms.add(word.toUpperCase());
    }

    // Synonyms / Mapping
    if (categoryLower.contains('textile') || categoryLower.contains('fabric') || categoryLower.contains('cloth')) {
      searchTerms.addAll(['Fabric', 'textiles', 'Textiles', 'clothes', 'Clothes', 'fabric', 'Cloth']);
    }
    if (categoryLower.contains('metal')) {
      searchTerms.addAll(['Metal', 'metal', 'Recyclable Metal', 'Scrap Metal', 'Steel', 'Aluminum']);
    }
    if (categoryLower.contains('paper') || categoryLower.contains('cardboard')) {
      searchTerms.addAll(['Paper', 'paper', 'Cardboard', 'cardboard', 'Paper-based']);
    }
    if (categoryLower.contains('plastic')) {
      searchTerms.addAll(['Plastic', 'plastic', 'PET', 'HDPE']);
    }
    if (categoryLower.contains('furniture') || categoryLower.contains('wood')) {
      searchTerms.addAll(['Furniture', 'Wood', 'wood', 'furniture']);
    }
    if (categoryLower.contains('e-waste') || categoryLower.contains('electronic') || categoryLower.contains('battery')) {
      searchTerms.addAll(['E-Waste', 'Electronic', 'Battery', 'e-waste', 'electronics']);
    }

    // 3. Query 'users' collection for 'company' role with matching categories
    final termsList = searchTerms.where((t) => t.isNotEmpty).toSet().toList();
    final cappedTerms = termsList.length > 10 ? termsList.sublist(0, 10) : termsList;

    print("Matching category: '$category' using terms: $cappedTerms");

    try {
      final query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'company')
          .where('wasteCategories', arrayContainsAny: cappedTerms);
      
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        // Fix for TypeError: Use a traditional loop or find manually to avoid firstWhere orElse closure type issues
        String? matchedId;
        for (var doc in snapshot.docs) {
          if (doc.id != excludeCompanyId) {
            matchedId = doc.id;
            break;
          }
        }
        
        // If we found a match that isn't excluded, return it
        if (matchedId != null) {
          print("Found matching company: $matchedId");
          return matchedId;
        }

        // If all found companies were excluded and we have results, 
        // fallback to the first one only if excludeCompanyId wasn't strictly required
        // But usually, if we exclude someone, we want a DIFFERENT one.
        print("No non-excluded companies found.");
      }
    } catch (e) {
      print("Warning: keyword matching query failed: $e");
    }

    return null;
  }
}