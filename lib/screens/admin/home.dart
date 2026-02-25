import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../services/user_service.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import '../../models/dumping_station_model.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'waste_profile.dart';

class AdminHomePage extends StatefulWidget {
  final Function(int)? onTabChange;
  const AdminHomePage({super.key, this.onTabChange});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

enum _SummaryRange { week, month, year }

class _AdminHomePageState extends State<AdminHomePage> {
  static const Color bg = Color(0xFFE6F1ED);
  static const Color pillGreen = Color(0xFF4B9E92);

  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();
  final UserService _userService = UserService();

  _SummaryRange _range = _SummaryRange.week;
  List<Report> _allReports = [];
  List<DumpingStation> _allStations = [];
  AppUser? _currentUserProfile;
  LatLng _lastKnownLocation = const LatLng(3.1390, 101.6869); // KL
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _fetchUserProfile();
    await _getCurrentLocation();
    _loadData();
  }

  Future<void> _fetchUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _userService.fetchUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _currentUserProfile = profile;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _lastKnownLocation = LatLng(position.latitude, position.longitude);
          });
        }
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _loadData() {
    // Listen to reports
    final role = _currentUserProfile?.role.toLowerCase();
    final reportStream = (role == 'business' || role == 'company' || role == 'admin')
        ? _reportService.getReportsByCompany(_currentUserProfile!.uid)
        : _reportService.getUnmatchedReports();

    reportStream.listen((reports) {
      if (mounted) {
        setState(() {
          _allReports = reports;
          _updateMarkers();
          _isLoading = false;
        });
      }
    });

    // Listen to stations
    FirebaseFirestore.instance.collection('dumping_stations').snapshots().listen((snapshot) {
      final stations = snapshot.docs.map((doc) => DumpingStation.fromMap(doc.data())).toList();
      if (mounted) {
        setState(() {
          _allStations = stations;
          _updateMarkers();
        });
      }
    });
  }

  void _updateMarkers() {
    final Set<Marker> newMarkers = {};

    // Waste Reports (Red)
    for (var report in _allReports) {
      newMarkers.add(
        Marker(
          markerId: MarkerId("report_${report.reportId}"),
          position: LatLng(report.location.latitude, report.location.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: report.aiAnalysis?.category ?? "Waste",
            snippet: report.description,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WasteProfilePage(report: report),
                ),
              );
            },
          ),
        ),
      );
    }

    // Stations (Green)
    for (var station in _allStations) {
      final gp = station.location;
      newMarkers.add(
        Marker(
          markerId: MarkerId("station_${station.stationId}"),
          position: LatLng(gp.latitude, gp.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: "Dumping Station",
            snippet: station.categories.join(", "),
          ),
        ),
      );
        }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  void _openDumpingStations() {
    Navigator.of(context).pushNamed('/company/dumping-stations');
  }

  void _openSummaryDashboard() {
    if (widget.onTabChange != null) {
      widget.onTabChange!(2);
    } else {
      Navigator.of(context).pushNamed('/company/summary-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    double s(double v) => v * (w / 423.0);
    double rs(double v) => v * (h / 917.0);

    final topPending = _allReports.take(3).toList();

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(s(18), rs(16), s(18), rs(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Top Pending Requests",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: s(20),
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: s(12)),
                      _PillButton(
                        label: "View All  →",
                        color: pillGreen,
                        onTap: () {
                          if (widget.onTabChange != null) {
                            widget.onTabChange!(1);
                          } else {
                            Navigator.pushNamed(context, '/company/reports');
                          }
                        },
                        height: rs(44),
                        paddingH: s(18),
                        textSize: s(12),
                      ),
                    ],
                  ),
                  SizedBox(height: rs(14)),

                  SizedBox(
                    height: rs(178),
                    child: topPending.isEmpty
                        ? const Center(child: Text("No pending requests"))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (_, _) => SizedBox(width: s(14)),
                            itemCount: topPending.length,
                            itemBuilder: (context, index) {
                              final p = topPending[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WasteProfilePage(report: p),
                                  ),
                                ),
                                child: _RequestCard(
                                  s: s,
                                  rs: rs,
                                  width: s(156),
                                  imageWidget: p.imageUrl.startsWith('http')
                                      ? Image.network(p.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                                      : Image.memory(base64Decode(p.imageUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                                  category: p.aiAnalysis?.category ?? "analyzing",
                                  weight: "Unknown", // Weight not in model
                                  location: p.locationName,
                                ),
                              );
                            },
                          ),
                  ),

                  SizedBox(height: rs(18)),

                  // ===== Real Map =====
                  Container(
                    width: double.infinity,
                    height: rs(360),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(s(18)),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color(0x14000000),
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _lastKnownLocation,
                            zoom: 14,
                          ),
                          onMapCreated: (controller) => _mapController = controller,
                          markers: _markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                        ),
                        Positioned(
                          top: rs(12),
                          right: s(12),
                          child: _PillButton(
                            label: "Dumping Stations  →",
                            color: pillGreen,
                            onTap: _openDumpingStations,
                            height: rs(42),
                            paddingH: s(14),
                            textSize: s(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: rs(18)),

                  // ===== Summary =====
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Summary",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: s(18),
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: s(10)),
                      _PillButton(
                        label: "View More  →",
                        color: pillGreen,
                        onTap: _openSummaryDashboard,
                        height: rs(40),
                        paddingH: s(16),
                        textSize: s(12),
                      ),
                    ],
                  ),
                  SizedBox(height: rs(10)),

                  _SummaryCard(
                    s: s,
                    rs: rs,
                    pillGreen: pillGreen,
                    range: _range,
                    totalReports: _allReports.length,
                    totalCollected: 0, // Need logic for collected
                    onChangeRange: (r) => setState(() => _range = r),
                  ),

                  SizedBox(height: rs(8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   Reusable Pill Button
========================= */
class _PillButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double height;
  final double paddingH;
  final double textSize;

  const _PillButton({
    required this.label,
    required this.color,
    required this.onTap,
    required this.height,
    required this.paddingH,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: paddingH),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'LexendExa',
            fontSize: textSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final double Function(double) s;
  final double Function(double) rs;
  final double width;
  final Widget imageWidget;
  final String category;
  final String weight;
  final String location;

  const _RequestCard({
    required this.s,
    required this.rs,
    required this.width,
    required this.imageWidget,
    required this.category,
    required this.weight,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.all(s(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s(18)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Color(0x14000000),
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(s(14)),
              child: SizedBox(
                height: rs(70),
                width: double.infinity,
                child: imageWidget,
              ),
            ),
            SizedBox(height: rs(6)),

            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width - s(22)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TinyText(
                          "AI Category:",
                          s: s,
                          fontSize: s(9.5),
                          weight: FontWeight.w400,
                        ),
                        SizedBox(height: rs(2)),
                        _TinyText(
                          category,
                          s: s,
                          fontSize: s(10),
                          weight: FontWeight.w900,
                        ),
                        SizedBox(height: rs(2)),
                        _TinyText(
                          "Estimated weight: $weight",
                          s: s,
                          fontSize: s(9),
                          weight: FontWeight.w700,
                        ),
                        SizedBox(height: rs(5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: s(12),
                              color: Colors.black.withValues(alpha: 0.70),
                            ),
                            SizedBox(width: s(4)),
                            Flexible(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'LexendExa',
                                  fontSize: s(8.4),
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                  color: Colors.black.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyText extends StatelessWidget {
  final String text;
  final double Function(double) s;
  final double fontSize;
  final FontWeight weight;

  const _TinyText(
    this.text, {
    required this.s,
    required this.fontSize,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'LexendExa',
        fontSize: fontSize,
        fontWeight: weight,
        height: 1.1,
        color: Colors.black,
      ),
    );
  }
}

/* =========================
   Summary Card
========================= */
class _SummaryCard extends StatelessWidget {
  final double Function(double) s;
  final double Function(double) rs;
  final Color pillGreen;
  final _SummaryRange range;
  final int totalReports;
  final int totalCollected;
  final ValueChanged<_SummaryRange> onChangeRange;

  const _SummaryCard({
    required this.s,
    required this.rs,
    required this.pillGreen,
    required this.range,
    required this.totalReports,
    required this.totalCollected,
    required this.onChangeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(18)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x14000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Filter",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: s(12),
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              _SegmentButton(
                s: s,
                rs: rs,
                label: "Week",
                selected: range == _SummaryRange.week,
                onTap: () => onChangeRange(_SummaryRange.week),
                selectedColor: pillGreen,
              ),
              SizedBox(width: s(8)),
              _SegmentButton(
                s: s,
                rs: rs,
                label: "Month",
                selected: range == _SummaryRange.month,
                onTap: () => onChangeRange(_SummaryRange.month),
                selectedColor: pillGreen,
              ),
              SizedBox(width: s(8)),
              _SegmentButton(
                s: s,
                rs: rs,
                label: "Year",
                selected: range == _SummaryRange.year,
                onTap: () => onChangeRange(_SummaryRange.year),
                selectedColor: pillGreen,
              ),
            ],
          ),
          SizedBox(height: rs(12)),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  s: s,
                  title: "Total Reports",
                  value: "$totalReports",
                  icon: Icons.receipt_long_outlined,
                  showChevron: false,
                ),
              ),
              SizedBox(width: s(10)),
              Expanded(
                child: _MetricTile(
                  s: s,
                  title: "Total Collected",
                  value: "$totalCollected",
                  icon: Icons.check_circle_outline,
                  showChevron: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final double Function(double) s;
  final String title;
  final String value;
  final IconData icon;
  final bool showChevron;

  const _MetricTile({
    required this.s,
    required this.title,
    required this.value,
    required this.icon,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(s(12)),
      decoration: BoxDecoration(
        color: const Color(0xFF2E746A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(s(16)),
      ),
      child: Row(
          children: [
            Container(
              width: s(40),
              height: s(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(s(14)),
              ),
              child: Icon(icon, size: s(20), color: const Color(0xFF2E746A)),
            ),
            SizedBox(width: s(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'LexendExa',
                      fontSize: s(9.5),
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                  ),
                  SizedBox(height: s(4)),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: s(18),
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                size: s(20),
                color: Colors.black.withValues(alpha: 0.35),
              ),
          ],
        ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final double Function(double) s;
  final double Function(double) rs;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _SegmentButton({
    required this.s,
    required this.rs,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: rs(32),
        padding: EdgeInsets.symmetric(horizontal: s(12)),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? selectedColor
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'LexendExa',
            fontSize: s(10),
            fontWeight: FontWeight.w900,
            color: selected
                ? Colors.white
                : Colors.black.withValues(alpha: 0.70),
          ),
        ),
      ),
    );
  }
}