import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

enum _SummaryRange { week, month, year }

enum _ReportStatus { pending, accepted, collected }

class _AdminHomePageState extends State<AdminHomePage> {
  static const Color bg = Color(0xFFE6F1ED);
  static const Color headerGreen = Color(0xFF2E746A);
  static const Color pillGreen = Color(0xFF4B9E92);

  int _navIndex = 0;
  _SummaryRange _range = _SummaryRange.week;

  int? _selectedPinIndex;

  int get _totalReports {
    switch (_range) {
      case _SummaryRange.week:
        return 28;
      case _SummaryRange.month:
        return 112;
      case _SummaryRange.year:
        return 1320;
    }
  }

  int get _totalCollected {
    switch (_range) {
      case _SummaryRange.week:
        return 19;
      case _SummaryRange.month:
        return 86;
      case _SummaryRange.year:
        return 1088;
    }
  }

  String get _rangeLabel {
    switch (_range) {
      case _SummaryRange.week:
        return "Week";
      case _SummaryRange.month:
        return "Month";
      case _SummaryRange.year:
        return "Year";
    }
  }

  final List<_PendingRequest> _allRequests = [
    _PendingRequest(
      id: "req_01",
      category: "Fabric",
      weight: "5kg",
      location: "Wangsa Permai • ~200m",
      icon: Icons.checkroom,
      status: _ReportStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    _PendingRequest(
      id: "req_02",
      category: "Furniture",
      weight: "20kg",
      location: "PV12 • ~0.3km",
      icon: Icons.chair_alt_outlined,
      status: _ReportStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
    _PendingRequest(
      id: "req_03",
      category: "Metal",
      weight: "12kg",
      location: "Taman Melati • ~2.0km",
      icon: Icons.construction_outlined,
      status: _ReportStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
    ),
    _PendingRequest(
      id: "req_04",
      category: "E-waste",
      weight: "4kg",
      location: "Gombak • ~3.4km",
      icon: Icons.memory_outlined,
      status: _ReportStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    _PendingRequest(
      id: "req_05",
      category: "Furniture",
      weight: "15kg",
      location: "Setapak • ~0.8km",
      icon: Icons.inventory_2_outlined,
      status: _ReportStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    _PendingRequest(
      id: "req_06",
      category: "Metal",
      weight: "9kg",
      location: "Batu Caves • ~4.5km",
      icon: Icons.construction_outlined,
      status: _ReportStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
  ];

  List<_PendingRequest> get _pendingOnlySortedLatest {
    final list =
        _allRequests.where((r) => r.status == _ReportStatus.pending).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<_PendingRequest> get _top3PendingLatest {
    final list = _pendingOnlySortedLatest;
    return list.length <= 3 ? list : list.sublist(0, 3);
  }

  final List<_ReportItem> _latestReports = [
    _ReportItem(
      id: "rep_01",
      title: "Old Sofa",
      wasteType: "Furniture",
      weight: "20kg",
      distance: "1.2km",
      location: "Wangsa Permai",
      status: _ReportStatus.pending,
      timeAgo: "12m ago",
      icon: Icons.chair_alt_outlined,
    ),
    _ReportItem(
      id: "rep_02",
      title: "Mixed Clothes Bundle",
      wasteType: "Clothes",
      weight: "6kg",
      distance: "0.6km",
      location: "Setapak",
      status: _ReportStatus.pending,
      timeAgo: "1h ago",
      icon: Icons.checkroom,
    ),
    _ReportItem(
      id: "rep_03",
      title: "Scrap Metal Pieces",
      wasteType: "Metal",
      weight: "12kg",
      distance: "2.0km",
      location: "Taman Melati",
      status: _ReportStatus.accepted,
      timeAgo: "3h ago",
      icon: Icons.construction_outlined,
    ),
    _ReportItem(
      id: "rep_04",
      title: "E-waste Box",
      wasteType: "E-waste",
      weight: "4kg",
      distance: "3.4km",
      location: "Gombak",
      status: _ReportStatus.collected,
      timeAgo: "6h ago",
      icon: Icons.memory_outlined,
    ),
    _ReportItem(
      id: "rep_05",
      title: "Wooden Crates x3",
      wasteType: "Furniture",
      weight: "15kg",
      distance: "0.3km",
      location: "PV12",
      status: _ReportStatus.pending,
      timeAgo: "Yesterday",
      icon: Icons.inventory_2_outlined,
    ),
  ];

  final List<_MapPin> _pins = [
    _MapPin(
      x: 0.62,
      y: 0.34,
      type: _MapPinType.report,
      color: Color(0xFF7A1F1F),
      condition: "Good",
      titleLine: "Waste 3x Wooden Crates",
      distanceLine: "Distance: 0.3km",
    ),
    _MapPin(
      x: 0.35,
      y: 0.48,
      type: _MapPinType.report,
      color: Color(0xFF7A1F1F),
      condition: "Normal",
      titleLine: "Waste Mixed Clothes Bundle",
      distanceLine: "Distance: 0.6km",
    ),
    _MapPin(
      x: 0.70,
      y: 0.66,
      type: _MapPinType.report,
      color: Color(0xFF7A1F1F),
      condition: "Good",
      titleLine: "Waste Old Sofa",
      distanceLine: "Distance: 1.2km",
    ),
    _MapPin(
      x: 0.88,
      y: 0.44,
      type: _MapPinType.station,
      color: Color(0xFF2CCB68),
      condition: "Active",
      titleLine: "Station Recycling Point A",
      distanceLine: "Distance: 0.7km",
    ),
    _MapPin(
      x: 0.12,
      y: 0.78,
      type: _MapPinType.station,
      color: Color(0xFF2CCB68),
      condition: "Active",
      titleLine: "Station Drop-off Point B",
      distanceLine: "Distance: 1.1km",
    ),
  ];

  // ===== Actions / Nav =====
  void _openNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationsSheet(
        headerGreen: headerGreen,
        pillGreen: pillGreen,
        bg: bg,
      ),
    );
  }

  void _openPendingRequestsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PendingRequestsPage(
          headerGreen: headerGreen,
          pillGreen: pillGreen,
          items: _pendingOnlySortedLatest,
        ),
      ),
    );
  }

  void _openDumpingStations() {
    Navigator.of(context).pushNamed('/company/dumping-stations');
  }

  void _openAllReports() {
    Navigator.of(context).pushNamed('/company/reports');
  }

  void _openSummaryDashboard() {
    Navigator.of(context).pushNamed('/company/summary-dashboard');
  }

  void _showMetricPopup({required String title, required int value}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MetricPopup(
        headerGreen: headerGreen,
        pillGreen: pillGreen,
        title: title,
        subtitle: "Range: $_rangeLabel",
        value: value,
      ),
    );
  }

