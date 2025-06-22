import 'package:flutter/material.dart';
import '../widgets/hotel_card.dart';
import 'rooms_list_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotel Room Reservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HotelCard(),
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
