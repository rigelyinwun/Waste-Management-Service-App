class AIAnalysis {
  final String category;
  final double estimatedWeightKg;
  final String recommendedTransport;
  final double estimatedCost;
  final String hazardLevel;
  final bool isRecyclable;

  AIAnalysis({
    required this.category,
    required this.estimatedWeightKg,
    required this.recommendedTransport,
    required this.estimatedCost,
    required this.hazardLevel,
    required this.isRecyclable,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'estimatedWeightKg': estimatedWeightKg,
      'recommendedTransport': recommendedTransport,
      'estimatedCost': estimatedCost,
      'hazardLevel': hazardLevel,
      'isRecyclable': isRecyclable,
    };
  }

  factory AIAnalysis.fromMap(Map<String, dynamic> map) {
    return AIAnalysis(
      category: map['category'] ?? 'Unknown',
      estimatedWeightKg: (map['estimatedWeightKg'] as num?)?.toDouble() ?? 0.0,
      recommendedTransport: map['recommendedTransport'] ?? 'N/A',
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      hazardLevel: map['hazardLevel'] ?? 'Low',
      isRecyclable: map['isRecyclable'] ?? false,
    );
  }
}