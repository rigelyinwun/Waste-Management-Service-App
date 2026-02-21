class AIAnalysis {
  final String category;
  final double estimatedWeightKg;
  final String recommendedTransport;
  final double estimatedCost;
  final String hazardLevel;

  AIAnalysis({
    required this.category,
    required this.estimatedWeightKg,
    required this.recommendedTransport,
    required this.estimatedCost,
    required this.hazardLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'estimatedWeightKg': estimatedWeightKg,
      'recommendedTransport': recommendedTransport,
      'estimatedCost': estimatedCost,
      'hazardLevel': hazardLevel,
    };
  }

  factory AIAnalysis.fromMap(Map<String, dynamic> map) {
    return AIAnalysis(
      category: map['category'],
      estimatedWeightKg: (map['estimatedWeightKg'] as num).toDouble(),
      recommendedTransport: map['recommendedTransport'],
      estimatedCost: (map['estimatedCost'] as num).toDouble(),
      hazardLevel: map['hazardLevel'],
    );
  }
}