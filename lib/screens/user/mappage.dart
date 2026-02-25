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
    final role = _currentUserProfile?.role.toLowerCase();
    final isAdmin = role == 'business' || role == 'company' || role == 'admin';
    
    // Load Waste Reports (RED Markers)
    Query wasteQuery = FirebaseFirestore.instance.collection('reports');
    if (!isAdmin) {
      wasteQuery = wasteQuery.where('isPublic', isEqualTo: true);
    }

    final wasteSnapshot = await wasteQuery.get();
    final wasteMarkers = wasteSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint? location = data['location'];
      if (location == null) return null;
      
      return Marker(
        markerId: MarkerId("waste_${doc.id}"),
        position: LatLng(location.latitude, location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: "Waste: ${data['description'] ?? 'No Description'}",
          snippet: "Category: ${data['aiAnalysis']?['category'] ?? 'analyzing'}",
        ),
      );
    }).whereType<Marker>().toSet();

    // Load Dumping Stations (GREEN Markers)
    final stationsSnapshot = await FirebaseFirestore.instance.collection('dumping_stations').get();
    final stationMarkers = stationsSnapshot.docs.map((doc) {
      final data = doc.data();
      final GeoPoint? location = data['location'];
      if (location == null) return null;

      return Marker(
        markerId: MarkerId("station_${doc.id}"),
        position: LatLng(location.latitude, location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: "Dumping Station",
          snippet: "Company ID: ${data['companyId']}",
        ),
      );
    }).whereType<Marker>().toSet();

    setState(() {
      _markers.clear();
      _markers.addAll(wasteMarkers);
      _markers.addAll(stationMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMarkers,
        backgroundColor: const Color(0xFF387664),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
