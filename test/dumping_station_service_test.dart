import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:smart_waste/services/dumping_station_service.dart';

void main() {
  group('DumpingStationService Test', () {

    test('addStation should add document to Firestore', () async {

      final fakeFirestore = FakeFirebaseFirestore();
      final service = DumpingStationService(firestore: fakeFirestore);

      await service.addStation(
        categories: ['Plastic', 'Glass'],
        location: 'Johor',
        companyId: 'company_test',
      );

      final snapshot =
          await fakeFirestore.collection('dumping_stations').get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first['location'], 'Johor');
    });

    test('deleteStation should remove document', () async {

      final fakeFirestore = FakeFirebaseFirestore();
      final service = DumpingStationService(firestore: fakeFirestore);

      final doc = await fakeFirestore.collection('dumping_stations').add({
        'categories': ['Metal'],
        'location': 'Ipoh',
        'companyId': 'company_test',
      });

      await service.deleteStation(doc.id);

      final snapshot =
          await fakeFirestore.collection('dumping_stations').get();

      expect(snapshot.docs.length, 0);
    });

  });
}