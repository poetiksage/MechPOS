class RestaurantInfo {
  final String name;
  final String phone;
  final String address;

  // Hardcoded footer
  final String footerMessage = "We appreciate your visit";

  RestaurantInfo({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
