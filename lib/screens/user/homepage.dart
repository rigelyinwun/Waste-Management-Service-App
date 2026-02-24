import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../services/user_service.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import 'dart:convert';
import 'report_result.dart';

class SmartWasteStyles {
  static const Color headerTeal = Color(0xFF387664);
  static const Color backgroundMint = Color(0xFFD3E6DB);
  static const Color accentGreen = Color(0xFF28B446);
  static const Color textDark = Color(0xFF1B3022);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: SmartWasteStyles.backgroundMint,
      appBar: AppBar(
        backgroundColor: SmartWasteStyles.headerTeal,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recycling, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text("SmartWaste",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text(
                "My Pending Requests",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: SmartWasteStyles.textDark),
              ),
            ),
            if (user != null)
              StreamBuilder<List<Report>>(
                stream: _reportService.getReportsByUser(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                          child: Text("No pending requests",
                              style: TextStyle(color: Colors.grey))),
                    );
                  }

                  final reports = snapshot.data!;
                  return Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: reports.map((report) {
                            return RequestCard(report: report);
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                    child: Text("Please login to see requests",
                        style: TextStyle(color: Colors.grey))),
              ),
            const SizedBox(height: 20),
            const Center(child: DisposeActionBox()),
            const SizedBox(height: 30),
            const RealWasteMap(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final Report report;

  const RequestCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 60) / 3;
    final category = report.aiAnalysis?.category ?? report.description;
    final status = report.status.toUpperCase();
    final imageUrl = report.imageUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportResultPage(report: report),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F4F2),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imageUrl.startsWith('http') 
                      ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                      : Image.memory(base64Decode(imageUrl), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(status: status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    bool isPending = status == "PENDING";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFFDE7) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 8,
            color: isPending ? Colors.orange : SmartWasteStyles.accentGreen,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DisposeActionBox extends StatelessWidget {
  const DisposeActionBox({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/reportwaste'),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle,
                color: SmartWasteStyles.accentGreen, size: 60),
            SizedBox(height: 8),
            Text(
              "Dispose of Something New",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: SmartWasteStyles.textDark),
            ),
          ],
        ),
      ),
    );
  }
}

class RealWasteMap extends StatefulWidget {
  const RealWasteMap({super.key});

  @override
  State<RealWasteMap> createState() => _RealWasteMapState();
}

class _RealWasteMapState extends State<RealWasteMap> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  AppUser? _currentUserProfile;
  LatLng _lastKnownLocation = const LatLng(3.1390, 101.6869); // KL

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _fetchUserProfile();
    await _getCurrentLocation();
    _loadMarkers();
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

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _lastKnownLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_lastKnownLocation, 14),
      );
    } catch (e) {
      print("Error getting location: $e");
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location not found: $e")),
      );
    }
  }

  Future<void> _loadMarkers() async {
    final isAdmin = _currentUserProfile?.role == 'business' || _currentUserProfile?.role == 'admin';
    
    // Load Waste Reports (RED Markers)
    Query wasteQuery = FirebaseFirestore.instance.collection('reports');
    if (!isAdmin) {
      wasteQuery = wasteQuery.where('isPublic', isEqualTo: true);
    }

    final wasteSnapshot = await wasteQuery.get();
    final wasteMarkers = wasteSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint location = data['location'];
      return Marker(
        markerId: MarkerId("waste_${doc.id}"),
        position: LatLng(location.latitude, location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: "Waste: ${data['description'] ?? 'No Description'}",
          snippet: "Category: ${data['aiAnalysis']?['category'] ?? 'analyzing'}",
        ),
      );
    }).toSet();

    // Load Dumping Stations (GREEN Markers)
    final stationsSnapshot = await FirebaseFirestore.instance.collection('dumping_stations').get();
    final stationMarkers = stationsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint location = data['location'];
      return Marker(
        markerId: MarkerId("station_${doc.id}"),
        position: LatLng(location.latitude, location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: "Dumping Station",
          snippet: "Company ID: ${data['companyId']}",
        ),
      );
    }).toSet();

    setState(() {
      _markers.clear();
      _markers.addAll(wasteMarkers);
      _markers.addAll(stationMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search location...",
              prefixIcon: const Icon(Icons.search, color: SmartWasteStyles.headerTeal),
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _getCurrentLocation,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _searchLocation(),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _lastKnownLocation,
                zoom: 14,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
              zoomControlsEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
      ],
    );
  }
}