import 'package:flutter/material.dart';

class DumpingStation {
  String state;
  String type;
  String location;
  bool isActive;

  DumpingStation({
    required this.state,
    required this.type,
    required this.location,
    required this.isActive,
  });
}

class DumpingStationsPage extends StatefulWidget {
  const DumpingStationsPage({super.key});

  @override
  State<DumpingStationsPage> createState() => _DumpingStationsPageState();
}

class _DumpingStationsPageState extends State<DumpingStationsPage> {
  static const Color _appBarGreen = Color(0xFF2F6F66);
  static const Color _pageMint = Color(0xFFE6F2EF);
  static const Color _pillGreen = Color(0xFF3C8A7E);
  static const Color _buttonGreen = Color(0xFF40B58F);
  static const Color _darkText = Color(0xFF1E1E1E);

  int _bottomIndex = 0;

  final Set<String> _selectedStates = {};

  final List<String> _states = [
    "Kuala Lumpur",
    "Selangor",
    "Johor",
    "Penang",
    "Perak",
    "Pahang",
    "Negeri Sembilan",
    "Melaka",
    "Kedah",
    "Kelantan",
    "Terengganu",
    "Sabah",
    "Sarawak",
    "Perlis",
    "Putrajaya",
    "Labuan",
  ];

  final List<String> _types = [
    "Recycling Center",
    "Landfill",
    "Transfer Station",
    "E-Waste Drop-off",
    "Composting Site",
  ];

  final List<DumpingStation> _stations = [
    DumpingStation(
      state: "Kuala Lumpur",
      type: "Recycling Center",
      location: "Jalan Permai 3, Wangsa Maju, 52200 K.L.",
      isActive: true,
    ),
    DumpingStation(
      state: "Selangor",
      type: "E-Waste Drop-off",
      location: "Persiaran Surian, Mutiara Damansara, 47810 PJ, Selangor",
      isActive: true,
    ),
    DumpingStation(
      state: "Johor",
      type: "Landfill",
      location: "Mukim Plentong, Johor Bahru, Johor",
      isActive: false,
    ),
  ];

