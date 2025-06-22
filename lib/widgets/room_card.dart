import 'package:flutter/material.dart';
import '../models/room.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final bool selected;
  final VoidCallback? onBook;
  const RoomCard({
    super.key,
    required this.room,
    this.selected = false,
    this.onBook,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool showAmenities = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: widget.selected ? const Color(0xFF0078d4) : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: widget.selected ? 6 : 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.room.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              widget.room.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Price: €${widget.room.price}'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selected
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: widget.selected ? 8 : 2,
                ),
                onPressed: widget.onBook,
                child: Text(widget.selected ? 'Selected' : 'Select'),
              ),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text(
                'Amenities',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              initiallyExpanded: showAmenities,
              onExpansionChanged: (expanded) =>
                  setState(() => showAmenities = expanded),
              children: [
                if (widget.room.amenities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.room.amenities
                          .map(
                            (a) => Chip(
                              label: Text(a),
                              backgroundColor: const Color(0xFFE3F2FD),
                              labelStyle: const TextStyle(
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Text('No amenities listed.'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
