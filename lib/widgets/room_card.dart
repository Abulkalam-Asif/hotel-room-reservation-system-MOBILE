import 'package:flutter/material.dart';
import '../models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onBook;
  const RoomCard({super.key, required this.room, this.onBook});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(room.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(room.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Price: €${room.price}'),
            Wrap(
              spacing: 8,
              children: room.amenities.map((a) => Chip(label: Text(a))).toList(),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBook,
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