  // Bottom nav
  void _onBottomNavTap(int i) {
    if (i == _bottomIndex) return;

    setState(() => _bottomIndex = i);

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

  bool get _hasStateFilter => _selectedStates.isNotEmpty;

  String get _selectedStateLabel {
    if (_selectedStates.isEmpty) return "All States";
    if (_selectedStates.length == 1) return _selectedStates.first;
    return "${_selectedStates.length} States";
  }

  List<String> get _allStatesForFilter {
    final set = <String>{..._states};
    for (final s in _stations) {
      final st = s.state.trim();
      if (st.isNotEmpty) set.add(st);
    }
    final list = set.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<String> get _allTypesForPick {
    final set = <String>{..._types};
    for (final s in _stations) {
      final t = s.type.trim();
      if (t.isNotEmpty) set.add(t);
    }
    final list = set.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<DumpingStation> get _filteredStations {
    if (_selectedStates.isEmpty) return _stations;
    return _stations.where((s) => _selectedStates.contains(s.state)).toList();
  }

  bool _existsInList(List<String> list, String value) {
    final v = value.trim().toLowerCase();
    return list.any((x) => x.trim().toLowerCase() == v);
  }

  void _commitToListIfNeeded(List<String> list, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (!_existsInList(list, trimmed)) {
      list.add(trimmed);
      list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
  }

  void _openCreateFromEmpty() {
    final defaultState = _selectedStates.length == 1
        ? _selectedStates.first
        : (_states.isNotEmpty ? _states.first : "Selangor");
    final defaultType = _types.isNotEmpty ? _types.first : "Recycling Center";

    _openEditDialog(
      isCreate: true,
      initialState: defaultState,
      initialType: defaultType,
      initialLocation: "",
      initialActive: true,
      onSave: (st, ty, loc, active) {
        setState(() {
          _stations.add(
            DumpingStation(
              state: st,
              type: ty,
              location: loc,
              isActive: active,
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStations;

    return Scaffold(
      backgroundColor: _pageMint,
      appBar: AppBar(
        backgroundColor: _appBarGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Dumping Stations",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Spacer(),
                if (_hasStateFilter) ...[
                  _ClearFilterPill(
                    onTap: () => setState(() => _selectedStates.clear()),
                  ),
                  const SizedBox(width: 10),
                ],
                _FilterPill(label: "State", onTap: _showMultiStateFilterSheet),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? _NotFoundEmptyState(
                    selectedStateLabel: _selectedStateLabel,
                    onAdd: _openCreateFromEmpty,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final station = filtered[index];
                      return _StationCard(
                        state: station.state,
                        type: station.type,
                        location: station.location,
                        isActive: station.isActive,
                        onEdit: () => _openEditDialog(
                          initialState: station.state,
                          initialType: station.type,
                          initialLocation: station.location,
                          initialActive: station.isActive,
                          onSave: (newState, newType, newLoc, newActive) {
                            final originalIndex = _stations.indexWhere(
                              (s) => identical(s, station),
                            );
                            setState(() {
                              if (originalIndex != -1) {
                                _stations[originalIndex].state = newState;
                                _stations[originalIndex].type = newType;
                                _stations[originalIndex].location = newLoc;
                                _stations[originalIndex].isActive = newActive;
                              } else {
                                station.state = newState;
                                station.type = newType;
                                station.location = newLoc;
                                station.isActive = newActive;
                              }
                            });
                          },
                        ),
                        onDelete: () => _confirmDelete(
                          onYes: () =>
                              setState(() => _stations.remove(station)),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _openCreateFromEmpty,
                icon: const Icon(Icons.add, size: 22),
                label: const Text(
                  "Add New Dumping Station",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        currentIndex: _bottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  // ---------- FILTER ----------
  void _showMultiStateFilterSheet() {
    final tempSelected = Set<String>.from(_selectedStates);
    final states = _allStatesForFilter;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        "State",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: states.map((s) {
                      final selected = tempSelected.contains(s);
                      return InkWell(
                        onTap: () {
                          setLocal(() {
                            if (selected) {
                              tempSelected.remove(s);
                            } else {
                              tempSelected.add(s);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? _pillGreen.withAlpha((0.12 * 255).round())
                                : const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected
                                  ? _pillGreen.withAlpha((0.55 * 255).round())
                                  : Colors.black12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected ? _pillGreen : _darkText,
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: _pillGreen,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F2F2F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedStates
                                  ..clear()
                                  ..addAll(tempSelected);
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                      if (tempSelected.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 40,
                          width: 110,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE3E3E3),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () =>
                                setLocal(() => tempSelected.clear()),
                            child: const Text(
                              "Clear",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------- CREATE/EDIT ----------
  void _openEditDialog({
    required String initialState,
    required String initialType,
    required String initialLocation,
    required bool initialActive,
    required void Function(
      String state,
      String type,
      String location,
      bool isActive,
    )
    onSave,
    bool isCreate = false,
  }) {
    String selectedState = initialState.trim().isEmpty
        ? (_states.isNotEmpty ? _states.first : "Selangor")
        : initialState.trim();

    String selectedType = initialType.trim().isEmpty
        ? (_types.isNotEmpty ? _types.first : "Recycling Center")
        : initialType.trim();

    bool active = initialActive;

    String? pendingNewState;
    String? pendingNewType;

    final locationController = TextEditingController(text: initialLocation);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => Navigator.pop(ctx),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.close, size: 26),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "State",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        final result = await _pickOrCreateDialog(
                          context: context,
                          title: "State",
                          list: _allStatesForFilter,
                          selected: selectedState,
                          addLabel: "Add new state",
                          hintText: "Type new state...",
                        );
                        if (result == null) return;

                        final picked = result.trim();
                        if (picked.isEmpty) return;

                        pendingNewState = !_existsInList(_states, picked)
                            ? picked
                            : null;
                        setLocal(() => selectedState = picked);
                      },
                      child: _GreySelectBox(value: selectedState),
                    ),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Type",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        final result = await _pickOrCreateDialog(
                          context: context,
                          title: "Type",
                          list: _allTypesForPick,
                          selected: selectedType,
                          addLabel: "Add new type",
                          hintText: "Type new type...",
                        );
                        if (result == null) return;

                        final picked = result.trim();
                        if (picked.isEmpty) return;

                        pendingNewType = !_existsInList(_types, picked)
                            ? picked
                            : null;
                        setLocal(() => selectedType = picked);
                      },
                      child: _GreySelectBox(value: selectedType),
                    ),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Location",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3E3E3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            hintText: "Write here...",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setLocal(() => active = !active),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? _pillGreen.withAlpha((0.12 * 255).round())
                                  : Colors.black.withAlpha(
                                      (0.06 * 255).round(),
                                    ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: active
                                    ? _pillGreen.withAlpha((0.55 * 255).round())
                                    : Colors.black12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  active
                                      ? Icons.check_circle_outline
                                      : Icons.remove_circle_outline,
                                  size: 18,
                                  color: active ? _pillGreen : Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  active ? "Active" : "Inactive",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: active ? _pillGreen : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 36,
                      width: 110,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F2F2F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final loc = locationController.text.trim();

                          setState(() {
                            if (pendingNewState != null) {
                              _commitToListIfNeeded(_states, pendingNewState!);
                            } else {
                              _commitToListIfNeeded(_states, selectedState);
                            }

                            if (pendingNewType != null) {
                              _commitToListIfNeeded(_types, pendingNewType!);
                            } else {
                              _commitToListIfNeeded(_types, selectedType);
                            }
                          });

                          final finalLoc = loc.isEmpty ? initialLocation : loc;
                          onSave(selectedState, selectedType, finalLoc, active);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<String?> _pickOrCreateDialog({
    required BuildContext context,
    required String title,
    required List<String> list,
    required String selected,
    required String addLabel,
    required String hintText,
  }) async {
    final unique = <String>{
      ...list.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };
    final items = unique.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    bool addingNew = false;
    final newController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: const Color(0xFFF4EEF6),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: items.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return InkWell(
                                    onTap: () =>
                                        setLocal(() => addingNew = !addingNew),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.black12,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.add, size: 18),
                                          const SizedBox(width: 10),
                                          Text(
                                            addLabel,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final item = items[index - 1];
                                final isSel =
                                    item.toLowerCase() ==
                                    selected.toLowerCase();

                                return InkWell(
                                  onTap: () => Navigator.pop(ctx, item),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 16,
                                    ),
                                    color: isSel
                                        ? const Color(0xFFE7E0EA)
                                        : Colors.transparent,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        if (isSel)
                                          const Icon(Icons.check, size: 18),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (addingNew) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3E3E3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: newController,
                            decoration: InputDecoration(
                              hintText: hintText,
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2F2F2F),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    final text = newController.text.trim();
                                    if (text.isEmpty) return;
                                    Navigator.pop(ctx, text);
                                  },
                                  child: const Text(
                                    "Add",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 40,
                              width: 110,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE3E3E3),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => setLocal(() {
                                  addingNew = false;
                                  newController.clear();
                                }),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  void _confirmDelete({required VoidCallback onYes}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.pop(ctx),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.close, size: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to\ndelete this dumping\nstation?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DialogButton(
                      label: "Yes",
                      onTap: () {
                        Navigator.pop(ctx);
                        onYes();
                      },
                    ),
                    const SizedBox(width: 12),
                    _DialogButton(label: "No", onTap: () => Navigator.pop(ctx)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------- EMPTY STATE ----------
class _NotFoundEmptyState extends StatelessWidget {
  const _NotFoundEmptyState({
    required this.selectedStateLabel,
    required this.onAdd,
  });

  final String selectedStateLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    final String title = selectedStateLabel == "All States"
        ? "No Dumping Stations Available Right Now."
        : "No Stations Found in $selectedStateLabel";

    final String subtitle = selectedStateLabel == "All States"
        ? "You can add a new dumping station anytime."
        : "Add a new station to start managing this state.";

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: h * 0.50),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.90,
                    child: Image.asset(
                      'assets/no-station.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF40B58F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    "Add Dumping Station",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- UI WIDGETS ----------
class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  static const Color _pillGreen = Color(0xFF3C8A7E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _pillGreen,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearFilterPill extends StatelessWidget {
  const _ClearFilterPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2F2F2F),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              "Clear",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreySelectBox extends StatelessWidget {
  const _GreySelectBox({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_drop_down_rounded),
        ],
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({
    required this.state,
    required this.type,
    required this.location,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
  });

  final String state;
  final String type;
  final String location;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Type: $type",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF1E1E1E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(isActive: isActive),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 16,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        state,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF1E1E1E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.edit_outlined, size: 20),
                ),
              ),
              const SizedBox(width: 2),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline_rounded, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isActive});
  final bool isActive;

  static const Color _pillGreen = Color(0xFF3C8A7E);

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? _pillGreen.withAlpha((0.12 * 255).round())
        : Colors.black.withAlpha((0.06 * 255).round());
    final border = isActive
        ? _pillGreen.withAlpha((0.55 * 255).round())
        : Colors.black12;
    final fg = isActive ? _pillGreen : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: fg),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F2F2F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: _DumpingStationsPageState._appBarGreen,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: "List",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            label: "Stats",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
