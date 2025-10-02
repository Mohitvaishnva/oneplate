class Individual {
  final String id;
  final String name;
  final String email;
  final String address;
  final String phoneNumber;
  
  Individual({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phoneNumber': phoneNumber,
    };
  }

  factory Individual.fromJson(Map<String, dynamic> json) {
    return Individual(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}