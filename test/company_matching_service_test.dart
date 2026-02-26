import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:smart_waste/services/company_matching_service.dart';

void main() {
  group('CompanyMatchingService Keyword Matching Test', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CompanyMatchingService service;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      service = CompanyMatchingService(firestore: fakeFirestore);

      // Seed some companies
      await fakeFirestore.collection('users').doc('comp_metal').set({
        'role': 'company',
        'companyName': 'Metal Recyclers Inc',
        'wasteCategories': ['Metal', 'Steel'],
      });

      await fakeFirestore.collection('users').doc('comp_fabric').set({
        'role': 'company',
        'companyName': 'Fabric Solutions',
        'wasteCategories': ['Fabric', 'Cotton'],
      });

      await fakeFirestore.collection('users').doc('comp_multi').set({
        'role': 'company',
        'companyName': 'Multi Recycler',
        'wasteCategories': ['Plastic', 'Paper', 'Glass'],
      });
    });

    test('Should match "Metal" exactly', () async {
      final match = await service.findMatchingCompany('Metal');
      expect(match, 'comp_metal');
    });

    test('Should match "Recyclable Metal" using keywords', () async {
      final match = await service.findMatchingCompany('Recyclable Metal');
      expect(match, 'comp_metal');
    });

    test('Should match "Textiles" using synonyms (Fabric)', () async {
      final match = await service.findMatchingCompany('Textiles');
      expect(match, 'comp_fabric');
    });

    test('Should match "Old Clothes" using synonyms (Fabric)', () async {
      final match = await service.findMatchingCompany('Old Clothes');
      expect(match, 'comp_fabric');
    });

    test('Should match "Plastic Bottles" using keywords', () async {
      final match = await service.findMatchingCompany('Plastic Bottles');
      expect(match, 'comp_multi');
    });

    test('Should return null for unmatched category', () async {
      final match = await service.findMatchingCompany('Organic Waste');
      expect(match, isNull);
    });

    test('Should match "Paper-based" using keywords', () async {
      // comp_multi has 'Paper'
      final match = await service.findMatchingCompany('Paper-based');
      expect(match, 'comp_multi');
    });

    test('Should match "Furniture" exactly', () async {
      await fakeFirestore.collection('users').doc('comp_furniture').set({
        'role': 'company',
        'companyName': 'Furniture Recyclers',
        'wasteCategories': ['Furniture'],
      });
      final match = await service.findMatchingCompany('Furniture');
      expect(match, 'comp_furniture');
    });
  });
}
