import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/dumping_station_model.dart';
import '../../services/dumping_station_service.dart';

class DumpingStationScreen extends StatefulWidget {
  final String companyId; // pass the logged-in company uid
  DumpingStationScreen({required this.companyId});

  @override
  _DumpingStationScreenState createState() => _DumpingStationScreenState();
}

class _DumpingStationScreenState extends State<DumpingStationScreen> {
  final DumpingStationService _service = DumpingStationService();

  final _categoryController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String? editingStationId; // null = adding new

  void _submit() async {
    final categories =
        _categoryController.text.split(',').map((e) => e.trim()).toList();
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    if (categories.isEmpty || lat == null || lng == null) return;

    final station = DumpingStation(
      stationId: editingStationId ??
          FirebaseFirestore.instance.collection('dumping_stations').doc().id,
      companyId: widget.companyId,
      categories: categories,
      location: GeoPoint(lat, lng)
    );

    if (editingStationId != null) {
      await _service.updateStation(station);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Station updated!')));
    } else {
      await _service.addStation(station: station);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Station added!')));
    }

    // Clear form
    _categoryController.clear();
    _latController.clear();
    _lngController.clear();
    setState(() => editingStationId = null);
  }

  void _edit(DumpingStation station) {
    setState(() => editingStationId = station.stationId);
    _categoryController.text = station.categories.join(', ');
    _latController.text = station.location.latitude.toString();
    _lngController.text = station.location.longitude.toString();
  }

  void _delete(String stationId) async {
    await _service.deleteStation(stationId);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Station deleted!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dumping Stations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                      labelText: 'Categories (comma separated)'),
                ),
                TextField(
                  controller: _latController,
                  decoration: InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _lngController,
                  decoration: InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: _submit,
                    child: Text(editingStationId != null
                        ? 'Update Station'
                        : 'Add Station'))
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: StreamBuilder<List<DumpingStation>>(
              stream: _service.getStationsByCompany(widget.companyId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final stations = snapshot.data!;
                if (stations.isEmpty)
                  return Center(child: Text('No stations yet.'));
                return ListView.builder(
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return ListTile(
                      title: Text('Categories: ${station.categories.join(", ")}'),
                      subtitle: Text(
                          'Location: ${station.location.latitude}, ${station.location.longitude}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _edit(station)),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _delete(station.stationId)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}