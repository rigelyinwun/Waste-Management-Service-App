import 'dart:math' as math;
import 'package:flutter/material.dart';

class SummaryDashboardPage extends StatefulWidget {
  const SummaryDashboardPage({super.key});

  @override
  State<SummaryDashboardPage> createState() => _SummaryDashboardPageState();
}

class _SummaryDashboardPageState extends State<SummaryDashboardPage> {
  DateTime _startDate = DateTime(2026, 1, 1);
  DateTime _endDate = DateTime(2026, 12, 31);

  String _trendRange = "Year";
  final List<String> _trendRanges = const ["Year", "Month", "Week"];

  String _nearbyRange = "Weekly";
  final List<String> _nearbyRanges = const ["Weekly", "Monthly", "Yearly"];

  final int totalRequests = 120; // total report
  final int totalCollected = 89;

  final List<_NearbyCardData> nearbyCards = const [
    _NearbyCardData(
      location: "Jalan Sentosa",
      category: "Aluminium Cans",
      count: 22,
    ),
    _NearbyCardData(location: "Jalan Ipoh", category: "Old Books", count: 39),
  ];

  final List<_PieSlice> pie = const [
    _PieSlice(label: "Plastic", value: 0.66, color: Color(0xFFD65B5B)),
    _PieSlice(label: "Paper", value: 0.18, color: Color(0xFFFFC46B)),
    _PieSlice(label: "Glass", value: 0.16, color: Color(0xFFA9D76B)),
  ];

  final List<double> lineA = const [3, 6, 4, 5, 4, 6]; // red
  final List<double> lineB = const [1, 3, 2, 1, 2, 2]; // blue
  final List<double> lineC = const [2, 3, 2, 3, 2.5, 4.2]; // yellow

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    double s(double v) => v * (w / 375.0);
    double rs(double v) => v * (h / 812.0);
    double fs(double v, {double min = 10, double max = 34}) =>
        (s(v)).clamp(min, max).toDouble();

    const bg = Color(0xFFE6F1ED);
    const headerGreen = Color(0xFF2E746A);
    const pillGreen = Color(0xFF4B9E92);
    const divider = Color(0xFF1F1F1F);

