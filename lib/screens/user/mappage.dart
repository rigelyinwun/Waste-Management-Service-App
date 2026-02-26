import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/report_service.dart';
import '../../services/dumping_station_service.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../models/report_model.dart';
import '../../models/dumping_station_model.dart';
import '../../models/user_model.dart';
import '../admin/waste_profile.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const Color bg = Color(0xFFE6F1ED);
  static const Color headerGreen = Color(0xFF2E746A);
  static const Color cardMint = Color(0xFFD9F0E6);
  static const Color buttonGreen = Color(0xFF3C7F72);
  static const Color pillGreen = Color(0xFF4B9E92);
  static const Color textDark = Color(0xFF1E3B36);
  static const Color subtleText = Color(0xFF5B7B74);
  static const Color divider = Color(0xFFA9C8BE);

  // ---------- Map ----------
  final Completer<GoogleMapController> _mapController = Completer();
  CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(3.1390, 101.6869), // KL
    zoom: 13.5,
  );

  // ---------- Search ----------
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = "";
  bool _showSearchList = false;

  // ---------- Services & Subscriptions ----------
  final ReportService _reportService = ReportService();
  final DumpingStationService _stationService = DumpingStationService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  StreamSubscription? _reportsSub;
  StreamSubscription? _stationsSub;

  List<Report> _firestoreReports = [];
  List<DumpingStation> _firestoreStations = [];
  final Map<String, AppUser> _companyProfiles = {};

  // ---------- Filters ----------
  final Set<_PlaceType> _selectedTypes = {
    _PlaceType.wasteLocation,
    _PlaceType.dumpingStation,
  };
  double _distanceKm = 10;
  static const double _distanceMax = 100;

  // ---------- Selected place ----------
  _Place? _selectedPlace;
  bool _navigateMode = false;

  // ---------- User Location ----------
  LatLng _userLocation = const LatLng(3.1390, 101.6869);
  bool _isLoading = true;

  // ---------- Route ----------
  _TransportMode _transportMode = _TransportMode.car;
  List<LatLng> _routePoints = const [];
  String _routeEtaLabel = "4 min (800m)";

  // ---------- Map Display ----------
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initData();
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() => _showSearchList = false);
      }
    });
  }

  Future<void> _initData() async {
    await _determinePosition();
    
    // Listen to public reports
    _reportsSub = _reportService.getPublicReports().listen((reports) {
      if (mounted) {
        setState(() {
          _firestoreReports = reports;
          _rebuildMarkers();
        });
      }
    });

    // Listen to all dumping stations
    _stationsSub = _stationService.getAllStations().listen((stations) async {
      if (mounted) {
        _firestoreStations = stations;
        // Fetch company names for new stations
        for (var s in stations) {
          if (!_companyProfiles.containsKey(s.companyId)) {
            final profile = await _userService.fetchUserProfile(s.companyId);
            if (profile != null) {
              _companyProfiles[s.companyId] = profile;
            }
          }
        }
        if (mounted) {
          setState(() {
            _rebuildMarkers();
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _initialCamera = CameraPosition(target: _userLocation, zoom: 13.5);
      });

      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(_initialCamera));
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _reportsSub?.cancel();
    _stationsSub?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data Conversion
  // ---------------------------------------------------------------------------
  List<_Place> get _allPlaces {
    final List<_Place> places = [];

    // Map Reports to _Place
    for (final r in _firestoreReports) {
      places.add(_Place(
        id: "report_${r.reportId}",
        name: r.description.isNotEmpty ? r.description : "Waste Report",
        type: _PlaceType.wasteLocation,
        position: LatLng(r.location.latitude, r.location.longitude),
        address: r.locationName,
        phone: "N/A",
        isOpen: true,
        closesAt: "—",
        capacityPct: 0,
        accepted: [r.aiAnalysis?.category ?? "Analyzing..."],
        originalReport: r,
      ));
    }

    // Map Stations to _Place
    for (final s in _firestoreStations) {
      final company = _companyProfiles[s.companyId];
      places.add(_Place(
        id: "station_${s.stationId}",
        name: company?.companyName ?? "Dumping Station",
        type: _PlaceType.dumpingStation,
        position: LatLng(s.location.latitude, s.location.longitude),
        address: "Dumping Station", // We could reverse geocode if needed
        phone: company?.phoneNumber ?? "N/A",
        isOpen: true,
        closesAt: "Open 24/7",
        capacityPct: 100, // Placeholder
        accepted: s.categories,
      ));
    }

    return places;
  }

  List<_Place> get _filteredPlaces {
    final q = _searchQuery.trim().toLowerCase();
    return _allPlaces.where((p) {
      if (!_selectedTypes.contains(p.type)) return false;

      if (q.isNotEmpty) {
        final hit =
            p.name.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q);
        if (!hit) return false;
      }

      final km = _haversineKm(_userLocation, p.position);
      if (km > _distanceKm) return false;

      return true;
    }).toList();
  }

  void _rebuildMarkers() {
    final places = _filteredPlaces;
    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: _userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "You are here"),
      ),
    );

    for (final p in places) {
      markers.add(
        Marker(
          markerId: MarkerId(p.id),
          position: p.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _markerHueForType(p.type),
          ),
          onTap: () {
            if (p.type == _PlaceType.wasteLocation && p.originalReport != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WasteProfilePage(report: p.originalReport!),
                ),
              );
            } else {
              setState(() {
                _selectedPlace = p;
                _navigateMode = false;
                _polylines = {};
                _routePoints = const [];
              });
              _openPlaceSheet(p);
            }
          },
        ),
      );
    }

    setState(() => _markers = markers);
  }

  double _markerHueForType(_PlaceType t) {
    switch (t) {
      case _PlaceType.wasteLocation:
        return BitmapDescriptor.hueRed;
      case _PlaceType.dumpingStation:
        return BitmapDescriptor.hueGreen;
      case _PlaceType.recyclingCenter:
        return BitmapDescriptor.hueCyan;
    }
  }

  // ---------------------------------------------------------------------------
  // Map Controls
  // ---------------------------------------------------------------------------
  Future<void> _zoomIn() async {
    final c = await _mapController.future;
    await c.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final c = await _mapController.future;
    await c.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _goToUser() async {
    final c = await _mapController.future;
    await c.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLocation, zoom: 15.0),
      ),
    );
  }

  Future<void> _focusToPlace(_Place p) async {
    final c = await _mapController.future;
    await c.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: p.position, zoom: 15.5),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filters dialog
  // ---------------------------------------------------------------------------
  void _openFiltersDialog() {
    final tmpTypes = Set<_PlaceType>.from(_selectedTypes);
    double tmpDistance = _distanceKm;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: cardMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: pillGreen, width: 2),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: Offset(0, 8),
                  color: Color(0x33000000),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: StatefulBuilder(
              builder: (context, setLocal) {
                Widget typeRow(String label, _PlaceType t) {
                  return InkWell(
                    onTap: () => setLocal(() {
                      if (tmpTypes.contains(t)) {
                        tmpTypes.remove(t);
                      } else {
                        tmpTypes.add(t);
                      }
                    }),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: tmpTypes.contains(t),
                            onChanged: (_) => setLocal(() {
                              if (tmpTypes.contains(t)) {
                                tmpTypes.remove(t);
                              } else {
                                tmpTypes.add(t);
                              }
                            }),
                            activeColor: buttonGreen,
                            side: BorderSide(color: divider, width: 1.4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w200,
                            fontSize: 13.5,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Filters",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: headerGreen,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: textDark),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Text(
                          "Category",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w500,
                            fontSize: 14.5,
                            color: textDark,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "All",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w200,
                            fontSize: 13,
                            color: subtleText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    typeRow("Waste Locations", _PlaceType.wasteLocation),
                    typeRow("Dumping Stations", _PlaceType.dumpingStation),
                    const SizedBox(height: 12),
                    Container(height: 1, color: divider.withOpacity(0.7)),
                    const SizedBox(height: 12),
                    const Text(
                      "Distance",
                      style: TextStyle(
                        fontFamily: "Lexend",
                        fontWeight: FontWeight.w500,
                        fontSize: 14.5,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 9,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        activeTrackColor: buttonGreen,
                        inactiveTrackColor: divider.withOpacity(0.7),
                        thumbColor: buttonGreen,
                        overlayColor: buttonGreen.withOpacity(0.12),
                      ),
                      child: Slider(
                        min: 0,
                        max: _distanceMax,
                        value: tmpDistance.clamp(0, _distanceMax),
                        onChanged: (v) => setLocal(() => tmpDistance = v),
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          "0 km",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w200,
                            fontSize: 12,
                            color: subtleText,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "100 km",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w200,
                            fontSize: 12,
                            color: subtleText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: divider),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.white.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => setLocal(() {
                              tmpTypes
                                ..clear()
                                ..addAll({
                                  _PlaceType.wasteLocation,
                                  _PlaceType.dumpingStation,
                                });
                              tmpDistance = 10;
                            }),
                            child: const Text(
                              "Reset",
                              style: TextStyle(
                                fontFamily: "Lexend",
                                fontWeight: FontWeight.w500,
                                color: textDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedTypes
                                  ..clear()
                                  ..addAll(tmpTypes);
                                _distanceKm = tmpDistance;
                              });
                              _rebuildMarkers();
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                fontFamily: "Lexend",
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Sheets
  // ---------------------------------------------------------------------------
  void _openPlaceSheet(_Place p) {
    _focusToPlace(p);
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _SheetContainer(
          child: _PlaceDetailsSheet(
            place: p,
            onNavigate: () {
              Navigator.pop(context);
              _enterNavigateMode(p);
            },
          ),
        );
      },
    );
  }

  void _openListSheet(List<_Place> places) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _SheetContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 2),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: divider.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    "Nearby Locations",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: textDark),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (places.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    "No results within your filters.",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontWeight: FontWeight.w200,
                      color: subtleText,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: places.length,
                    separatorBuilder: (_, _) => Container(
                      height: 1,
                      color: divider.withOpacity(0.6),
                    ),
                    itemBuilder: (_, i) {
                      final p = places[i];
                      final km = _haversineKm(_userLocation, p.position);
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          _selectFromSearch(p);
                        },
                        leading: CircleAvatar(
                          backgroundColor: _chipColorForType(p.type),
                          child: Icon(
                            _iconForType(p.type),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: textDark,
                          ),
                        ),
                        subtitle: Text(
                          "${p.address}  •  ${km.toStringAsFixed(1)} km",
                          style: const TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w200,
                            fontSize: 12.5,
                            color: subtleText,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openLegendSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return _SheetContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: divider.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        "Legend (Tap to Filter)",
                        style: TextStyle(
                          fontFamily: "Lexend",
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: textDark,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _legendRow(
                    color: _chipColorForType(_PlaceType.wasteLocation),
                    icon: _iconForType(_PlaceType.wasteLocation),
                    label: "Waste Location",
                    isActive: _selectedTypes.contains(_PlaceType.wasteLocation),
                    onTap: () => _toggleType(_PlaceType.wasteLocation, setSheet),
                  ),
                  const SizedBox(height: 8),
                  _legendRow(
                    color: _chipColorForType(_PlaceType.dumpingStation),
                    icon: _iconForType(_PlaceType.dumpingStation),
                    label: "Dumping Station",
                    isActive: _selectedTypes.contains(_PlaceType.dumpingStation),
                    onTap: () => _toggleType(_PlaceType.dumpingStation, setSheet),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _toggleType(_PlaceType type, StateSetter setSheet) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
      _rebuildMarkers();
    });
    setSheet(() {});
  }

  Widget _legendRow({
    required Color color,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isActive ? color : color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: "Lexend",
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w200,
                  fontSize: 13.5,
                  color: isActive ? textDark : textDark.withOpacity(0.5),
                ),
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle, color: headerGreen, size: 20)
            else
              Icon(Icons.circle_outlined, color: divider, size: 20),
          ],
        ),
      ),
    );
  }

  void _selectFromSearch(_Place p) {
    _searchCtrl.text = p.name;
    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchCtrl.text.length),
    );
    _searchQuery = p.name;

    setState(() {
      _selectedPlace = p;
      _showSearchList = false;
      _navigateMode = false;
      _polylines = {};
      _routePoints = const [];
    });

    _rebuildMarkers();
    FocusScope.of(context).unfocus();
    _openPlaceSheet(p);
  }

  // ---------------------------------------------------------------------------
  // Navigate mode
  // ---------------------------------------------------------------------------
  void _enterNavigateMode(_Place p) {
    final route = _generateRoute(_userLocation, p.position);
    final km = _haversineKm(_userLocation, p.position);
    final meters = (km * 1000).round();
    final mins = max(2, (meters / _speedMetersPerMin(_transportMode)).round());
    final eta = "$mins min (${meters}m)";

    final newPolylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId("route"),
        points: route,
        width: 7,
        color: const Color(0xFF2D78FF),
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };

    setState(() {
      _navigateMode = true;
      _selectedPlace = p;
      _routePoints = route;
      _polylines = newPolylines;
      _routeEtaLabel = eta;
      _showSearchList = false;
    });

    _fitToRoute();
  }

  double _speedMetersPerMin(_TransportMode m) {
    switch (m) {
      case _TransportMode.car: return 350;
      case _TransportMode.bike: return 220;
      case _TransportMode.transit: return 280;
      case _TransportMode.walk: return 80;
    }
  }

  Future<void> _fitToRoute() async {
    if (_routePoints.isEmpty) return;
    final c = await _mapController.future;

    double minLat = _routePoints.first.latitude;
    double maxLat = _routePoints.first.latitude;
    double minLng = _routePoints.first.longitude;
    double maxLng = _routePoints.first.longitude;

    for (final p in _routePoints) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  void _updateTransport(_TransportMode m) {
    final p = _selectedPlace;
    if (p == null) return;
    setState(() => _transportMode = m);
    _enterNavigateMode(p);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPlaces;
    final showDropdown = _showSearchList && _searchQuery.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: _initialCamera,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                    },
                    onTap: (_) {
                      FocusScope.of(context).unfocus();
                      setState(() => _showSearchList = false);
                    },
                  ),

                  // Search bar
                  Positioned(
                    left: 14,
                    right: 14,
                    top: 14,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SearchBar(
                          controller: _searchCtrl,
                          focusNode: _searchFocus,
                          hintText: "Search location",
                          onChanged: (v) {
                            setState(() {
                              _searchQuery = v;
                              _showSearchList = true;
                            });
                            _rebuildMarkers();
                          },
                          onFilterTap: _openFiltersDialog,
                          onClear: () {
                            setState(() {
                              _searchCtrl.clear();
                              _searchQuery = "";
                              _showSearchList = false;
                            });
                            _rebuildMarkers();
                          },
                        ),
                        if (showDropdown)
                          _SearchResultsDropdown(
                            results: filtered,
                            onTapItem: _selectFromSearch,
                          ),
                      ],
                    ),
                  ),

                  // Map buttons
                  Positioned(
                    right: 14,
                    top: 86,
                    child: Column(
                      children: [
                        _MapButton(icon: Icons.add, onTap: _zoomIn),
                        const SizedBox(height: 10),
                        _MapButton(icon: Icons.remove, onTap: _zoomOut),
                        const SizedBox(height: 10),
                        _MapButton(
                          icon: Icons.near_me_outlined,
                          onTap: _goToUser,
                        ),
                      ],
                    ),
                  ),

                  // Loading
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: buttonGreen)),

                  // Bottom panel
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _navigateMode
                        ? _NavigatePanel(
                            fromLabel: "My Location",
                            toLabel: _selectedPlace?.name ?? "Destination",
                            etaLabel: _routeEtaLabel,
                            transportMode: _transportMode,
                            onTransportChanged: _updateTransport,
                            onStartTrip: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Start Trip pressed")),
                              );
                            },
                            onExit: () {
                              setState(() {
                                _navigateMode = false;
                                _polylines = {};
                                _routePoints = const [];
                              });
                            },
                          )
                        : _NearbyPanel(
                            count: filtered.length,
                            categoryLabel: _categoryLabel(_selectedTypes),
                            distanceLabel: "< ${_distanceKm.round()} km",
                            onShowList: () => _openListSheet(filtered),
                            onLegend: _openLegendSheet,
                            onTapCategory: _openFiltersDialog,
                            onTapDistance: _openFiltersDialog,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(Set<_PlaceType> types) {
    if (types.length == 2) return "All";
    final names = <String>[];
    if (types.contains(_PlaceType.wasteLocation)) names.add("Waste");
    if (types.contains(_PlaceType.dumpingStation)) names.add("Dumping");
    return names.join(", ");
  }

  Color _chipColorForType(_PlaceType t) {
    switch (t) {
      case _PlaceType.wasteLocation: return const Color(0xFFB84B4B);
      case _PlaceType.dumpingStation: return const Color(0xFF4A8D5C);
      case _PlaceType.recyclingCenter: return const Color(0xFF2D8DA1);
    }
  }

  IconData _iconForType(_PlaceType t) {
    switch (t) {
      case _PlaceType.wasteLocation: return Icons.location_on;
      case _PlaceType.dumpingStation: return Icons.delete_outline;
      case _PlaceType.recyclingCenter: return Icons.recycling;
    }
  }

  static double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final lat1 = _deg2rad(a.latitude);
    final lat2 = _deg2rad(b.latitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return r * c;
  }

  static double _deg2rad(double d) => d * pi / 180;

  List<LatLng> _generateRoute(LatLng start, LatLng end) {
    final points = <LatLng>[];
    const steps = 18;
    final midLat = (start.latitude + end.latitude) / 2;
    final midLng = (start.longitude + end.longitude) / 2;
    const offset = 0.004;
    final control = LatLng(midLat + offset, midLng - offset);
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = (1 - t) * (1 - t) * start.latitude + 2 * (1 - t) * t * control.latitude + t * t * end.latitude;
      final lng = (1 - t) * (1 - t) * start.longitude + 2 * (1 - t) * t * control.longitude + t * t * end.longitude;
      points.add(LatLng(lat, lng));
    }
    return points;
  }
}

