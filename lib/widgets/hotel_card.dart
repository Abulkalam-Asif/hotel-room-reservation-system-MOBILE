import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  const HotelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1549294413-26f195200c16?q=80&w=764&auto=format&fit=crop',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 12),
            const Text(
              'Grand Azure Hotel',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text('123 Main Street, City, Country'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => const Icon(Icons.star, color: Colors.amber, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
