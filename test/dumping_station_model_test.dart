import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_waste/models/dumping_station_model.dart';

void main() {
  group('DumpingStation Model Test', () {

    test('fromMap should correctly parse data', () {
      final data = {
        'id': '123',
        'categories': ['Plastic', 'Metal'],
        'location': GeoPoint(3.1390, 101.6869),
        'companyId': 'company_1',
      };

      final station = DumpingStation.fromMap(data);

      expect(station.stationId, '123');
      expect(station.categories.length, 2);
      expect(station.location, GeoPoint(3.1390, 101.6869));
      expect(station.companyId, 'company_1');
    });

    test('toMap should return correct map', () {
      final station = DumpingStation(
        stationId: '123',
        categories: ['Plastic'],
        location: GeoPoint(5.3520, 100.3330),
        companyId: 'company_2',
      );

      final map = station.toMap();

      expect(map['categories'], ['Plastic']);
      expect(map['location'], GeoPoint(5.3520, 100.3330));
      expect(map['companyId'], 'company_2');
    });

  });
}