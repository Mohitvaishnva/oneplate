class Donation {
  final String id;
  final String donorId;
  final String donorName;
  final String donorType; // Hotel/Individual
  final String ngoId;
  final String ngoName;
  final String foodQuantity;
  final DateTime madAt;
  final DateTime expiryTime;
  final String? imageUrl;
  final String status; // Pending, Accepted, Completed
  final DateTime createdAt;
  
  Donation({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.donorType,
    required this.ngoId,
    required this.ngoName,
    required this.foodQuantity,
    required this.madAt,
    required this.expiryTime,
    this.imageUrl,
    this.status = 'Pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorId': donorId,
      'donorName': donorName,
      'donorType': donorType,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'foodQuantity': foodQuantity,
      'madAt': madAt.millisecondsSinceEpoch,
      'expiryTime': expiryTime.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] ?? '',
      donorId: json['donorId'] ?? '',
      donorName: json['donorName'] ?? '',
      donorType: json['donorType'] ?? '',
      ngoId: json['ngoId'] ?? '',
      ngoName: json['ngoName'] ?? '',
      foodQuantity: json['foodQuantity'] ?? '',
      madAt: DateTime.fromMillisecondsSinceEpoch(json['madAt'] ?? 0),
      expiryTime: DateTime.fromMillisecondsSinceEpoch(json['expiryTime'] ?? 0),
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
    );
  }
}