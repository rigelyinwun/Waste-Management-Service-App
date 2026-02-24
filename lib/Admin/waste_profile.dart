import 'package:flutter/material.dart';

class WasteProfilePage extends StatefulWidget {
  final String imagePath;
  final bool isNetworkImage;

  /// Display data
  final String wasteTypeLabel;
  final bool isLargeAiCertified;
  final List<String> materialChips;
  final int weightKg;
  final String transportLabel;
  final String description;

  // Details & AI metadata
  final int aiConfidence;
  final String structureLine;
  final int quantity;
  final String logistics;
  final String materialTag;
  final String recyclabilityLevel;
  final String pickupPriority;
  final String collectionEffort;
  final double initialEstimatedCostRm;
  final String initialCollectStatus;

  const WasteProfilePage({
    super.key,
    this.imagePath = "assets/sw.png",
    this.isNetworkImage = false,
    this.wasteTypeLabel = "Furniture",
    this.isLargeAiCertified = true,
    this.materialChips = const ["Wood, Fabric"],
    this.weightKg = 20,
    this.transportLabel = "Van",
    this.description = "Used: 2 years",
    this.aiConfidence = 89,
    this.structureLine = "Non-collapsible structure",
    this.quantity = 1,
    this.logistics = "Heavy, required at least 2 people\nto lift",
    this.materialTag = "Treated wood, cotton blend\nfabric, metal springs",
    this.recyclabilityLevel = "Medium",
    this.pickupPriority = "Normal",
    this.collectionEffort = "High",
    this.initialEstimatedCostRm = 100.00,
    this.initialCollectStatus = "none",
  });

  @override
  State<WasteProfilePage> createState() => _WasteProfileAdminPageState();
}

enum _CollectStatus { none, pending, accepted, collected }

class _WasteProfileAdminPageState extends State<WasteProfilePage> {
  late double _estimatedCostRm;
  late _CollectStatus _status;

  @override
  void initState() {
    super.initState();
    _estimatedCostRm = widget.initialEstimatedCostRm;
    _status = _parseStatus(widget.initialCollectStatus);
  }

  _CollectStatus _parseStatus(String v) {
    switch (v.toLowerCase().trim()) {
      case "pending":
        return _CollectStatus.pending;
      case "accepted":
        return _CollectStatus.accepted;
      case "collected":
        return _CollectStatus.collected;
      case "none":
      default:
        return _CollectStatus.none;
    }
  }

