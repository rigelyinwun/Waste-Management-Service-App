class AIAnalysis {
  final String category;
  final double estimatedWeightKg;
  final String recommendedTransport;
  final double estimatedCost;
  final String hazardLevel;
  final bool isRecyclable;
  final String recyclabilityLevel;
  final String pickupPriority;
  final String collectionEffort;
  final String logistics;
  final String materialTag;

  AIAnalysis({
    required this.category,
    required this.estimatedWeightKg,
    required this.recommendedTransport,
    required this.estimatedCost,
    required this.hazardLevel,
    required this.isRecyclable,
    this.recyclabilityLevel = 'Unknown',
    this.pickupPriority = 'Normal',
    this.collectionEffort = 'Medium',
    this.logistics = 'N/A',
    this.materialTag = 'N/A',
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'estimatedWeightKg': estimatedWeightKg,
      'recommendedTransport': recommendedTransport,
      'estimatedCost': estimatedCost,
      'hazardLevel': hazardLevel,
      'isRecyclable': isRecyclable,
      'recyclabilityLevel': recyclabilityLevel,
      'pickupPriority': pickupPriority,
      'collectionEffort': collectionEffort,
      'logistics': logistics,
      'materialTag': materialTag,
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
      recyclabilityLevel: map['recyclabilityLevel'] ?? 'Unknown',
      pickupPriority: map['pickupPriority'] ?? 'Normal',
      collectionEffort: map['collectionEffort'] ?? 'Medium',
      logistics: map['logistics'] ?? 'N/A',
      materialTag: map['materialTag'] ?? 'N/A',
    );
  }
}