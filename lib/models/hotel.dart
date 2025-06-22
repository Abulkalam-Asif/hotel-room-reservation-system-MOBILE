class Hotel {
  final String name;
  final String address;
  final int starRating;
  final String mainImageUrl;

  Hotel({
    required this.name,
    required this.address,
    required this.starRating,
    required this.mainImageUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      starRating: json['starRating'] ?? 0,
      mainImageUrl: json['mainImageUrl'] ?? '',
    );
  }
}
