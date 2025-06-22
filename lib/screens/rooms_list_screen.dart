import 'package:flutter/material.dart';
import '../models/room.dart';
import '../widgets/room_card.dart';

class RoomsListScreen extends StatelessWidget {
  final int adults;
  final int kids;
  final int rooms;
  final DateTime checkIn;
  final DateTime checkOut;

  const RoomsListScreen({
    super.key,
    required this.adults,
    required this.kids,
    required this.rooms,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  Widget build(BuildContext context) {
    final sampleRooms = Room.sampleRooms;
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms & Rates')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Trip summary: ${checkIn.toLocal().toString().split(' ')[0]} - ${checkOut.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Rooms: $rooms | Adults: $adults | Kids: $kids'),
          const SizedBox(height: 16),
          ...sampleRooms.map(
            (room) => RoomCard(
              room: room,
              onBook: () {
                // TODO: Navigate to booking form
              },
            ),
          ),
        ],
      ),
    );
  }
}