    final double recyclingRate = totalRequests == 0
        ? 0
        : (totalCollected / totalRequests) * 100.0;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: rs(26)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: rs(18)),
                color: headerGreen,
                child: Center(
                  child: Text(
                    "Summary Dashboard",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontSize: fs(18, min: 18, max: 20),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              SizedBox(height: rs(14)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: "Start Date",
                        date: _startDate,
                        onPick: () => _pickDate(isStart: true),
                        fs: fs,
                      ),
                    ),
                    SizedBox(width: s(14)),
                    Expanded(
                      child: _DateField(
                        label: "End Date",
                        date: _endDate,
                        onPick: () => _pickDate(isStart: false),
                        fs: fs,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs(14)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Container(
                  height: rs(160),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(s(22)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BigStat(
                          title: "Total Reports",
                          value: "$totalRequests",
                          fs: fs,
                        ),
                      ),
                      Container(
                        width: 1.2,
                        margin: EdgeInsets.symmetric(vertical: rs(22)),
                        color: divider.withValues(alpha: 0.6),
                      ),
                      Expanded(
                        child: _BigStat(
                          title: "Total Collected",
                          value: "$totalCollected",
                          fs: fs,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: rs(18)),
              _SectionDivider(padH: s(18)),

              SizedBox(height: rs(18)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Collection Trend",
                        style: TextStyle(
                          fontFamily: "Lexend",
                          fontSize: fs(20, min: 16, max: 26),
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _PillDropdown(
                      value: _trendRange,
                      items: _trendRanges,
                      onChanged: (v) => setState(() => _trendRange = v),
                      pillColor: pillGreen,
                      fs: fs,
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs(12)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Column(
                  children: [
                    // Line chart
                    Container(
                      height: rs(230),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(s(16)),
                      ),
                      child: CustomPaint(
                        painter: _LineChartPainter(
                          red: lineA,
                          blue: lineB,
                          yellow: lineC,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    SizedBox(height: rs(14)),

                    // Pie chart
                    Container(
                      height: rs(230),
                      padding: EdgeInsets.all(s(12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(s(14)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _PiePainter(
                          slices: pie,
                          highlightLabel: "Plastic",
                          highlightText: "66%",
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs(18)),
              _SectionDivider(padH: s(18)),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "Similar waste reports in nearby area",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "Lexend",
                              fontSize: fs(18, min: 14, max: 20),
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rs(10)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _PillDropdown(
                        value: _nearbyRange,
                        items: _nearbyRanges,
                        onChanged: (v) => setState(() => _nearbyRange = v),
                        pillColor: const Color(0xFF4B9E92),
                        fs: fs,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs(14)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Row(
                  children: [
                    Expanded(
                      child: _NearbyCard(data: nearbyCards[0], fs: fs),
                    ),
                    SizedBox(width: s(14)),
                    Expanded(
                      child: _NearbyCard(data: nearbyCards[1], fs: fs),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs(18)),
              _SectionDivider(padH: s(18)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Text(
                  "Environmental Impact",
                  style: TextStyle(
                    fontFamily: "Lexend",
                    fontSize: fs(20, min: 16, max: 24),
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: rs(10)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(18)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(16),
                    vertical: rs(14),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(s(18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    "Waste Diverted From Landfill:\n"
                    "Total collected recyclable waste (kg) = 240kg\n\n"
                    "Estimated Recycling Benefit:\n"
                    "Example: CO₂ saved estimate based on recycled materials\n\n"
                    "Collection Efficiency:\n"
                    "Recycling Rate = (Total Collected / Total Reports) × 100%\n"
                    "${recyclingRate.toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontSize: fs(14, min: 12, max: 15),
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              SizedBox(height: rs(28)),
            ],
          ),
        ),
      ),

    );
  }
  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final first = DateTime(2020, 1, 1);
    final last = DateTime(2035, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E746A)),
            textTheme: Theme.of(context).textTheme.apply(fontFamily: "Lexend"),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) _startDate = _endDate;
      }
    });
  }
}

/* ----------------------------- UI Widgets ----------------------------- */

typedef _FS = double Function(double v, {double min, double max});

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onPick,
    required this.fs,
  });

  final String label;
  final DateTime date;
  final VoidCallback onPick;
  final _FS fs;

  String _ddmmyyyy(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    const pillGreen = Color(0xFF4B9E92);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: "Lexend",
            fontSize: fs(13.5, min: 11, max: 14),
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: pillGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _ddmmyyyy(date),
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontSize: fs(14, min: 12, max: 14),
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.title, required this.value, required this.fs});

  final String title;
  final String value;
  final _FS fs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Lexend",
                fontSize: fs(18, min: 13, max: 18),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: "Lexend",
                fontSize: fs(52, min: 32, max: 52),
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 0.95,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  const _PillDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.pillColor,
    required this.fs,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Color pillColor;
  final _FS fs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 36,
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: pillColor,
          borderRadius: BorderRadius.circular(14),
          style: TextStyle(
            fontFamily: "Lexend",
            fontSize: fs(14, min: 12, max: 14),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.padH});
  final double padH;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Container(
        height: 1.2,
        color: Colors.black.withValues(alpha: 0.85),
      ),
    );
  }
}

class _NearbyCardData {
  final String location;
  final String category;
  final int count;
  const _NearbyCardData({
    required this.location,
    required this.category,
    required this.count,
  });
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.data, required this.fs});
  final _NearbyCardData data;
  final _FS fs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.black87),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.location,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Lexend",
                    fontSize: fs(16, min: 13, max: 16),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data.category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Lexend",
                fontSize: fs(18, min: 13, max: 18),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF43B19A),
              ),
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${data.count}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Lexend",
                fontSize: fs(44, min: 28, max: 44),
                fontWeight: FontWeight.w800,
                color: Colors.black,
                height: 0.95,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------------------------- Charts ----------------------------- */

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.red,
    required this.blue,
    required this.yellow,
  });

  final List<double> red;
  final List<double> blue;
  final List<double> yellow;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final axisPaint = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    // Axes
    final origin = Offset(size.width * 0.12, size.height * 0.86);
    final yTop = Offset(origin.dx, size.height * 0.12);
    final xRight = Offset(size.width * 0.92, origin.dy);

    canvas.drawLine(origin, yTop, axisPaint);
    canvas.drawLine(yTop, Offset(yTop.dx - 18, yTop.dy + 22), axisPaint);
    canvas.drawLine(yTop, Offset(yTop.dx + 18, yTop.dy + 22), axisPaint);

    canvas.drawLine(origin, xRight, axisPaint);
    canvas.drawLine(xRight, Offset(xRight.dx - 22, xRight.dy - 18), axisPaint);
    canvas.drawLine(xRight, Offset(xRight.dx - 22, xRight.dy + 18), axisPaint);

    // Plot area
    final left = origin.dx + 14;
    final right = size.width * 0.90;
    final top = size.height * 0.16;
    final bottom = origin.dy - 14;

    final plotW = right - left;
    final plotH = bottom - top;
    if (plotW <= 0 || plotH <= 0) return;

    // Shared min/max across all series
    final all = <double>[...red, ...blue, ...yellow];
    if (all.isEmpty) return;

    double minV = all.reduce(math.min);
    double maxV = all.reduce(math.max);

    final pad = (maxV - minV == 0) ? 1.0 : (maxV - minV) * 0.15;
    minV -= pad;
    maxV += pad;

    double mapY(double v) {
      final denom = (maxV - minV == 0) ? 1.0 : (maxV - minV);
      final t = (v - minV) / denom;
      return bottom - plotH * t;
    }

    Path buildPath(List<double> vals) {
      final path = Path();
      if (vals.length < 2) return path;

      for (int i = 0; i < vals.length; i++) {
        final t = i / (vals.length - 1);
        final x = left + plotW * t;
        final y = mapY(vals[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    void drawSeries(List<double> vals, Color color) {
      if (vals.length < 2) return;
      final p = Paint()
        ..color = color
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(buildPath(vals), p);
    }

    drawSeries(red, const Color(0xFFB4431D));
    drawSeries(blue, const Color(0xFF1E73B8));
    drawSeries(yellow, const Color(0xFFF2C100));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.red != red ||
        oldDelegate.blue != blue ||
        oldDelegate.yellow != yellow;
  }
}

class _PieSlice {
  final String label;
  final double value;
  final Color color;
  const _PieSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _PiePainter extends CustomPainter {
  _PiePainter({
    required this.slices,
    required this.highlightLabel,
    required this.highlightText,
  });

  final List<_PieSlice> slices;
  final String highlightLabel;
  final String highlightText;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.42;

    final gapPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    double start = -math.pi / 2;

    for (final s in slices) {
      final sweep = s.value * math.pi * 2;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, start, sweep, true, paint);
      canvas.drawArc(rect, start, 0.001, true, gapPaint);

      start += sweep;
    }

    canvas.drawCircle(center, radius, gapPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: "$highlightLabel\n$highlightText",
        style: const TextStyle(
          fontFamily: "Lexend",
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    final pos = Offset(
      center.dx - tp.width * 0.55,
      center.dy - tp.height * 0.2,
    );
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
