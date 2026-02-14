class CompanyModel {
  final String uid;
  final String companyName;
  final List<String> wasteTypes;
  final String contactNumber;
  final String email;
  final String serviceRegion;

  CompanyModel({
    required this.uid,
    required this.companyName,
    required this.wasteTypes,
    required this.contactNumber,
    required this.email,
    required this.serviceRegion,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'companyName': companyName,
      'wasteTypes': wasteTypes,
      'contactNumber': contactNumber,
      'email': email,
      'serviceRegion': serviceRegion,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      uid: map['uid'] ?? '',
      companyName: map['companyName'] ?? '',
      wasteTypes: List<String>.from(map['wasteTypes'] ?? []),
      contactNumber: map['contactNumber'] ?? '',
      email: map['email'] ?? '',
      serviceRegion: map['serviceRegion'] ?? '',
    );
  }
}
