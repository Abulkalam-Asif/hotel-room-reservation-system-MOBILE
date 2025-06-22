class Room {
  final int id;
  final String title;
  final int price;
  final String imageUrl;
  final List<String> amenities;

  Room({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.amenities,
  });

  // Sample data
  static List<Room> sampleRooms = [
    Room(
      id: 1,
      title: 'Classic: 1 king bed (24 m²)',
      price: 100,
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      amenities: ['Free internet', 'Non-smoking', 'Fitness center'],
    ),
    Room(
      id: 2,
      title: 'Deluxe: 2 queen beds (30 m²)',
      price: 120,
      imageUrl: 'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd',
      amenities: ['Lounge/bar', '24h front desk', 'In-room safe'],
    ),
  ];
}
