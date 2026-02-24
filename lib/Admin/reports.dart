import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:excel/excel.dart' as ex;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const Color bg = Color(0xFFE6F1ED);
  static const Color headerGreen = Color(0xFF2E746A);
  static const Color cardGreen = Color(0xFFA6BFAF);
  static const Color pillGreen = Color(0xFF4B9E92);
  static const Color redDanger = Color(0xFFB61E1E);

  final int _rowsPerPage = 10;
  int _pageIndex = 0;

  // ALL button toggle
  bool _showAll = false;

  final GlobalKey _exportBoundaryKey = GlobalKey();

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = "";

  // per-report selection
  final Set<String> _selectedIds = <String>{};

  // soft delete
  final Set<String> _hiddenIds = <String>{};

  // filter state
  String? _filterCategory; // null = ALL
  double? _filterCostMin; // null = no min
  double? _filterCostMax; // null = no max
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  double? _filterDistanceMin;
  double? _filterDistanceMax;

  final SwipeCloseController _swipeCtrl = SwipeCloseController();

  // bottom nav
  int _navIndex = 1;

  final List<ReportItem> _allReports = [
    ReportItem(
      id: "1",
      category: "Metal",
      location: "Jalan Sri Emas, Cyberjaya",
      weight: "45 - 60 kg",
      costText: "RM 150-300",
      costMin: 150,
      costMax: 300,
      distanceKm: 3.4,
      reportedAt: DateTime(2026, 2, 18),
      matches: ["EcoGreen Ltd.", "CleanUp Co.", "WasteHero"],
    ),
    ReportItem(
      id: "2",
      category: "Paper-based",
      location: "Bandar Tasik Selatan",
      weight: "150 - 200 kg",
      costText: "RM 300-400",
      costMin: 300,
      costMax: 400,
      distanceKm: 12.8,
      reportedAt: DateTime(2026, 2, 20),
      matches: ["EcoGreen Ltd.", "CleanUp Co."],
    ),
    ReportItem(
      id: "3",
      category: "Cloth",
      location: "Bandar Tasik Selatan",
      weight: "150 - 200 kg",
      costText: "RM 300-400",
      costMin: 300,
      costMax: 400,
      distanceKm: 9.2,
      reportedAt: DateTime(2026, 2, 21),
      matches: ["EcoGreen Ltd.", "CleanUp Co."],
    ),
    ReportItem(
      id: "4",
      category: "Furniture",
      location: "Bandar Tasik Selatan",
      weight: "150 - 200 kg",
      costText: "RM 300-400",
      costMin: 300,
      costMax: 400,
      distanceKm: 18.5,
      reportedAt: DateTime(2026, 2, 22),
      matches: ["EcoGreen Ltd.", "CleanUp Co."],
    ),
  ];

  List<String> get _allCategories {
    final set = _allReports.map((e) => e.category).toSet().toList();
    set.sort();
    return set;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // filtered reports
  List<ReportItem> get _filteredReports => _filteredCore(includeHidden: false);

  List<ReportItem> get _filteredReportsIncludingHidden =>
      _filteredCore(includeHidden: true);

  List<ReportItem> _filteredCore({required bool includeHidden}) {
    final q = _query.trim().toLowerCase();
    DateTime? from = _filterDateFrom == null
        ? null
        : _dateOnly(_filterDateFrom!);
    DateTime? to = _filterDateTo == null ? null : _dateOnly(_filterDateTo!);

    return _allReports.where((r) {
      if (!includeHidden && _hiddenIds.contains(r.id)) return false;

      final matchesSearch = q.isEmpty
          ? true
          : (r.category.toLowerCase().contains(q) ||
                r.location.toLowerCase().contains(q) ||
                r.costText.toLowerCase().contains(q) ||
                r.weight.toLowerCase().contains(q) ||
                r.matches.any((m) => m.toLowerCase().contains(q)));

      if (!matchesSearch) return false;

      if (_filterCategory != null && r.category != _filterCategory) {
        return false;
      }

      if (_filterCostMin != null && r.costMax < _filterCostMin!) return false;
      if (_filterCostMax != null && r.costMin > _filterCostMax!) return false;

      if (_filterDistanceMin != null && r.distanceKm < _filterDistanceMin!) {
        return false;
      }
      if (_filterDistanceMax != null && r.distanceKm > _filterDistanceMax!) {
        return false;
      }

      final rd = _dateOnly(r.reportedAt);
      if (from != null && rd.isBefore(from)) return false;
      if (to != null && rd.isAfter(to)) return false;

      return true;
    }).toList();
  }

  // Total pages
  int get _totalPages {
    if (_showAll) return 1;
    final list = _filteredReports;
    if (list.isEmpty) return 1;
    return (list.length / _rowsPerPage).ceil().clamp(1, 9999);
  }

  // visible list
  List<ReportItem> get _pagedReports {
    if (_showAll) return _filteredReportsIncludingHidden;

    final list = _filteredReports;
    final start = _pageIndex * _rowsPerPage;
    if (start >= list.length) return [];
    final end = (start + _rowsPerPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void _handleBack() {
    _swipeCtrl.close();
    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/company');
    }
  }

  // ===============================
  // DELETE
  // ===============================
  Future<bool> _deleteReportRow(ReportItem item) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FBF7).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                const Text(
                  "Remove Match ?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: headerGreen,
                    fontFamily: "Lexend",
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 2,
                  color: headerGreen.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 18),
                Text(
                  "Remove CleanUp Co. from this list?\nThe request will be rematched to a\nnew company if all matches are\ncleared.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: const Color(0xFF1C5A50).withValues(alpha: 0.95),
                    fontFamily: "Lexend",
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9D9D9),
                          foregroundColor: const Color(0xFF2C2C2C),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Lexend",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redDanger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Lexend",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return false;

    if (result == true) {
      setState(() {
        _hiddenIds.add(item.id);
        _selectedIds.remove(item.id);
        _pageIndex = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report row hidden (data still remains)."),
        ),
      );

      return true;
    }

    return false;
  }

  // ===============================
  // FILTER
  // ===============================
  void _openFilterSheet() {
    _swipeCtrl.close();

    String? tmpCategory = _filterCategory;
    double? tmpCostMin = _filterCostMin;
    double? tmpCostMax = _filterCostMax;

    DateTime? tmpDateFrom = _filterDateFrom;
    DateTime? tmpDateTo = _filterDateTo;

    double? tmpDistanceMin = _filterDistanceMin;
    double? tmpDistanceMax = _filterDistanceMax;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF2FBF7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setSheet) {
              Future<void> pickFrom() async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: tmpDateFrom ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setSheet(() {
                    tmpDateFrom = _dateOnly(picked);
                    if (tmpDateTo != null && tmpDateFrom!.isAfter(tmpDateTo!)) {
                      tmpDateTo = null;
                    }
                  });
                }
              }

              Future<void> pickTo() async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: tmpDateTo ?? tmpDateFrom ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setSheet(() {
                    tmpDateTo = _dateOnly(picked);
                    if (tmpDateFrom != null &&
                        tmpDateTo!.isBefore(tmpDateFrom!)) {
                      tmpDateFrom = null;
                    }
                  });
                }
              }

              String fmt(DateTime? d) {
                if (d == null) return "—";
                final dd = _dateOnly(d);
                final m = dd.month.toString().padLeft(2, '0');
                final day = dd.day.toString().padLeft(2, '0');
                return "${dd.year}-$m-$day";
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Filter",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: headerGreen,
                          fontFamily: "Lexend",
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Category",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w500,
                            color: headerGreen.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8E7DF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: headerGreen.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: tmpCategory,
                            isExpanded: true,
                            hint: const Text("All"),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text("All"),
                              ),
                              ..._allCategories.map(
                                (c) => DropdownMenuItem<String?>(
                                  value: c,
                                  child: Text(c),
                                ),
                              ),
                            ],
                            onChanged: (v) => setSheet(() => tmpCategory = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Date Range",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w500,
                            color: headerGreen.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _PickerPill(
                              label: "From",
                              value: fmt(tmpDateFrom),
                              onTap: pickFrom,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PickerPill(
                              label: "To",
                              value: fmt(tmpDateTo),
                              onTap: pickTo,
                            ),
                          ),
                        ],
                      ),
                      if (tmpDateFrom != null || tmpDateTo != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => setSheet(() {
                              tmpDateFrom = null;
                              tmpDateTo = null;
                            }),
                            child: Text(
                              "Clear date",
                              style: TextStyle(
                                fontFamily: "Lexend",
                                fontWeight: FontWeight.w500,
                                color: headerGreen.withValues(alpha: 0.75),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Distance Range (KM)",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w500,
                            color: headerGreen.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _NumberField(
                              hint: "Min",
                              initial: tmpDistanceMin?.toStringAsFixed(1) ?? "",
                              onChanged: (txt) => setSheet(
                                () => tmpDistanceMin = double.tryParse(txt),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NumberField(
                              hint: "Max",
                              initial: tmpDistanceMax?.toStringAsFixed(1) ?? "",
                              onChanged: (txt) => setSheet(
                                () => tmpDistanceMax = double.tryParse(txt),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Cost Range (RM)",
                          style: TextStyle(
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w500,
                            color: headerGreen.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _NumberField(
                              hint: "Min",
                              initial: tmpCostMin?.toStringAsFixed(0) ?? "",
                              onChanged: (txt) => setSheet(
                                () => tmpCostMin = double.tryParse(txt),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NumberField(
                              hint: "Max",
                              initial: tmpCostMax?.toStringAsFixed(0) ?? "",
                              onChanged: (txt) => setSheet(
                                () => tmpCostMax = double.tryParse(txt),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD9D9D9),
                                foregroundColor: const Color(0xFF2C2C2C),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _filterCategory = null;
                                  _filterCostMin = null;
                                  _filterCostMax = null;
                                  _filterDateFrom = null;
                                  _filterDateTo = null;
                                  _filterDistanceMin = null;
                                  _filterDistanceMax = null;
                                  _pageIndex = 0;
                                });
                                Navigator.pop(ctx);
                              },
                              child: const Text(
                                "Reset",
                                style: TextStyle(
                                  fontFamily: "Lexend",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: headerGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _filterCategory = tmpCategory;
                                  _filterCostMin = tmpCostMin;
                                  _filterCostMax = tmpCostMax;
                                  _filterDateFrom = tmpDateFrom;
                                  _filterDateTo = tmpDateTo;
                                  _filterDistanceMin = tmpDistanceMin;
                                  _filterDistanceMax = tmpDistanceMax;
                                  _pageIndex = 0;
                                });
                                Navigator.pop(ctx);
                              },
                              child: const Text(
                                "Apply",
                                style: TextStyle(
                                  fontFamily: "Lexend",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ===============================
  // SELECT ALL / CLEAR
  // ===============================
  bool get _isAllFilteredSelected {
    final list = _showAll ? _filteredReportsIncludingHidden : _filteredReports;
    if (list.isEmpty) return false;
    return list.every((r) => _selectedIds.contains(r.id));
  }

  void _toggleSelectAllFiltered(bool value) {
    _swipeCtrl.close();
    setState(() {
      final list = _showAll
          ? _filteredReportsIncludingHidden
          : _filteredReports;
      if (value) {
        for (final r in list) {
          _selectedIds.add(r.id);
        }
      } else {
        for (final r in list) {
          _selectedIds.remove(r.id);
        }
      }
    });
  }

  void _toggleSelected(String id, bool v) {
    _swipeCtrl.close();
    setState(() {
      if (v) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  // ===============================
  // EXPORT
  // ===============================
  void _openExportSheet() {
    if (_selectedIds.isEmpty) return;
    _swipeCtrl.close();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF2FBF7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Export",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: headerGreen,
                    fontFamily: "Lexend",
                  ),
                ),
                const SizedBox(height: 12),
                _ExportTile(
                  icon: Icons.picture_as_pdf,
                  title: "Export PDF",
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _exportPdfSelected();
                  },
                ),
                _ExportTile(
                  icon: Icons.table_chart,
                  title: "Export Excel",
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _exportExcelSelected();
                  },
                ),
                _ExportTile(
                  icon: Icons.image_outlined,
                  title: "Export PNG",
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _exportPngFromBoundary();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ReportItem> get _selectedReports {
    final byId = {for (final r in _allReports) r.id: r};
    final out = <ReportItem>[];
    for (final id in _selectedIds) {
      final r = byId[id];
      if (r == null) continue;
      if (_hiddenIds.contains(r.id)) continue;
      out.add(r);
    }
    return out;
  }

  Future<void> _saveBytes({
    required Uint8List bytes,
    required String name,
    required String ext,
    required MimeType mime,
  }) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      ext: ext,
      mimeType: mime,
    );
  }

  String _fmtDate(DateTime d) {
    final dd = _dateOnly(d);
    final m = dd.month.toString().padLeft(2, '0');
    final day = dd.day.toString().padLeft(2, '0');
    return "${dd.year}-$m-$day";
  }

  Future<void> _exportPdfSelected() async {
    final list = _selectedReports;
    if (list.isEmpty) return;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            "Selected Reports",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text("Selected: ${list.length}"),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: const [
              "Category",
              "Location",
              "Weight",
              "Cost",
              "Distance (KM)",
              "Date",
              "Matches",
            ],
            data: list
                .map(
                  (r) => [
                    r.category,
                    r.location,
                    r.weight,
                    r.costText,
                    r.distanceKm.toStringAsFixed(1),
                    _fmtDate(r.reportedAt),
                    r.matches.join(", "),
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    await _saveBytes(
      bytes: Uint8List.fromList(bytes),
      name: "reports_selected",
      ext: "pdf",
      mime: MimeType.pdf,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Exported selected PDF.")));
    }
  }

  Future<void> _exportExcelSelected() async {
    final list = _selectedReports;
    if (list.isEmpty) return;

    final excel = ex.Excel.createExcel();
    final sheet = excel["Reports"];

    sheet.appendRow([
      "Category",
      "Location",
      "Weight",
      "Cost",
      "Distance (KM)",
      "Date",
      "Matches",
    ]);
    for (final r in list) {
      sheet.appendRow([
        r.category,
        r.location,
        r.weight,
        r.costText,
        r.distanceKm,
        _fmtDate(r.reportedAt),
        r.matches.join(", "),
      ]);
    }

    final raw = excel.save();
    if (raw == null) return;

    await _saveBytes(
      bytes: Uint8List.fromList(raw),
      name: "reports_selected",
      ext: "xlsx",
      mime: MimeType.microsoftExcel,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Exported selected Excel.")));
    }
  }

  Future<void> _exportPngFromBoundary() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final renderObject = _exportBoundaryKey.currentContext
          ?.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        return;
      }

      final ui.Image image = await renderObject.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      await _saveBytes(
        bytes: pngBytes,
        name: "reports",
        ext: "png",
        mime: MimeType.png,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Exported PNG.")));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Export failed. Try again.")),
        );
      }
    }
  }

  // bottom nav navigation
  void _onNavTap(int i) {
    if (i == _navIndex) return;

    _swipeCtrl.close();
    setState(() => _navIndex = i);

    switch (i) {
      case 0:
        Navigator.pushReplacementNamed(context, '/company');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/company/reports');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/company/summary-dashboard');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/company/locations');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/company/profile');
        break;
    }
  }

  @override
  void dispose() {
    _swipeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxIndex = _totalPages - 1;
    if (_pageIndex > maxIndex) _pageIndex = maxIndex;
    if (_pageIndex < 0) _pageIndex = 0;

    final visible = _pagedReports;

    final bool canPrev = !_showAll && _pageIndex > 0;
    final bool canNext =
        !_showAll &&
        _pageIndex < _totalPages - 1 &&
        _filteredReports.isNotEmpty;

    final bool showExport = _selectedIds.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 66,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: headerGreen,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _handleBack,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "All Reports",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: "Lexend",
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8E7DF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: headerGreen.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: headerGreen.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onTap: () => _swipeCtrl.close(),
                                onChanged: (v) => setState(() {
                                  _query = v;
                                  _pageIndex = 0;
                                }),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                    fontFamily: "Lexend",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: "Lexend",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _openFilterSheet,
                      child: Icon(
                        Icons.filter_alt_outlined,
                        color: headerGreen.withValues(alpha: 0.9),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAllFilteredSelected,
                      onChanged: (v) => _toggleSelectAllFiltered(v ?? false),
                      activeColor: headerGreen,
                      side: BorderSide(
                        color: headerGreen.withValues(alpha: 0.9),
                        width: 1.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${_filteredReports.length} matching results",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: headerGreen,
                        fontFamily: "Lexend",
                      ),
                    ),
                    const Spacer(),
                    if (showExport)
                      GestureDetector(
                        onTap: _openExportSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: headerGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Export",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Lexend",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  key: _exportBoundaryKey,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (_) => _swipeCtrl.close(),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n is ScrollStartNotification ||
                            n is ScrollUpdateNotification ||
                            n is UserScrollNotification) {
                          _swipeCtrl.close();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                        itemCount: visible.length + 1,
                        itemBuilder: (context, index) {
                          if (index == visible.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Text(
                                    "${visible.length} rows",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: headerGreen,
                                      fontFamily: "Lexend",
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: canPrev
                                        ? () => setState(
                                            () => _pageIndex = (_pageIndex - 1)
                                                .clamp(0, _totalPages - 1),
                                          )
                                        : null,
                                    icon: Icon(
                                      Icons.chevron_left,
                                      size: 30,
                                      color: canPrev
                                          ? headerGreen
                                          : headerGreen.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  Text(
                                    "${_pageIndex + 1} / $_totalPages",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: _showAll
                                          ? headerGreen.withValues(alpha: 0.5)
                                          : headerGreen,
                                      fontFamily: "Lexend",
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: canNext
                                        ? () => setState(
                                            () => _pageIndex = (_pageIndex + 1)
                                                .clamp(0, _totalPages - 1),
                                          )
                                        : null,
                                    icon: Icon(
                                      Icons.chevron_right,
                                      size: 30,
                                      color: canNext
                                          ? headerGreen
                                          : headerGreen.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      _swipeCtrl.close();
                                      setState(() {
                                        _showAll = !_showAll;
                                        _pageIndex = 0;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        "ALL",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: _showAll
                                              ? cardGreen
                                              : headerGreen,
                                          fontFamily: "Lexend",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final r = visible[index];
                          final isSelected = _selectedIds.contains(r.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: SwipeToRemove(
                              id: r.id,
                              controller: _swipeCtrl,
                              height: 125,
                              rightActionWidth: 78,
                              onRemove: () async => await _deleteReportRow(r),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (v) =>
                                        _toggleSelected(r.id, v ?? false),
                                    activeColor: headerGreen,
                                    side: BorderSide(
                                      color: headerGreen.withValues(alpha: 0.9),
                                      width: 1.5,
                                    ),
                                  ),
                                  Expanded(
                                    child: Opacity(
                                      opacity:
                                          (_showAll &&
                                              _hiddenIds.contains(r.id))
                                          ? 0.55
                                          : 1.0,
                                      child: ReportCard(
                                        report: r,
                                        cardGreen: cardGreen,
                                        pillGreen: pillGreen,
                                        headerGreen: headerGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: _onNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: headerGreen,
            unselectedItemColor: Colors.black54,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================
// SMALL WIDGETS
// ======================
class _PickerPill extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerPill({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD8E7DF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _ReportsPageState.headerGreen.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Text(
              "$label:",
              style: TextStyle(
                fontFamily: "Lexend",
                fontWeight: FontWeight.w500,
                color: _ReportsPageState.headerGreen.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "Lexend",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.calendar_month,
              color: _ReportsPageState.headerGreen.withValues(alpha: 0.85),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  final String hint;
  final String initial;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.hint,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E7DF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _ReportsPageState.headerGreen.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontFamily: "Lexend",
              fontWeight: FontWeight.w500,
            ),
          ),
          style: const TextStyle(
            fontFamily: "Lexend",
            fontWeight: FontWeight.w500,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ExportTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: _ReportsPageState.headerGreen),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: "Lexend",
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

class ReportCard extends StatelessWidget {
  final ReportItem report;
  final Color cardGreen;
  final Color pillGreen;
  final Color headerGreen;

  const ReportCard({
    super.key,
    required this.report,
    required this.cardGreen,
    required this.pillGreen,
    required this.headerGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "https://images.unsplash.com/photo-1595278069441-2cf29f8005a4?auto=format&fit=crop&w=400&q=60",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: headerGreen,
                    fontFamily: "Lexend",
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  report.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF184D44),
                    fontFamily: "Lexend",
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${report.weight} | ${report.costText} | ${report.distanceKm.toStringAsFixed(1)} km",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF184D44),
                    fontFamily: "Lexend",
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: pillGreen.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "Matches: ${_shortMatches(report.matches)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: headerGreen,
                      fontFamily: "Lexend",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortMatches(List<String> list) {
    if (list.isEmpty) return "—";
    if (list.length == 1) return list.first;
    if (list.length == 2) return "${list[0]}, ${list[1]}";
    return "${list[0]}, ${list[1]}, ...";
  }
}

// ======================
// Swipe controller
// ======================
class SwipeCloseController extends ChangeNotifier {
  String? _openId;

  String? get openId => _openId;

  void open(String id) {
    if (_openId == id) return;
    _openId = id;
    notifyListeners();
  }

  void close() {
    if (_openId == null) return;
    _openId = null;
    notifyListeners();
  }
}

class SwipeToRemove extends StatefulWidget {
  final String id;
  final SwipeCloseController controller;

  final Widget child;
  final double height;
  final double rightActionWidth;

  final Future<bool> Function() onRemove;

  const SwipeToRemove({
    super.key,
    required this.id,
    required this.controller,
    required this.child,
    required this.height,
    required this.rightActionWidth,
    required this.onRemove,
  });

  @override
  State<SwipeToRemove> createState() => _SwipeToRemoveState();
}

class _SwipeToRemoveState extends State<SwipeToRemove> {
  double _offsetX = 0;

  void _closeLocal() {
    if (!mounted) return;
    setState(() => _offsetX = 0);
  }

  void _openLocal() {
    if (!mounted) return;
    setState(() => _offsetX = -widget.rightActionWidth);
  }

  void _handleController() {
    final openId = widget.controller.openId;

    if (openId != widget.id && _offsetX != 0) _closeLocal();
    if (openId == null && _offsetX != 0) _closeLocal();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleController);
  }

  @override
  void didUpdateWidget(covariant SwipeToRemove oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleController);
      widget.controller.addListener(_handleController);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleController);
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.controller.openId != widget.id) {
      widget.controller.open(widget.id);
    }

    setState(() {
      _offsetX += details.delta.dx;
      if (_offsetX > 0) _offsetX = 0;
      if (_offsetX < -widget.rightActionWidth) {
        _offsetX = -widget.rightActionWidth;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_offsetX.abs() > widget.rightActionWidth / 2) {
      widget.controller.open(widget.id);
      _openLocal();
    } else {
      widget.controller.close();
      _closeLocal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  widget.controller.open(widget.id);
                  _openLocal();

                  final removed = await widget.onRemove();

                  if (removed) {
                    widget.controller.close();
                    _closeLocal();
                  } else {
                    widget.controller.open(widget.id);
                    _openLocal();
                  }
                },
                child: Container(
                  width: widget.rightActionWidth,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB61E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            transform: Matrix4.translationValues(_offsetX, 0, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onTapDown: (_) {
                if (_offsetX != 0) {
                  widget.controller.close();
                  _closeLocal();
                }
              },
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportItem {
  final String id;
  final String category;
  final String location;
  final String weight;
  final String costText;

  final double costMin;
  final double costMax;

  final double distanceKm;
  final DateTime reportedAt;

  final List<String> matches;

  ReportItem({
    required this.id,
    required this.category,
    required this.location,
    required this.weight,
    required this.costText,
    required this.costMin,
    required this.costMax,
    required this.distanceKm,
    required this.reportedAt,
    required this.matches,
  });
}
