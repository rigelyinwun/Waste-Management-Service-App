import 'package:flutter/material.dart';

class WasteListPage extends StatefulWidget {
  const WasteListPage({super.key});
  @override
  State<WasteListPage> createState() => _WasteListPageState();
}

class _WasteListPageState extends State<WasteListPage> {
  bool _isEmpty = false;
  PreferredSizeWidget _buildAppBar(String title) => AppBar(
    backgroundColor: const Color(0xFF387664),
    elevation: 0,
    centerTitle: true,
    automaticallyImplyLeading: false,
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E6DB),
      appBar: _buildAppBar("Waste List"),
      body: Column(
        children: [
          _buildTopSearchSection(),
          Expanded(
            child: _isEmpty ? _buildEmptyState() : _buildWasteListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search waste reports...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF387664)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _filterHeaderChip("Category"),
              _filterHeaderChip("Date"),
              _filterHeaderChip("Distance"),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.tune, color: Color(0xFF387664)),
                onPressed: () => _openFilterModal(context),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _filterHeaderChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFB5D1C1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('https://cdn-icons-png.flaticon.com/512/7486/7486744.png', height: 180),
          const SizedBox(height: 20),
          const Text("No Waste Reports Found.",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF387664))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text("Try adjusting your filters or send a new report.", textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text("Report Waste"),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF387664),
                foregroundColor: Colors.white,
                shape: const StadiumBorder()
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWasteListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 2,
      itemBuilder: (context, index) => _buildWasteCard(),
    );
  }

  Widget _buildWasteCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network('https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=200', width: 85, height: 85, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Metal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text("Taman Sri Emas, Cyberjaya", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const Text("Approx. 60 kg", style: TextStyle(fontSize: 12)),
                  const Text("RM 150 - RM 300", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF387664))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Feb 10, 2026", style: TextStyle(fontSize: 10, color: Colors.grey)),
                const Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey), Text("1.2km", style: TextStyle(fontSize: 10, color: Colors.grey))]),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => _showSendRequestModal(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF82D69A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: const Text("Send Request", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openFilterModal(BuildContext context) {
    showDialog(context: context, builder: (context) => const FilterDialog());
  }

  void _showSendRequestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFD3E6DB),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Send Request", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF387664))),
            const SizedBox(height: 15),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type your message here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessOverlay(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF387664),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text("Submit Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSuccessOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2E5E4E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF4FD195), size: 80),
              const SizedBox(height: 15),
              const Text("Request Sent !", style: TextStyle(color: Color(0xFF4FD195), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Your request to collect this waste has been successfully sent.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB5D1C1), foregroundColor: Colors.black),
                child: const Text("Okay!"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  double _dist = 40.0;
  String _date = "Today";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFD3E6DB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filters", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF387664))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            _pCheckbox("Metal"),
            _pCheckbox("Furniture"),
            _pCheckbox("Cloth"),
            const Divider(),
            const Text("Distance", style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _dist,
              max: 100,
              activeColor: const Color(0xFF4FD195),
              onChanged: (v) => setState(() => _dist = v),
            ),
            const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: const Color(0xFFB5D1C1), borderRadius: BorderRadius.circular(8)),
              child: DropdownButton<String>(
                value: _date,
                isExpanded: true,
                underline: const SizedBox(),
                items: ["Today", "This Week"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _date = v!),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text("Reset"))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF537A6E)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Apply", style: TextStyle(color: Colors.white)))
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _pCheckbox(String t) => SizedBox(
    height: 35,
    child: CheckboxListTile(
      value: true, onChanged: (v){},
      title: Text(t, style: const TextStyle(fontSize: 14)),
      activeColor: const Color(0xFF387664),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    ),
  );
}