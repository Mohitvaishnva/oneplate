class Hotel {
  final String id;
  final String hotelName;
  final String email;
  final String address;
  final String openingHours;
  final String foodType; // Veg/Non-Veg/Both
  final String? imageUrl;
  
  Hotel({
    required this.id,
    required this.hotelName,
    required this.email,
    required this.address,
    required this.openingHours,
    required this.foodType,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelName': hotelName,
      'email': email,
      'address': address,
      'openingHours': openingHours,
      'foodType': foodType,
      'imageUrl': imageUrl,
    };
  }

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '',
      hotelName: json['hotelName'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      openingHours: json['openingHours'] ?? '',
      foodType: json['foodType'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}