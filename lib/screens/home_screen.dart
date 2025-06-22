import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/hotel_card.dart';
import '../models/hotel.dart';
import 'rooms_list_screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int adults = 2;
  int kids = 0;
  int rooms = 1;
  DateTime? checkIn;
  DateTime? checkOut;

  Hotel? hotel;
  bool hotelLoaded = false;
  // final String apiBaseUrl =
  //     dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5000/api';
  final String apiBaseUrl = 'http://10.0.2.2:5272/api';
  final String defaultImage =
      'https://images.unsplash.com/photo-1549294413-26f195200c16?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  @override
  void initState() {
    super.initState();
    fetchHotelInfo();
  }

  Future<void> fetchHotelInfo() async {
    try {
      final res = await http.get(Uri.parse('$apiBaseUrl/Hotel/info'));
      if (res.statusCode == 200) {
        setState(() {
          hotel = Hotel.fromJson(json.decode(res.body));
        });
      }
    } catch (e) {
      // handle error
    } finally {
      setState(() {
        hotelLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotel Room Reservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hotelLoaded && hotel != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        hotel!.mainImageUrl.isNotEmpty
                            ? hotel!.mainImageUrl
                            : defaultImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hotel!.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(hotel!.address),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          hotel!.starRating,
                          (i) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (!hotelLoaded)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Loading hotel info...'),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Your Room',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Adults',
                            ),
                            initialValue: adults.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                setState(() => adults = int.tryParse(v) ?? 1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Kids',
                            ),
                            initialValue: kids.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                setState(() => kids = int.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Rooms',
                            ),
                            initialValue: rooms.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                setState(() => rooms = int.tryParse(v) ?? 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: checkIn ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null)
                                setState(() => checkIn = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Check-in',
                              ),
                              child: Text(
                                checkIn == null
                                    ? 'Select date'
                                    : checkIn!.toLocal().toString().split(
                                        ' ',
                                      )[0],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    checkOut ??
                                    (checkIn ?? DateTime.now()).add(
                                      const Duration(days: 1),
                                    ),
                                firstDate: checkIn ?? DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 366),
                                ),
                              );
                              if (picked != null)
                                setState(() => checkOut = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Check-out',
                              ),
                              child: Text(
                                checkOut == null
                                    ? 'Select date'
                                    : checkOut!.toLocal().toString().split(
                                        ' ',
                                      )[0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (checkIn == null || checkOut == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select check-in and check-out dates.',
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomsListScreen(
                                adults: adults,
                                kids: kids,
                                rooms: rooms,
                                checkIn: checkIn!,
                                checkOut: checkOut!,
                              ),
                            ),
                          );
                        },
                        child: const Text('Find Rooms'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