  void _openReportDetailsSheet(_ReportItem it) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportDetailsSheet(
        headerGreen: headerGreen,
        pillGreen: pillGreen,
        item: it,
        onAccept: it.status == _ReportStatus.pending
            ? () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Accepted request.")),
                );
              }
            : null,
        onMarkCollected:
            (it.status == _ReportStatus.pending ||
                it.status == _ReportStatus.accepted)
            ? () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Marked as collected.")),
                );
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    double s(double v) => v * (w / 423.0);
    double rs(double v) => v * (h / 917.0);

    final topPending = _top3PendingLatest;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            Container(
              height: rs(86),
              width: double.infinity,
              color: headerGreen,
              padding: EdgeInsets.symmetric(horizontal: s(18)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: s(42),
                        height: s(42),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: s(10)),
                      SizedBox(
                        height: s(22),
                        child: Image.asset(
                          'assets/sw.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: _openNotificationsSheet,
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: s(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Content =====
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(s(18), rs(16), s(18), rs(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== TOP PENDING REQUESTS =====
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
                          onTap: _openPendingRequestsPage,
                          height: rs(44),
                          paddingH: s(18),
                          textSize: s(12),
                        ),
                      ],
                    ),
                    SizedBox(height: rs(14)),

                    SizedBox(
                      height: rs(178),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, _) => SizedBox(width: s(14)),
                        itemCount: topPending.length,
                        itemBuilder: (context, index) {
                          final p = topPending[index];
                          return _RequestCard(
                            s: s,
                            rs: rs,
                            width: s(156),
                            imageWidget: _PhotoMock(icon: p.icon),
                            category: p.category,
                            weight: p.weight,
                            location: p.location,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: rs(18)),

                    // ===== Map Preview =====
                    _OverviewMapCard(
                      s: s,
                      rs: rs,
                      pillGreen: pillGreen,
                      onDumpingStations: _openDumpingStations,
                      pins: _pins,
                      selectedPinIndex: _selectedPinIndex,
                      onTapPin: (idx) =>
                          setState(() => _selectedPinIndex = idx),
                      onCloseCallout: () =>
                          setState(() => _selectedPinIndex = null),
                    ),

                    SizedBox(height: rs(18)),

                    // ===== Latest reports =====
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Latest Reports",
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
                          label: "View All  →",
                          color: pillGreen,
                          onTap: _openAllReports,
                          height: rs(40),
                          paddingH: s(16),
                          textSize: s(12),
                        ),
                      ],
                    ),
                    SizedBox(height: rs(10)),

                    _LatestReportsList(
                      s: s,
                      rs: rs,
                      items: _latestReports,
                      onTapItem: _openReportDetailsSheet,
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
                      totalReports: _totalReports,
                      totalCollected: _totalCollected,
                      onChangeRange: (r) => setState(() => _range = r),
                      onTapTotalReports: () => _showMetricPopup(
                        title: "Total Reports",
                        value: _totalReports,
                      ),
                      onTapTotalCollected: () => _showMetricPopup(
                        title: "Total Collected",
                        value: _totalCollected,
                      ),
                    ),

                    SizedBox(height: rs(8)),
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

/* =========================
   Pending Request card (FIXED RenderFlex overflow)
   - Uses LayoutBuilder and flexible heights
========================= */
class _PhotoMock extends StatelessWidget {
  final IconData icon;
  const _PhotoMock({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      alignment: Alignment.center,
      child: Icon(icon, size: 42, color: Colors.black.withValues(alpha: 0.30)),
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
   Map Card
   CHANGE:
   - Station markers are GREEN ELLIPSE markers (not green pins)
   - Fix lint: local identifier no underscore (pinOffset)
========================= */
class _OverviewMapCard extends StatelessWidget {
  final double Function(double) s;
  final double Function(double) rs;
  final Color pillGreen;
  final VoidCallback onDumpingStations;

  final List<_MapPin> pins;
  final int? selectedPinIndex;
  final void Function(int index) onTapPin;
  final VoidCallback onCloseCallout;

  const _OverviewMapCard({
    required this.s,
    required this.rs,
    required this.pillGreen,
    required this.onDumpingStations,
    required this.pins,
    required this.selectedPinIndex,
    required this.onTapPin,
    required this.onCloseCallout,
  });

  @override
  Widget build(BuildContext context) {
    final sel = selectedPinIndex;

    return Container(
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
      child: LayoutBuilder(
        builder: (context, box) {
          final bw = box.maxWidth;
          final bh = box.maxHeight;

          Offset pinOffset(int i) => Offset(pins[i].x * bw, pins[i].y * bh);

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFEFEDE6),
                  child: CustomPaint(painter: _SimpleMapPainter()),
                ),
              ),

              Positioned(
                top: rs(12),
                right: s(12),
                child: _PillButton(
                  label: "Dumping Stations  →",
                  color: pillGreen,
                  onTap: onDumpingStations,
                  height: rs(42),
                  paddingH: s(14),
                  textSize: s(12),
                ),
              ),

              // User dot
              Positioned(
                left: bw * 0.54,
                top: bh * 0.62,
                child: _UserDot(radius: s(48)),
              ),

              // Pins / Markers
              for (int i = 0; i < pins.length; i++)
                Positioned(
                  left: pinOffset(i).dx - s(18),
                  top: pinOffset(i).dy - s(18),
                  child: GestureDetector(
                    onTap: () => onTapPin(i),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (sel == i)
                          Container(
                            width: s(44),
                            height: s(44),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: pins[i].type == _MapPinType.station
                                  ? const Color(
                                      0xFF2CCB68,
                                    ).withValues(alpha: 0.18)
                                  : const Color(
                                      0xFF7A1F1F,
                                    ).withValues(alpha: 0.14),
                            ),
                          ),

                        // REPORT = red pin
                        if (pins[i].type == _MapPinType.report)
                          Icon(
                            Icons.location_pin,
                            size: s(46),
                            color: const Color(0xFF7A1F1F),
                          ),

                        // STATION = green ellipse marker
                        if (pins[i].type == _MapPinType.station)
                          _StationEllipseMarker(s: s, selected: sel == i),
                      ],
                    ),
                  ),
                ),

              // Callout
              if (sel != null)
                Positioned(
                  left: (pinOffset(sel).dx + s(22)).clamp(s(12), bw - s(220)),
                  top: (pinOffset(sel).dy - s(55)).clamp(s(12), bh - s(120)),
                  child: _PinCallout(
                    s: s,
                    condition: pins[sel].condition,
                    titleLine: pins[sel].titleLine,
                    distanceLine: pins[sel].distanceLine,
                    onClose: onCloseCallout,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StationEllipseMarker extends StatelessWidget {
  final double Function(double) s;
  final bool selected;

  const _StationEllipseMarker({required this.s, required this.selected});

  @override
  Widget build(BuildContext context) {
    final w = s(34);
    final h = s(34);
    final r = s(999);

    return SizedBox(
      width: s(46),
      height: s(46),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              Container(
                width: w + s(14),
                height: h + s(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2CCB68).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(r),
                ),
              ),

            Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(r),
                border: Border.all(
                  width: s(3.2),
                  color: const Color(0xFF2CCB68),
                ),
              ),
            ),

            // center dot
            Container(
              width: s(14),
              height: s(14),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2CCB68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinCallout extends StatelessWidget {
  final double Function(double) s;
  final String condition;
  final String titleLine;
  final String distanceLine;
  final VoidCallback onClose;

  const _PinCallout({
    required this.s,
    required this.condition,
    required this.titleLine,
    required this.distanceLine,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClose,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: s(210),
          padding: EdgeInsets.all(s(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(s(20)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                color: Color(0x1A000000),
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Condition: $condition | Waste",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'LexendExa',
                  fontSize: s(10),
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: s(8)),
              Text(
                titleLine,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: s(14),
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: s(6)),
              Text(
                distanceLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'LexendExa',
                  fontSize: s(11),
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserDot extends StatelessWidget {
  final double radius;
  const _UserDot({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2A73FF).withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(
          width: 12,
          height: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2A73FF),
            ),
          ),
        ),
      ],
    );
  }
}

/* =========================
   Latest Reports List
========================= */
class _LatestReportsList extends StatelessWidget {
  final double Function(double) s;
  final double Function(double) rs;
  final List<_ReportItem> items;
  final void Function(_ReportItem item) onTapItem;

  const _LatestReportsList({
    required this.s,
    required this.rs,
    required this.items,
    required this.onTapItem,
  });

  Color _statusColor(_ReportStatus status) {
    if (status == _ReportStatus.pending) return const Color(0xFFB96A00);
    if (status == _ReportStatus.accepted) return const Color(0xFF1D6F5F);
    return const Color(0xFF2C8B4E);
  }

  String _statusLabel(_ReportStatus status) {
    if (status == _ReportStatus.pending) return "Pending";
    if (status == _ReportStatus.accepted) return "Accepted";
    return "Collected";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(s(12)),
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
      child: ListView.separated(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, _) => Divider(
          height: rs(14),
          color: const Color(0xFF000000).withValues(alpha: 0.08),
        ),
        itemBuilder: (context, i) {
          final it = items[i];
          final sc = _statusColor(it.status);

          return InkWell(
            borderRadius: BorderRadius.circular(s(14)),
            onTap: () => onTapItem(it),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: rs(6)),
              child: Row(
                children: [
                  Container(
                    width: s(44),
                    height: s(44),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E746A).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(s(14)),
                    ),
                    child: Icon(
                      it.icon,
                      size: s(22),
                      color: const Color(0xFF2E746A),
                    ),
                  ),
                  SizedBox(width: s(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                it.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: s(13),
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: s(8)),
                            Text(
                              it.timeAgo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'LexendExa',
                                fontSize: s(9),
                                fontWeight: FontWeight.w700,
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: rs(4)),
                        Text(
                          "${it.wasteType} • ${it.weight} • ${it.distance}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'LexendExa',
                            fontSize: s(10),
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            color: Colors.black.withValues(alpha: 0.65),
                          ),
                        ),
                        SizedBox(height: rs(4)),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: s(13),
                              color: Colors.black.withValues(alpha: 0.60),
                            ),
                            SizedBox(width: s(4)),
                            Expanded(
                              child: Text(
                                it.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'LexendExa',
                                  fontSize: s(10),
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                  color: Colors.black.withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                            SizedBox(width: s(10)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: s(10),
                                vertical: rs(6),
                              ),
                              decoration: BoxDecoration(
                                color: sc.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _statusLabel(it.status),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'LexendExa',
                                  fontSize: s(9),
                                  fontWeight: FontWeight.w900,
                                  color: sc,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: s(6)),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: s(26),
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ],
              ),
            ),
          );
        },
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

  final VoidCallback onTapTotalReports;
  final VoidCallback onTapTotalCollected;

  const _SummaryCard({
    required this.s,
    required this.rs,
    required this.pillGreen,
    required this.range,
    required this.totalReports,
    required this.totalCollected,
    required this.onChangeRange,
    required this.onTapTotalReports,
    required this.onTapTotalCollected,
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
                  onTap: onTapTotalReports,
                ),
              ),
              SizedBox(width: s(10)),
              Expanded(
                child: _MetricTile(
                  s: s,
                  title: "Total Collected",
                  value: "$totalCollected",
                  icon: Icons.check_circle_outline,
                  onTap: onTapTotalCollected,
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
  final VoidCallback onTap;

  const _MetricTile({
    required this.s,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(s(16)),
      onTap: onTap,
      child: Container(
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
            Icon(
              Icons.chevron_right_rounded,
              size: s(20),
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ],
        ),
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

/* =========================
   Map painter
========================= */
class _SimpleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFD9C85B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final roadPaint2 = Paint()
      ..color = const Color(0xFFE7E1C6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.15),
      Offset(size.width * 0.95, size.height * 0.52),
      roadPaint2,
    );
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.15),
      Offset(size.width * 0.95, size.height * 0.52),
      roadPaint,
    );

    final street = Paint()
      ..color = const Color(0xFFBDB7A8).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.78),
      Offset(size.width * 0.72, size.height * 0.65),
      street,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.92),
      Offset(size.width * 0.88, size.height * 0.78),
      street,
    );

    final block = Paint()..color = const Color(0xFFE8E6DE);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.06,
        size.height * 0.24,
        size.width * 0.32,
        size.height * 0.22,
      ),
      block,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.58,
        size.width * 0.42,
        size.height * 0.28,
      ),
      block,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* =========================
   Sheets / Pages
   CHANGE:
   - Notifications sheet: NO Close button, tap anywhere to close
   - Metric popup: NO Close button, tap anywhere to close
========================= */

class _NotificationsSheet extends StatelessWidget {
  final Color headerGreen;
  final Color pillGreen;
  final Color bg;

  const _NotificationsSheet({
    required this.headerGreen,
    required this.pillGreen,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    double s(double v) => v * (w / 423.0);

    final notifications = <_NotificationItem>[
      _NotificationItem(
        title: "New report submitted",
        subtitle: "Furniture • PV12 • 0.3km",
        time: "12m ago",
        icon: Icons.notifications_active_outlined,
      ),
      _NotificationItem(
        title: "Request accepted",
        subtitle: "Metal • Taman Melati",
        time: "3h ago",
        icon: Icons.check_circle_outline,
      ),
      _NotificationItem(
        title: "Collected completed",
        subtitle: "E-waste • Gombak",
        time: "6h ago",
        icon: Icons.verified_outlined,
      ),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: s(80)),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(s(22)),
              topRight: Radius.circular(s(22)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: s(10)),
              Container(
                width: s(46),
                height: s(5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: s(12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: s(18),
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: s(10)),
              Padding(
                padding: EdgeInsets.fromLTRB(s(18), 0, s(18), s(18)),
                child: Column(
                  children: [
                    for (final n in notifications) ...[
                      Container(
                        padding: EdgeInsets.all(s(14)),
                        margin: EdgeInsets.only(bottom: s(10)),
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
                        child: Row(
                          children: [
                            Container(
                              width: s(44),
                              height: s(44),
                              decoration: BoxDecoration(
                                color: headerGreen.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(s(14)),
                              ),
                              child: Icon(
                                n.icon,
                                color: headerGreen,
                                size: s(22),
                              ),
                            ),
                            SizedBox(width: s(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: s(12.8),
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: s(4)),
                                  Text(
                                    n.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'LexendExa',
                                      fontSize: s(10),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black.withValues(
                                        alpha: 0.60,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: s(10)),
                            Text(
                              n.time,
                              style: TextStyle(
                                fontFamily: 'LexendExa',
                                fontSize: s(9.2),
                                fontWeight: FontWeight.w700,
                                color: Colors.black.withValues(alpha: 0.50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingRequestsPage extends StatelessWidget {
  final Color headerGreen;
  final Color pillGreen;
  final List<_PendingRequest> items;

  const _PendingRequestsPage({
    required this.headerGreen,
    required this.pillGreen,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F1ED),
      appBar: AppBar(
        backgroundColor: headerGreen,
        foregroundColor: Colors.white,
        title: const Text("Pending Requests"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final p = items[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Color(0x14000000),
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: headerGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(p.icon, color: headerGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.category,
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Estimated weight: ${p.weight}",
                        style: TextStyle(
                          fontFamily: 'LexendExa',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withValues(alpha: 0.60),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black.withValues(alpha: 0.60),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              p.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'LexendExa',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB96A00).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(
                      fontFamily: 'LexendExa',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB96A00),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportDetailsSheet extends StatelessWidget {
  final Color headerGreen;
  final Color pillGreen;
  final _ReportItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onMarkCollected;

  const _ReportDetailsSheet({
    required this.headerGreen,
    required this.pillGreen,
    required this.item,
    required this.onAccept,
    required this.onMarkCollected,
  });

  String get _statusLabel {
    if (item.status == _ReportStatus.pending) return "Pending";
    if (item.status == _ReportStatus.accepted) return "Accepted";
    return "Collected";
  }

  Color get _statusColor {
    if (item.status == _ReportStatus.pending) return const Color(0xFFB96A00);
    if (item.status == _ReportStatus.accepted) return const Color(0xFF1D6F5F);
    return const Color(0xFF2C8B4E);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    double s(double v) => v * (w / 423.0);

    final showAccept = item.status == _ReportStatus.pending;
    final showMarkCollected =
        item.status == _ReportStatus.pending ||
        item.status == _ReportStatus.accepted;

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: s(90)),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F1ED),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(s(22)),
            topRight: Radius.circular(s(22)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: s(10)),
            Container(
              width: s(46),
              height: s(5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            SizedBox(height: s(12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s(18)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Report Details",
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: s(18),
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: EdgeInsets.all(s(6)),
                      child: Icon(Icons.close_rounded, size: s(20)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: s(12)),
            Padding(
              padding: EdgeInsets.fromLTRB(s(18), 0, s(18), s(18)),
              child: Container(
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
                        Container(
                          width: s(46),
                          height: s(46),
                          decoration: BoxDecoration(
                            color: headerGreen.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(s(16)),
                          ),
                          child: Icon(
                            item.icon,
                            color: headerGreen,
                            size: s(22),
                          ),
                        ),
                        SizedBox(width: s(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: s(14),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: s(4)),
                              Text(
                                "${item.wasteType} • ${item.weight} • ${item.distance}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'LexendExa',
                                  fontSize: s(10.2),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: s(10),
                            vertical: s(6),
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              fontFamily: 'LexendExa',
                              fontSize: s(10),
                              fontWeight: FontWeight.w900,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s(12)),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: s(16),
                          color: Colors.black.withValues(alpha: 0.60),
                        ),
                        SizedBox(width: s(6)),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(
                              fontFamily: 'LexendExa',
                              fontSize: s(11),
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withValues(alpha: 0.60),
                            ),
                          ),
                        ),
                        Text(
                          item.timeAgo,
                          style: TextStyle(
                            fontFamily: 'LexendExa',
                            fontSize: s(10),
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withValues(alpha: 0.50),
                          ),
                        ),
                      ],
                    ),
                    if (showAccept || showMarkCollected) ...[
                      SizedBox(height: s(14)),
                      Row(
                        children: [
                          if (showAccept) ...[
                            Expanded(
                              child: _ActionButton(
                                label: "Accept Request",
                                color: headerGreen,
                                onTap: onAccept,
                              ),
                            ),
                            SizedBox(width: s(10)),
                          ],
                          if (showMarkCollected)
                            Expanded(
                              child: _ActionButton(
                                label: "Mark as Collected",
                                color: const Color(0xFF2C8B4E),
                                onTap: onMarkCollected,
                              ),
                            ),
                        ],
                      ),
                    ],
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

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'LexendExa',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _MetricPopup extends StatelessWidget {
  final Color headerGreen;
  final Color pillGreen;
  final String title;
  final String subtitle;
  final int value;

  const _MetricPopup({
    required this.headerGreen,
    required this.pillGreen,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    double s(double v) => v * (w / 423.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: s(170)),
          padding: EdgeInsets.fromLTRB(s(18), s(16), s(18), s(18)),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F1ED),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(s(22)),
              topRight: Radius.circular(s(22)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: s(46),
                height: s(5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: s(14)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: s(18),
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: s(10)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(s(16)),
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
                child: Row(
                  children: [
                    Container(
                      width: s(52),
                      height: s(52),
                      decoration: BoxDecoration(
                        color: headerGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(s(18)),
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: headerGreen,
                        size: s(24),
                      ),
                    ),
                    SizedBox(width: s(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: 'LexendExa',
                              fontSize: s(11),
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withValues(alpha: 0.60),
                            ),
                          ),
                          SizedBox(height: s(6)),
                          Text(
                            "$value",
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: s(28),
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   Models
========================= */
class _PendingRequest {
  final String id;
  final String category;
  final String weight;
  final String location;
  final IconData icon;
  final _ReportStatus status;
  final DateTime createdAt;

  _PendingRequest({
    required this.id,
    required this.category,
    required this.weight,
    required this.location,
    required this.icon,
    required this.status,
    required this.createdAt,
  });
}

class _ReportItem {
  final String id;
  final String title;
  final String wasteType;
  final String weight;
  final String distance;
  final String location;
  final _ReportStatus status;
  final String timeAgo;
  final IconData icon;

  _ReportItem({
    required this.id,
    required this.title,
    required this.wasteType,
    required this.weight,
    required this.distance,
    required this.location,
    required this.status,
    required this.timeAgo,
    required this.icon,
  });
}

enum _MapPinType { report, station }

class _MapPin {
  final double x;
  final double y;
  final _MapPinType type;
  final Color color;

  final String condition;
  final String titleLine;
  final String distanceLine;

  const _MapPin({
    required this.x,
    required this.y,
    required this.type,
    required this.color,
    required this.condition,
    required this.titleLine,
    required this.distanceLine,
  });
}

class _NotificationItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });
}
