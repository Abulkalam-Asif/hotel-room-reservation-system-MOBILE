import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../widgets/room_card.dart';
import 'home_screen.dart';
import 'booking_screen.dart';

class RoomsListScreen extends StatefulWidget {
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
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  List<Room> availableRooms = [];
  bool loading = false;
  String? error;
  List<int> selectedRoomIds = [];

  final String apiBaseUrl =
      'http://10.0.2.2:5272/api'; // Use 10.0.2.2 for Android emulator

  @override
  void initState() {
    super.initState();
    fetchAvailableRooms();
  }

  Future<void> fetchAvailableRooms() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final params = {
        'checkIn': widget.checkIn.toIso8601String(),
        'checkOut': widget.checkOut.toIso8601String(),
        'rooms': widget.rooms.toString(),
        'adults': widget.adults.toString(),
        'kids': widget.kids.toString(),
      };
      final uri = Uri.parse(
        '$apiBaseUrl/Room/available',
      ).replace(queryParameters: params);
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          availableRooms = data
              .map(
                (e) => Room(
                  id: e['id'] ?? e['Id'],
                  title: e['title'] ?? e['Title'] ?? '',
                  price: (e['price'] ?? e['Price'] ?? 0) is int
                      ? (e['price'] ?? e['Price'] ?? 0)
                      : ((e['price'] ?? e['Price'] ?? 0) as num).toInt(),
                  imageUrl: e['imageUrl'] ?? e['ImageUrl'] ?? '',
                  amenities: (e['amenities'] ?? e['Amenities'] ?? [])
                      .cast<String>(),
                ),
              )
              .toList();
        });
      } else {
        setState(() {
          error = 'Failed to fetch available rooms.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error.';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void onSelectRoom(int roomId) {
    setState(() {
      if (selectedRoomIds.contains(roomId)) {
        selectedRoomIds.remove(roomId);
      } else {
        if (selectedRoomIds.length < widget.rooms) {
          selectedRoomIds.add(roomId);
        }
      }
    });
  }

  void proceedToBooking() {
    if (selectedRoomIds.length != widget.rooms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select exactly ${widget.rooms} room(s).'),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          selectedRoomIds: selectedRoomIds,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          adults: widget.adults,
          kids: widget.kids,
          rooms: widget.rooms,
          apiBaseUrl: apiBaseUrl,
        ),
      ),
    );
  }

  void changeDates() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedCheckIn =
        '${widget.checkIn.toLocal().toString().split(' ')[0]}';
    final formattedCheckOut =
        '${widget.checkOut.toLocal().toString().split(' ')[0]}';
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms & Rates')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trip summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip summary: $formattedCheckIn - $formattedCheckOut',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: changeDates,
                        child: const Text('Change dates'),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Rooms: ${widget.rooms} | Adults: ${widget.adults} | Kids: ${widget.kids}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedRoomIds.length == widget.rooms
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        elevation: 4,
                      ),
                      onPressed: selectedRoomIds.length == widget.rooms
                          ? proceedToBooking
                          : null,
                      child: const Text('Proceed to Booking'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (error != null)
            Card(
              color: Colors.red[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            ),
          if (loading) const Center(child: CircularProgressIndicator()),
          if (!loading && availableRooms.isEmpty && error == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No rooms available for the selected dates.'),
              ),
            ),
          ...availableRooms.map(
            (room) => RoomCard(
              room: room,
              selected: selectedRoomIds.contains(room.id),
              onBook: () => onSelectRoom(room.id),
            ),
          ),
        ],
      ),
    );
  }
}