// ============================================================================
// Internal Widgets (Copied from LocationsPage)
// ============================================================================

class _SearchResultsDropdown extends StatelessWidget {
  final List<_Place> results;
  final ValueChanged<_Place> onTapItem;

  const _SearchResultsDropdown({required this.results, required this.onTapItem});

  @override
  Widget build(BuildContext context) {
    final list = results.take(6).toList();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD9F0E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA9C8BE).withOpacity(0.9), width: 1.2),
        boxShadow: const [BoxShadow(blurRadius: 12, offset: Offset(0, 6), color: Color(0x1A000000))],
      ),
      child: list.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text("No matching locations found.", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12.5, color: Color(0xFF5B7B74))),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, _) => Container(height: 1, color: const Color(0xFFA9C8BE).withOpacity(0.6)),
              itemBuilder: (_, i) {
                final p = list[i];
                return ListTile(
                  dense: true,
                  onTap: () => onTapItem(p),
                  title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 13.5, color: Color(0xFF1E3B36))),
                  subtitle: Text(p.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12, color: Color(0xFF5B7B74))),
                );
              },
            ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onClear;

  const _SearchBar({required this.controller, required this.focusNode, required this.hintText, required this.onChanged, required this.onFilterTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;
    const textDark = Color(0xFF1E3B36);
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFCFE9DB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4B9E92).withOpacity(0.55), width: 1.6),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 6), color: Color(0x1A000000))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: textDark),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 13.5, color: textDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 13.5, color: textDark.withOpacity(0.55)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (hasText)
            IconButton(icon: const Icon(Icons.close, color: textDark, size: 20), onPressed: onClear),
          IconButton(icon: const Icon(Icons.tune, color: textDark, size: 20), onPressed: onFilterTap),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFCFE9DB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFA9C8BE).withOpacity(0.9), width: 1.2)),
          child: Icon(icon, color: const Color(0xFF1E3B36)),
        ),
      ),
    );
  }
}

