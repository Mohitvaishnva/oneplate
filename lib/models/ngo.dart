class NGO {
  final String id;
  final String ownerName;
  final String ngoName;
  final String address;
  final String email;
  final String phoneNumber;
  final String areaCovered;
  final String? certificateUrl;
  
  NGO({
    required this.id,
    required this.ownerName,
    required this.ngoName,
    required this.address,
    required this.email,
    required this.phoneNumber,
    required this.areaCovered,
    this.certificateUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerName': ownerName,
      'ngoName': ngoName,
      'address': address,
      'email': email,
      'phoneNumber': phoneNumber,
      'areaCovered': areaCovered,
      'certificateUrl': certificateUrl,
    };
  }

  factory NGO.fromJson(Map<String, dynamic> json) {
    return NGO(
      id: json['id'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ngoName: json['ngoName'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      areaCovered: json['areaCovered'] ?? '',
      certificateUrl: json['certificateUrl'],
    );
  }
}