  void setStatusFromBackend(String newStatus) {
    if (!mounted) return;
    setState(() => _status = _parseStatus(newStatus));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    // scale helpers
    double s(double v) => v * (w / 423.0);
    double rs(double v) => v * (h / 917.0);

    const bg = Color(0xFFE6F1ED);
    const headerGreen = Color(0xFF2E746A);
    const buttonGreen = Color(0xFF48B49D);
    const cardBorder = Color(0xFF2E746A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: headerGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          "Waste Profile",
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: s(22),
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(s(16), rs(14), s(16), rs(14)),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(s(16)),
                      border: Border.all(color: cardBorder, width: s(1.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: s(16),
                          offset: Offset(0, rs(8)),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        s(14),
                        rs(14),
                        s(14),
                        rs(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _imageBlock(s, rs),
                          SizedBox(height: rs(10)),
                          _weightAndVehicleRow(s, rs),
                          SizedBox(height: rs(12)),
                          _descriptionBlock(s, rs),
                          SizedBox(height: rs(10)),
                          Divider(
                            height: rs(22),
                            thickness: rs(1),
                            color: const Color(0xFFE7C9C6),
                          ),

                          _sectionHeader("Details & AI Metadata", s, rs),
                          SizedBox(height: rs(14)),

                          _detailLine(
                            s,
                            rs,
                            'Recyclability level:',
                            widget.recyclabilityLevel,
                          ),
                          _detailLine(
                            s,
                            rs,
                            'Pickup priority:',
                            widget.pickupPriority,
                          ),
                          _detailLine(
                            s,
                            rs,
                            'Collection effort:',
                            widget.collectionEffort,
                          ),
                          _detailLine(
                            s,
                            rs,
                            'AI Confidence:',
                            '${widget.aiConfidence}%',
                          ),
                          _detailLine(s, rs, '', widget.structureLine),
                          _detailLine(s, rs, 'Quantity:', '${widget.quantity}'),
                          _detailLine(
                            s,
                            rs,
                            'Estimated weight:',
                            '${widget.weightKg}kg',
                          ),
                          _detailLine(s, rs, 'Logistics:', widget.logistics),
                          _detailLine(
                            s,
                            rs,
                            'Material Tag:',
                            widget.materialTag,
                          ),

                          SizedBox(height: rs(8)),

                          _estimatedCostStepper(s, rs),

                          SizedBox(height: rs(14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: rs(14)),
              _bottomButtons(s, rs, buttonGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    double Function(double) s,
    double Function(double) rs,
  ) {
    const headerGreen = Color(0xFF2E746A);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(10), vertical: rs(10)),
      child: Row(
        children: [
          Container(
            width: s(6),
            height: rs(22),
            decoration: BoxDecoration(
              color: headerGreen,
              borderRadius: BorderRadius.circular(s(8)),
            ),
          ),
          SizedBox(width: s(10)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: s(18.5),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBlock(double Function(double) s, double Function(double) rs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(s(14)),
      child: Stack(
        children: [
          Container(
            height: rs(250),
            width: double.infinity,
            color: const Color(0xFFD9D9D9),
            child: widget.isNetworkImage
                ? Image.network(widget.imagePath, fit: BoxFit.cover)
                : Image.asset(widget.imagePath, fit: BoxFit.cover),
          ),
          Positioned(
            left: s(10),
            right: s(10),
            bottom: rs(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _pill("[ ${widget.wasteTypeLabel} ]", s, rs),
                  SizedBox(width: s(8)),
                  _pill(
                    widget.isLargeAiCertified
                        ? "Large - AI Certified"
                        : "AI Certified",
                    s,
                    rs,
                  ),
                  SizedBox(width: s(8)),
                  _pill(
                    widget.materialChips.isNotEmpty
                        ? widget.materialChips[0]
                        : "Wood",
                    s,
                    rs,
                  ),
                  SizedBox(width: s(6)),
                  _pill(
                    widget.materialChips.length > 1
                        ? widget.materialChips[1]
                        : "Fabric",
                    s,
                    rs,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(
    String text,
    double Function(double) s,
    double Function(double) rs,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(10), vertical: rs(6)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(s(8)),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: s(10),
            offset: Offset(0, rs(3)),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: s(12.5),
          fontWeight: FontWeight.w200,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _weightAndVehicleRow(
    double Function(double) s,
    double Function(double) rs,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _iconStat(
          icon: Icons.scale_rounded,
          label: '${widget.weightKg}kg',
          s: s,
        ),
        _iconStat(
          icon: Icons.airport_shuttle_rounded,
          label: widget.transportLabel,
          s: s,
        ),
      ],
    );
  }

  Widget _iconStat({
    required IconData icon,
    required String label,
    required double Function(double) s,
  }) {
    return Row(
      children: [
        Icon(icon, size: s(22), color: Colors.black),
        SizedBox(width: s(10)),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: s(18),
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _descriptionBlock(
    double Function(double) s,
    double Function(double) rs,
  ) {
    const muted = Color(0xFF6E6E6E);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description:',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: s(16),
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: rs(2)),
        Text(
          widget.description,
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: s(16),
            fontWeight: FontWeight.w200,
            color: muted,
          ),
        ),
      ],
    );
  }

  Widget _detailLine(
    double Function(double) s,
    double Function(double) rs,
    String k,
    String v,
  ) {
    final hasKey = k.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: rs(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: s(170),
            child: hasKey
                ? Text(
                    k,
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: s(14.5),
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: s(14.5),
                fontWeight: FontWeight.w200,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estimatedCostStepper(
    double Function(double) s,
    double Function(double) rs,
  ) {
    final keyStyle = TextStyle(
      fontFamily: 'Lexend',
      fontSize: s(14.5),
      fontWeight: FontWeight.w200,
      color: Colors.black,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: rs(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: s(170),
            child: Text("Estimated costs:", style: keyStyle),
          ),
          Expanded(
            child: Row(
              children: [
                Text("RM ", style: keyStyle),
                SizedBox(
                  width: s(150),
                  height: rs(40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E9E9),
                      borderRadius: BorderRadius.circular(s(12)),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: s(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _estimatedCostRm.toStringAsFixed(2),
                            style: keyStyle,
                          ),
                        ),
                        SizedBox(
                          width: s(34),
                          height: rs(38),
                          child: Column(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _setCost(
                                    (_estimatedCostRm + 10)
                                        .clamp(0, 999999)
                                        .toDouble(),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      size: s(18),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _setCost(
                                    (_estimatedCostRm - 10)
                                        .clamp(0, 999999)
                                        .toDouble(),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: s(18),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  void _setCost(double v) {
    setState(() => _estimatedCostRm = v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E746A),
        content: Text(
          "Estimated cost updated: RM ${_estimatedCostRm.toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Widget _bottomButtons(
    double Function(double) s,
    double Function(double) rs,
    Color buttonGreen,
  ) {
    final canRequest = _status == _CollectStatus.none;

    final canMarkCollected =
        _status == _CollectStatus.accepted || _status == _CollectStatus.pending;

    final requestLabel = (_status == _CollectStatus.pending)
        ? "Requested"
        : (_status == _CollectStatus.collected)
        ? "Request Collect"
        : "Request Collect";

    final markLabel = (_status == _CollectStatus.collected)
        ? "Collected"
        : "Mark as collected";

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: rs(52),
          child: ElevatedButton(
            onPressed: canRequest ? _onRequestCollectPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canRequest
                  ? buttonGreen
                  : buttonGreen.withValues(alpha: 0.35),
              disabledBackgroundColor: buttonGreen.withValues(alpha: 0.35),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(s(10)),
              ),
            ),
            child: Text(
              requestLabel,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: s(16),
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: canRequest ? 1.0 : 0.75),
              ),
            ),
          ),
        ),
        SizedBox(height: rs(10)),
        SizedBox(
          width: double.infinity,
          height: rs(52),
          child: ElevatedButton(
            onPressed: canMarkCollected ? _onMarkCollectedPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canMarkCollected
                  ? buttonGreen
                  : buttonGreen.withValues(alpha: 0.35),
              disabledBackgroundColor: buttonGreen.withValues(alpha: 0.35),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(s(10)),
              ),
            ),
            child: Text(
              markLabel,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: s(16),
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(
                  alpha: canMarkCollected ? 1.0 : 0.75,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onRequestCollectPressed() async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Request collect?"),
          content: const Text(
            "Send a collection request to the user?\n\n"
            "If the user rejects, you can request again.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48B49D),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Send request"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (res != true) return;

    setState(() => _status = _CollectStatus.pending);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request sent. Waiting for user acceptance."),
      ),
    );
  }

  void _onMarkCollectedPressed() {
    setState(() => _status = _CollectStatus.collected);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Marked as collected.")));
  }
}