class _NearbyPanel extends StatelessWidget {
  final int count;
  final String categoryLabel;
  final String distanceLabel;
  final VoidCallback onShowList;
  final VoidCallback onLegend;
  final VoidCallback onTapCategory;
  final VoidCallback onTapDistance;

  const _NearbyPanel({required this.count, required this.categoryLabel, required this.distanceLabel, required this.onShowList, required this.onLegend, required this.onTapCategory, required this.onTapDistance});

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF1E3B36);
    const divider = Color(0xFFA9C8BE);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFD9F0E6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [BoxShadow(blurRadius: 18, offset: Offset(0, -6), color: Color(0x22000000))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 44, height: 5, decoration: BoxDecoration(color: divider.withOpacity(0.85), borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 10),
          Row(children: [Text("$count Locations Found Nearby", style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 15, color: textDark))]),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _PillDropdown(label: "Type:", value: categoryLabel, onTap: onTapCategory)),
              const SizedBox(width: 10),
              Expanded(child: _PillDropdown(label: "Dist:", value: distanceLabel, onTap: onTapDistance)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.white.withOpacity(0.4), padding: const EdgeInsets.symmetric(vertical: 10)),
                  onPressed: onShowList,
                  child: const Text("Show List", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, color: Color(0xFF5B7B74))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3C7F72), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 10)),
                  onPressed: onLegend,
                  child: const Text("Legend", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _PillDropdown({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFCFE9DB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFA9C8BE).withOpacity(0.9), width: 1.1)),
          child: Row(
            children: [
              Text(label, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12, color: Color(0xFF5B7B74))),
              const SizedBox(width: 6),
              Expanded(child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 12.5, color: Color(0xFF1E3B36)))),
              const Icon(Icons.expand_more, color: Color(0xFF5B7B74), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final Widget child;
  const _SheetContainer({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFD9F0E6), borderRadius: BorderRadius.vertical(top: Radius.circular(18)), boxShadow: [BoxShadow(blurRadius: 18, offset: Offset(0, -6), color: Color(0x22000000))]),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: SafeArea(top: false, child: child),
    );
  }
}

