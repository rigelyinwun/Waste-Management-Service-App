import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';
import 'waste_profile.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationsPage> {
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
  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(3.1390, 101.6869), // KL
    zoom: 13.5,
  );

  // ---------- Search ----------
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = "";

  // show search results list dropdown
  bool _showSearchList = false;

  // ---------- Data ----------
  final List<_Place> _allPlaces = const [
    _Place(
      id: "p1",
      name: "Cheras Recycling Center",
      type: _PlaceType.recyclingCenter,
      position: LatLng(3.0998, 101.7449),
      address: "Jalan Cheras, Kuala Lumpur",
      phone: "+60 14-567 8912",
      isOpen: true,
      closesAt: "11:30 PM",
      capacityPct: 70,
      accepted: ["Clothes", "Metal", "Furniture", "E-Waste"],
    ),
    _Place(
      id: "p2",
      name: "Titiwangsa Drop Point",
      type: _PlaceType.dumpingStation,
      position: LatLng(3.1737, 101.7041),
      address: "Titiwangsa, Kuala Lumpur",
      phone: "+60 12-222 1999",
      isOpen: false,
      closesAt: "—",
      capacityPct: 40,
      accepted: ["Metal", "E-Waste"],
    ),
    _Place(
      id: "p3",
      name: "Bukit Bintang Collection Hub",
      type: _PlaceType.wasteLocation,
      position: LatLng(3.1478, 101.7133),
      address: "Bukit Bintang, Kuala Lumpur",
      phone: "+60 11-888 7777",
      isOpen: true,
      closesAt: "10:00 PM",
      capacityPct: 55,
      accepted: ["Furniture", "E-Waste"],
    ),
    _Place(
      id: "p4",
      name: "KL Eco Station",
      type: _PlaceType.recyclingCenter,
      position: LatLng(3.1265, 101.6520),
      address: "Bangsar, Kuala Lumpur",
      phone: "+60 19-555 0101",
      isOpen: true,
      closesAt: "9:00 PM",
      capacityPct: 62,
      accepted: ["Clothes", "Metal"],
    ),
    _Place(
      id: "p5",
      name: "Sentul Waste Point",
      type: _PlaceType.wasteLocation,
      position: LatLng(3.1860, 101.6930),
      address: "Sentul, Kuala Lumpur",
      phone: "+60 10-303 4488",
      isOpen: true,
      closesAt: "8:30 PM",
      capacityPct: 28,
      accepted: ["Furniture"],
    ),
    _Place(
      id: "p6",
      name: "Ampang Dumping Station",
      type: _PlaceType.dumpingStation,
      position: LatLng(3.1569, 101.7638),
      address: "Ampang, Selangor",
      phone: "+60 13-909 1212",
      isOpen: false,
      closesAt: "—",
      capacityPct: 88,
      accepted: ["Metal", "Furniture"],
    ),
    _Place(
      id: "p7",
      name: "Sri Petaling Recycle Point",
      type: _PlaceType.recyclingCenter,
      position: LatLng(3.0581, 101.6915),
      address: "Sri Petaling, Kuala Lumpur",
      phone: "+60 16-777 3232",
      isOpen: true,
      closesAt: "10:30 PM",
      capacityPct: 35,
      accepted: ["Clothes", "E-Waste"],
    ),
    _Place(
      id: "p8",
      name: "Setapak Collection Point",
      type: _PlaceType.wasteLocation,
      position: LatLng(3.2068, 101.7250),
      address: "Setapak, Kuala Lumpur",
      phone: "+60 17-111 4545",
      isOpen: true,
      closesAt: "11:00 PM",
      capacityPct: 50,
      accepted: ["Metal", "E-Waste"],
    ),
  ];

  final ReportService _reportService = ReportService();
  StreamSubscription? _reportsSub;
  List<Report> _firestoreReports = [];

  // ---------- Filters ----------
  final Set<_PlaceType> _selectedTypes = {
    _PlaceType.wasteLocation,
    _PlaceType.dumpingStation,
    _PlaceType.recyclingCenter,
  };
  double _distanceKm = 6;
  static const double _distanceMax = 100;

  // ---------- Selected place ----------
  _Place? _selectedPlace;
  bool _navigateMode = false;

  // ---------- Route ----------
  final LatLng _userLocation = const LatLng(3.1390, 101.6869);
  _TransportMode _transportMode = _TransportMode.car;
  List<LatLng> _routePoints = const [];
  String _routeEtaLabel = "4 min (800m)";

  // ---------- Map ----------
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _rebuildMarkers();

    _reportsSub = _reportService.getAllReports().listen((reports) {
      setState(() {
        _firestoreReports = reports;
        _rebuildMarkers();
      });
    });

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() => _showSearchList = false);
      }
    });
  }

  @override
  void dispose() {
    _reportsSub?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  double rs(double v) => v;

  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------
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
    final staticPlaces = _filteredPlaces;
    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: _userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "You are here"),
      ),
    );

    // Static places
    for (final p in staticPlaces) {
      markers.add(
        Marker(
          markerId: MarkerId(p.id),
          position: p.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _markerHueForType(p.type),
          ),
          onTap: () {
            setState(() {
              _selectedPlace = p;
              _navigateMode = false;
              _polylines = {};
              _routePoints = const [];
            });
            _openPlaceSheet(p);
          },
        ),
      );
    }

    // Firestore reports
    if (_selectedTypes.contains(_PlaceType.wasteLocation)) {
      for (final r in _firestoreReports) {
        final pos = LatLng(r.location.latitude, r.location.longitude);
        final km = _haversineKm(_userLocation, pos);
        if (km > _distanceKm) continue;

        markers.add(
          Marker(
            markerId: MarkerId("fs_${r.reportId}"),
            position: pos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WasteProfilePage(report: r),
                ),
              );
            },
          ),
        );
      }
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
                    typeRow("Recycling Centers", _PlaceType.recyclingCenter),
                    const SizedBox(height: 12),
                    Container(height: 1, color: divider.withValues(alpha: 0.7)),
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
                        inactiveTrackColor: divider.withValues(alpha: 0.7),
                        thumbColor: buttonGreen,
                        overlayColor: buttonGreen.withValues(alpha: 0.12),
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
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => setLocal(() {
                              tmpTypes
                                ..clear()
                                ..addAll({
                                  _PlaceType.wasteLocation,
                                  _PlaceType.dumpingStation,
                                  _PlaceType.recyclingCenter,
                                });
                              tmpDistance = 6;
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
  // Place sheet
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
      case _TransportMode.car:
        return 350;
      case _TransportMode.bike:
        return 220;
      case _TransportMode.transit:
        return 280;
      case _TransportMode.walk:
        return 80;
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
  // List & Legend
  // ---------------------------------------------------------------------------
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
                  color: divider.withValues(alpha: 0.8),
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
                      color: divider.withValues(alpha: 0.6),
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
        return _SheetContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 2),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: divider.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    "Legend",
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
              ),
              const SizedBox(height: 8),
              _legendRow(
                color: _chipColorForType(_PlaceType.dumpingStation),
                icon: _iconForType(_PlaceType.dumpingStation),
                label: "Dumping Station",
              ),
              const SizedBox(height: 8),
              _legendRow(
                color: _chipColorForType(_PlaceType.recyclingCenter),
                icon: _iconForType(_PlaceType.recyclingCenter),
                label: "Recycling Center",
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _legendRow({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 12),
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
                      myLocationEnabled: false,
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

                    // Search bar + dropdown list
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

                    // Map controls
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

                    // Bottom panel
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _navigateMode
                          ? _NavigatePanel(
                              fromLabel: "Lakefront Residence",
                              toLabel: _selectedPlace?.name ?? "Destination",
                              etaLabel: _routeEtaLabel,
                              transportMode: _transportMode,
                              onTransportChanged: _updateTransport,
                              onStartTrip: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Start Trip pressed"),
                                  ),
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
    if (types.length == 3) return "All";
    final names = <String>[];
    if (types.contains(_PlaceType.wasteLocation)) names.add("Waste");
    if (types.contains(_PlaceType.dumpingStation)) names.add("Dumping");
    if (types.contains(_PlaceType.recyclingCenter)) names.add("Recycle");
    return names.join(", ");
  }

  Color _chipColorForType(_PlaceType t) {
    switch (t) {
      case _PlaceType.wasteLocation:
        return const Color(0xFFB84B4B);
      case _PlaceType.dumpingStation:
        return const Color(0xFF4A8D5C);
      case _PlaceType.recyclingCenter:
        return const Color(0xFF2D8DA1);
    }
  }

  IconData _iconForType(_PlaceType t) {
    switch (t) {
      case _PlaceType.wasteLocation:
        return Icons.location_on;
      case _PlaceType.dumpingStation:
        return Icons.delete_outline;
      case _PlaceType.recyclingCenter:
        return Icons.recycling;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  static double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final lat1 = _deg2rad(a.latitude);
    final lat2 = _deg2rad(b.latitude);

    final h =
        sin(dLat / 2) * sin(dLat / 2) +
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
      final lat =
          (1 - t) * (1 - t) * start.latitude +
          2 * (1 - t) * t * control.latitude +
          t * t * end.latitude;
      final lng =
          (1 - t) * (1 - t) * start.longitude +
          2 * (1 - t) * t * control.longitude +
          t * t * end.longitude;
      points.add(LatLng(lat, lng));
    }
    return points;
  }
}

