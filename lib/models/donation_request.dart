class DonationRequest {
  final String id;
  final String ngoId;
  final String ngoName;
  final String description;
  final String foodType; // Veg/Non-Veg/Both
  final DateTime createdAt;
  final bool isActive;
  
  DonationRequest({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.description,
    required this.foodType,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'description': description,
      'foodType': foodType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      id: json['id'] ?? '',
      ngoId: json['ngoId'] ?? '',
      ngoName: json['ngoName'] ?? '',
      description: json['description'] ?? '',
      foodType: json['foodType'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      isActive: json['isActive'] ?? true,
    );
  }
}