class _PlaceDetailsSheet extends StatefulWidget {
  final _Place place;
  final VoidCallback onNavigate;
  const _PlaceDetailsSheet({required this.place, required this.onNavigate});
  @override
  State<_PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<_PlaceDetailsSheet> {
  bool _showAccepted = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    const textDark = Color(0xFF1E3B36);
    const divider = Color(0xFFA9C8BE);
    const subtleText = Color(0xFF5B7B74);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 44, height: 5, decoration: BoxDecoration(color: divider.withOpacity(0.85), borderRadius: BorderRadius.circular(999))),
        const SizedBox(height: 10),
        Align(alignment: Alignment.centerLeft, child: Text(p.name, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 16, color: textDark))),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.35), borderRadius: BorderRadius.circular(14), border: Border.all(color: divider.withOpacity(0.8))),
          child: Column(
            children: [
              Row(children: [Icon(Icons.access_time, size: 18, color: p.isOpen ? Colors.orange : subtleText), const SizedBox(width: 8), Text(p.isOpen ? "Open" : "Closed", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 12.5, color: p.isOpen ? Colors.orange : subtleText)), const SizedBox(width: 10), if (p.isOpen) Text("Until ${p.closesAt}", style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12.2, color: subtleText))]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.place, size: 18, color: subtleText), const SizedBox(width: 8), Expanded(child: Text(p.address, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12.5, color: subtleText)))]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.call, size: 18, color: subtleText), const SizedBox(width: 8), Expanded(child: Text(p.phone, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12.5, color: subtleText)))]),
              if (p.type == _PlaceType.dumpingStation) ...[
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.info_outline, size: 18, color: subtleText), const SizedBox(width: 8), const Expanded(child: Text("Accepting specified waste types only.", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12.5, color: subtleText)))]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(side: const BorderSide(color: divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.white.withOpacity(0.35), padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
          onPressed: () => setState(() => _showAccepted = !_showAccepted),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Waste Categories", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 13, color: textDark)), const SizedBox(width: 8), Icon(_showAccepted ? Icons.expand_less : Icons.expand_more, color: subtleText)]),
        ),
        if (_showAccepted) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: p.accepted.map((e) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFCFE9DB), borderRadius: BorderRadius.circular(999), border: Border.all(color: divider.withOpacity(0.9))), child: Text(e, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12.2, color: textDark)))).toList()),
        ],
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3C7F72), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: widget.onNavigate, child: const Text("Navigate", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white)))),
      ],
    );
  }
}