// ============================================================================
// Search dropdown list
// ============================================================================

class _SearchResultsDropdown extends StatelessWidget {
  final List<_Place> results;
  final ValueChanged<_Place> onTapItem;

  const _SearchResultsDropdown({
    required this.results,
    required this.onTapItem,
  });

  static const Color cardMint = Color(0xFFD9F0E6);
  static const Color textDark = Color(0xFF1E3B36);
  static const Color subtleText = Color(0xFF5B7B74);
  static const Color divider = Color(0xFFA9C8BE);

  @override
  Widget build(BuildContext context) {
    final list = results.take(6).toList();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: cardMint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: divider.withValues(alpha: 0.9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 6),
            color: Color(0x1A000000),
          ),
        ],
      ),
      child: list.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                "No matching locations found.",
                style: TextStyle(
                  fontFamily: "Lexend",
                  fontWeight: FontWeight.w200,
                  fontSize: 12.5,
                  color: subtleText,
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  Container(height: 1, color: divider.withValues(alpha: 0.6)),
              itemBuilder: (_, i) {
                final p = list[i];
                return ListTile(
                  dense: true,
                  onTap: () => onTapItem(p),
                  title: Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: "Lexend",
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                      color: textDark,
                    ),
                  ),
                  subtitle: Text(
                    p.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: "Lexend",
                      fontWeight: FontWeight.w200,
                      fontSize: 12,
                      color: subtleText,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================================
// Small widgets
// ============================================================================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onFilterTap,
    required this.onClear,
  });

  static const Color softMint = Color(0xFFCFE9DB);
  static const Color pillGreen = Color(0xFF4B9E92);
  static const Color textDark = Color(0xFF1E3B36);

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: softMint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: pillGreen.withValues(alpha: 0.55),
          width: 1.6,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Color(0x1A000000),
          ),
        ],
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
              style: const TextStyle(
                fontFamily: "Lexend",
                fontWeight: FontWeight.w200,
                fontSize: 13.5,
                color: textDark,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: "Lexend",
                  fontWeight: FontWeight.w200,
                  fontSize: 13.5,
                  color: textDark.withValues(alpha: 0.55),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (hasText)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: textDark),
              ),
            ),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.tune, color: textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  static const Color softMint = Color(0xFFCFE9DB);
  static const Color divider = Color(0xFFA9C8BE);
  static const Color textDark = Color(0xFF1E3B36);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: softMint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: divider.withValues(alpha: 0.9),
              width: 1.2,
            ),
          ),
          child: Icon(icon, color: textDark),
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

  const _NearbyPanel({
    required this.count,
    required this.categoryLabel,
    required this.distanceLabel,
    required this.onShowList,
    required this.onLegend,
    required this.onTapCategory,
    required this.onTapDistance,
  });

  static const Color bg = Color(0xFFD9F0E6);
  static const Color textDark = Color(0xFF1E3B36);
  static const Color subtleText = Color(0xFF5B7B74);
  static const Color buttonGreen = Color(0xFF3C7F72);
  static const Color divider = Color(0xFFA9C8BE);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, -6),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: divider.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "$count Waste Locations Nearby",
                style: const TextStyle(
                  fontFamily: "Lexend",
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PillDropdown(
                  label: "Category:",
                  value: categoryLabel,
                  onTap: onTapCategory,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillDropdown(
                  label: "Distance:",
                  value: distanceLabel,
                  onTap: onTapDistance,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onShowList,
                  child: const Text(
                    "Show List",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontWeight: FontWeight.w500,
                      color: subtleText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onLegend,
                  child: const Text(
                    "Legend",
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
      ),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PillDropdown({
    required this.label,
    required this.value,
    required this.onTap,
  });

  static const Color softMint = Color(0xFFCFE9DB);
  static const Color divider = Color(0xFFA9C8BE);
  static const Color textDark = Color(0xFF1E3B36);
  static const Color subtleText = Color(0xFF5B7B74);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: softMint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: divider.withValues(alpha: 0.9),
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: "Lexend",
                  fontWeight: FontWeight.w200,
                  fontSize: 12,
                  color: subtleText,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "Lexend",
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                    color: textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more, color: subtleText),
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

  static const Color cardMint = Color(0xFFD9F0E6);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: cardMint,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, -6),
            color: Color(0x22000000),
          ),
        ],
      ),
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

  static const Color textDark = Color(0xFF1E3B36);
  static const Color subtleText = Color(0xFF5B7B74);
  static const Color buttonGreen = Color(0xFF3C7F72);
  static const Color divider = Color(0xFFA9C8BE);

  @override
  Widget build(BuildContext context) {
    final p = widget.place;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: divider.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            p.name,
            style: const TextStyle(
              fontFamily: "Lexend",
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: textDark,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: divider.withValues(alpha: 0.8),
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: p.isOpen ? Colors.orange : subtleText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    p.isOpen ? "Opened" : "Closed",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      color: p.isOpen ? Colors.orange : subtleText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (p.isOpen)
                    Text(
                      "Closes ${p.closesAt}",
                      style: const TextStyle(
                        fontFamily: "Lexend",
                        fontWeight: FontWeight.w200,
                        fontSize: 12.2,
                        color: subtleText,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, size: 18, color: subtleText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.address,
                      style: const TextStyle(
                        fontFamily: "Lexend",
                        fontWeight: FontWeight.w200,
                        fontSize: 12.5,
                        color: subtleText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.call, size: 18, color: subtleText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.phone,
                      style: const TextStyle(
                        fontFamily: "Lexend",
                        fontWeight: FontWeight.w200,
                        fontSize: 12.5,
                        color: subtleText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: subtleText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${p.capacityPct}% Capacity",
                      style: const TextStyle(
                        fontFamily: "Lexend",
                        fontWeight: FontWeight.w200,
                        fontSize: 12.5,
                        color: subtleText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: divider),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.35),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          onPressed: () => setState(() => _showAccepted = !_showAccepted),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "View Accepted Waste Types",
                style: TextStyle(
                  fontFamily: "Lexend",
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: textDark,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _showAccepted ? Icons.expand_less : Icons.expand_more,
                color: subtleText,
              ),
            ],
          ),
        ),
        if (_showAccepted) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.place.accepted
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFE9DB),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: divider.withValues(alpha: 0.9)),
                    ),
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontFamily: "Lexend",
                        fontWeight: FontWeight.w200,
                        fontSize: 12.2,
                        color: textDark,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: widget.onNavigate,
            child: const Text(
              "Navigate",
              style: TextStyle(
                fontFamily: "Lexend",
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
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

  const _NavigatePanel({
    required this.fromLabel,
    required this.toLabel,
    required this.etaLabel,
    required this.transportMode,
    required this.onTransportChanged,
    required this.onStartTrip,
    required this.onExit,
  });

  static const Color bg = Color(0xFFD9F0E6);
  static const Color textDark = Color(0xFF1E3B36);
  static const Color subtleText = Color(0xFF5B7B74);
  static const Color buttonGreen = Color(0xFF3C7F72);
  static const Color divider = Color(0xFFA9C8BE);
  static const Color softMint = Color(0xFFCFE9DB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, -6),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: divider.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onExit,
                icon: const Icon(Icons.close, color: textDark),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: softMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: divider.withValues(alpha: 0.9),
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Column(
                  children: const [
                    Icon(Icons.circle, size: 10, color: Color(0xFF2D8DA1)),
                    SizedBox(height: 6),
                    Icon(Icons.place, size: 18, color: Color(0xFF4A8D5C)),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fromLabel,
                        style: const TextStyle(
                          fontFamily: "Lexend",
                          fontWeight: FontWeight.w200,
                          fontSize: 12.5,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toLabel,
                        style: const TextStyle(
                          fontFamily: "Lexend",
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.swap_vert, color: subtleText),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: softMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: divider.withValues(alpha: 0.9),
                width: 1.1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TransportChip(
                  icon: Icons.directions_car,
                  selected: transportMode == _TransportMode.car,
                  onTap: () => onTransportChanged(_TransportMode.car),
                ),
                _TransportChip(
                  icon: Icons.directions_bike,
                  selected: transportMode == _TransportMode.bike,
                  onTap: () => onTransportChanged(_TransportMode.bike),
                ),
                _TransportChip(
                  icon: Icons.directions_transit,
                  selected: transportMode == _TransportMode.transit,
                  onTap: () => onTransportChanged(_TransportMode.transit),
                ),
                _TransportChip(
                  icon: Icons.directions_walk,
                  selected: transportMode == _TransportMode.walk,
                  onTap: () => onTransportChanged(_TransportMode.walk),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: softMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: divider.withValues(alpha: 0.9),
                width: 1.1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etaLabel,
                  style: const TextStyle(
                    fontFamily: "Lexend",
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Faster route, the usual traffic",
                  style: TextStyle(
                    fontFamily: "Lexend",
                    fontWeight: FontWeight.w200,
                    fontSize: 12.2,
                    color: subtleText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onStartTrip,
              child: const Text(
                "Start Trip",
                style: TextStyle(
                  fontFamily: "Lexend",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportChip extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TransportChip({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const Color buttonGreen = Color(0xFF3C7F72);
  static const Color textDark = Color(0xFF1E3B36);
  static const Color divider = Color(0xFFA9C8BE);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? buttonGreen.withValues(alpha: 0.12)
              : Colors.white54,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? buttonGreen : divider.withValues(alpha: 0.9),
            width: 1.2,
          ),
        ),
        child: Icon(icon, color: selected ? buttonGreen : textDark),
      ),
    );
  }
}

// ============================================================================
// Models
// ============================================================================

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

  const _Place({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.address,
    required this.phone,
    required this.isOpen,
    required this.closesAt,
    required this.capacityPct,
    required this.accepted,
  });
}
