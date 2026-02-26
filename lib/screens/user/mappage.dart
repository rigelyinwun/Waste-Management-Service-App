import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  AppUser? _currentUserProfile;
  LatLng _currentLocation = const LatLng(3.1390, 101.6869); // Default KL
  bool _isLoading = true;

  // Filters
  bool _showWaste = true;
  bool _showStations = true;
  double _distanceKm = 10.0; // Default 10km

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _fetchUserProfile();
    await _determinePosition();
    _loadMarkers();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _userService.fetchUserProfile(user.uid);
      setState(() {
        _currentUserProfile = profile;
      });
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 14),
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = LatLng(locations.first.latitude, locations.first.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(loc, 14));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location not found: $e")),
        );
      }
    }
  }

  Future<void> _loadMarkers() async {
    setState(() => _isLoading = true);
    final role = _currentUserProfile?.role.toLowerCase();
    final isAdmin = role == 'business' || role == 'company' || role == 'admin';
    
    final markers = <Marker>{};

    // Load Waste Reports (RED Markers)
    if (_showWaste) {
      Query wasteQuery = FirebaseFirestore.instance.collection('reports');
      if (!isAdmin) {
        wasteQuery = wasteQuery.where('isPublic', isEqualTo: true);
      }

      final wasteSnapshot = await wasteQuery.get();
      for (var doc in wasteSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final GeoPoint? location = data['location'];
        if (location == null) continue;
        
        final pos = LatLng(location.latitude, location.longitude);
        final dist = _calculateDistance(_currentLocation.latitude, _currentLocation.longitude, pos.latitude, pos.longitude);
        
        if (dist <= _distanceKm) {
          markers.add(Marker(
            markerId: MarkerId("waste_${doc.id}"),
            position: pos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: "Waste: ${data['description'] ?? 'No Description'}",
              snippet: "Category: ${data['aiAnalysis']?['category'] ?? 'analyzing'}",
            ),
          ));
        }
      }
    }

    // Load Dumping Stations (GREEN Markers)
    if (_showStations) {
      final stationsSnapshot = await FirebaseFirestore.instance.collection('dumping_stations').get();
      for (var doc in stationsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final GeoPoint? location = data['location'];
        if (location == null) continue;

        final pos = LatLng(location.latitude, location.longitude);
        final dist = _calculateDistance(_currentLocation.latitude, _currentLocation.longitude, pos.latitude, pos.longitude);

        if (dist <= _distanceKm) {
          markers.add(Marker(
            markerId: MarkerId("station_${doc.id}"),
            position: pos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: "Dumping Station",
              snippet: "Company ID: ${data['companyId']}",
            ),
          ));
        }
      }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
      _isLoading = false;
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Basic Haversine formula
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text("Map Filters", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF387664))),
              backgroundColor: const Color(0xFFD3E6DB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text("Waste Reports"),
                    value: _showWaste,
                    activeColor: const Color(0xFF387664),
                    onChanged: (v) => setLocal(() => setState(() => _showWaste = v!)),
                  ),
                  CheckboxListTile(
                    title: const Text("Dumping Stations"),
                    value: _showStations,
                    activeColor: const Color(0xFF387664),
                    onChanged: (v) => setLocal(() => setState(() => _showStations = v!)),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Radius:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${_distanceKm.toStringAsFixed(1)} km"),
                      ],
                    ),
                  ),
                  Slider(
                    value: _distanceKm,
                    min: 1,
                    max: 100,
                    activeColor: const Color(0xFF387664),
                    onChanged: (v) => setLocal(() => setState(() => _distanceKm = v)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Apply", style: TextStyle(color: Color(0xFF387664), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => _loadMarkers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Waste & Station Map", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF387664),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            padding: const EdgeInsets.only(top: 80),
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search for a location...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF387664)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location, color: Color(0xFF387664)),
                    onPressed: _determinePosition,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                onSubmitted: (_) => _searchLocation(),
              ),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF387664))),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "filterBtn",
            onPressed: _showFilterDialog,
            backgroundColor: const Color(0xFF387664),
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "refreshBtn",
            onPressed: _loadMarkers,
            backgroundColor: const Color(0xFF387664),
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