class _NavigatePanel extends StatelessWidget {
  final String fromLabel;
  final String toLabel;
  final String etaLabel;
  final _TransportMode transportMode;
  final ValueChanged<_TransportMode> onTransportChanged;
  final VoidCallback onStartTrip;
  final VoidCallback onExit;

  const _NavigatePanel({required this.fromLabel, required this.toLabel, required this.etaLabel, required this.transportMode, required this.onTransportChanged, required this.onStartTrip, required this.onExit});

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF1E3B36);
    const divider = Color(0xFFA9C8BE);
    const softMint = Color(0xFFCFE9DB);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(color: Color(0xFFD9F0E6), borderRadius: BorderRadius.vertical(top: Radius.circular(18)), boxShadow: [BoxShadow(blurRadius: 18, offset: Offset(0, -6), color: Color(0x22000000))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [Container(width: 44, height: 5, decoration: BoxDecoration(color: divider.withOpacity(0.85), borderRadius: BorderRadius.circular(999))), const Spacer(), IconButton(onPressed: onExit, icon: const Icon(Icons.close, color: textDark))]),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: softMint, borderRadius: BorderRadius.circular(14), border: Border.all(color: divider.withOpacity(0.9), width: 1.1)),
            child: Row(
              children: [
                Column(children: const [Icon(Icons.circle, size: 10, color: Color(0xFF2D8DA1)), SizedBox(height: 6), Icon(Icons.place, size: 18, color: Color(0xFF4A8D5C))]),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(fromLabel, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12.5, color: textDark)), const SizedBox(height: 4), Text(toLabel, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 13.5, color: textDark))])),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: softMint, borderRadius: BorderRadius.circular(14), border: Border.all(color: divider.withOpacity(0.9), width: 1.1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TransportChip(icon: Icons.directions_car, selected: transportMode == _TransportMode.car, onTap: () => onTransportChanged(_TransportMode.car)),
                _TransportChip(icon: Icons.directions_bike, selected: transportMode == _TransportMode.bike, onTap: () => onTransportChanged(_TransportMode.bike)),
                _TransportChip(icon: Icons.directions_transit, selected: transportMode == _TransportMode.transit, onTap: () => onTransportChanged(_TransportMode.transit)),
                _TransportChip(icon: Icons.directions_walk, selected: transportMode == _TransportMode.walk, onTap: () => onTransportChanged(_TransportMode.walk)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: softMint, borderRadius: BorderRadius.circular(14), border: Border.all(color: divider.withOpacity(0.9), width: 1.1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(etaLabel, style: const TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 14, color: textDark)), const SizedBox(height: 4), const Text("Faster route, the usual traffic", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w200, fontSize: 12.2, color: Color(0xFF5B7B74)))])) ,
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3C7F72), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: onStartTrip, child: const Text("Start Trip", style: TextStyle(fontFamily: "Lexend", fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white)))),
        ],
      ),
    );
  }
}

class _TransportChip extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TransportChip({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const buttonGreen = Color(0xFF3C7F72);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: selected ? buttonGreen.withOpacity(0.12) : Colors.white54, borderRadius: BorderRadius.circular(999), border: Border.all(color: selected ? buttonGreen : const Color(0xFFA9C8BE).withOpacity(0.9), width: 1.2)),
        child: Icon(icon, color: selected ? buttonGreen : const Color(0xFF1E3B36)),
      ),
    );
  }
}

enum _PlaceType { wasteLocation, dumpingStation, recyclingCenter }
enum _TransportMode { car, bike, transit, walk }

class _Place {
  final String id;
  final String name;
  final _PlaceType type;
  final LatLng position;
  final String address;
  final String phone;
  final bool isOpen;
  final String closesAt;
  final int capacityPct;
  final List<String> accepted;
  final Report? originalReport;

  const _Place({required this.id, required this.name, required this.type, required this.position, required this.address, required this.phone, required this.isOpen, required this.closesAt, required this.capacityPct, required this.accepted, this.originalReport});
}
