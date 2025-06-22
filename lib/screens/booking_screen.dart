import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class BookingScreen extends StatefulWidget {
  final List<int> selectedRoomIds;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int kids;
  final int rooms;
  final String apiBaseUrl;

  const BookingScreen({
    super.key,
    required this.selectedRoomIds,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.kids,
    required this.rooms,
    required this.apiBaseUrl,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Room> selectedRooms = [];
  bool loading = true;
  String? error;
  bool bookingLoading = false;
  String? bookingResult;
  String? bookingError;

  // Guest & billing info
  final _formKey = GlobalKey<FormState>();
  final TextEditingController guestFirstName = TextEditingController();
  final TextEditingController guestLastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  // Payment info
  final TextEditingController cardFirstName = TextEditingController();
  final TextEditingController cardLastName = TextEditingController();
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController cardType = TextEditingController();
  final TextEditingController cardExpMonth = TextEditingController();
  final TextEditingController cardExpYear = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRoomDetails();
  }

  Future<void> fetchRoomDetails() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final params = widget.selectedRoomIds.map((id) => 'ids=$id').join('&');
      final uri = Uri.parse('${widget.apiBaseUrl}/Room/details?$params');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          selectedRooms = data
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
          error = 'Failed to fetch room details.';
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

  int get totalCharge =>
      selectedRooms.fold(0, (sum, r) => sum + (r.price ?? 0));

  Future<void> submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      bookingLoading = true;
      bookingError = null;
      bookingResult = null;
    });
    try {
      final payload = {
        'RoomIds': widget.selectedRoomIds,
        'GuestFirstName': guestFirstName.text,
        'GuestLastName': guestLastName.text,
        'Email': email.text,
        'Phone': phone.text,
        'Country': country.text,
        'Street': street.text,
        'City': city.text,
        'PostalCode': postalCode.text,
        'CardFirstName': cardFirstName.text,
        'CardLastName': cardLastName.text,
        'CardNumber': cardNumber.text,
        'CardType': cardType.text,
        'CardExpMonth': cardExpMonth.text,
        'CardExpYear': cardExpYear.text,
        'CheckIn': widget.checkIn.toIso8601String(),
        'CheckOut': widget.checkOut.toIso8601String(),
        'Adults': widget.adults,
        'Kids': widget.kids,
        'Rooms': widget.rooms,
        'NightlyRate': selectedRooms.isNotEmpty ? selectedRooms[0].price : 0,
        'TotalCharge': totalCharge,
        'IsPaid': false,
      };
      final res = await http.post(
        Uri.parse('${widget.apiBaseUrl}/Booking'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          bookingResult = data['Message'] ?? 'Booking successful!';
        });
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Booking Confirmed'),
            content: Text(bookingResult ?? ''),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          bookingError = 'Booking failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        bookingError = 'Booking failed. Please try again.';
      });
    } finally {
      setState(() {
        bookingLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedCheckIn =
        '${widget.checkIn.toLocal().toString().split(' ')[0]}';
    final formattedCheckOut =
        '${widget.checkOut.toLocal().toString().split(' ')[0]}';
    // Helper for nights
    int nights = widget.checkOut.difference(widget.checkIn).inDays;
    double avgNightlyRate = selectedRooms.isNotEmpty
        ? selectedRooms.fold(0, (sum, r) => sum + (r.price ?? 0)) /
              selectedRooms.length
        : 0;
    List<double> prices = selectedRooms
        .map((r) => (r.price ?? 0).toDouble())
        .toList();
    double roomSum = prices.isNotEmpty ? prices.reduce((a, b) => a + b) : 0.0;
    double totalStayCharge = roomSum * nights;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Booking summary card at the top
                  Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR BOOKING SUMMARY',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Check-in'),
                              Text(formattedCheckIn),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Check-out'),
                              Text(formattedCheckOut),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...selectedRooms.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final room = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Room \\${idx + 1} Category'),
                                  Text(
                                    room.title.replaceAll(
                                      RegExp(r'^Room \\d+ - '),
                                      '',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total number of adults'),
                              Text(widget.adults.toString()),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Avg. nightly rate:'),
                              Text('€${avgNightlyRate.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total charge of the stay'),
                              Text(
                                '€${totalStayCharge.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This is the amount that will be charged to your credit card.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Booking form card below
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Guest Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: guestFirstName,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: guestLastName,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Billing Address',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: country,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: street,
                              decoration: const InputDecoration(
                                labelText: 'Street',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: city,
                              decoration: const InputDecoration(
                                labelText: 'City',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: postalCode,
                              decoration: const InputDecoration(
                                labelText: 'Postal Code',
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Payment Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: cardFirstName,
                              decoration: const InputDecoration(
                                labelText: 'Cardholder First Name',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: cardLastName,
                              decoration: const InputDecoration(
                                labelText: 'Cardholder Last Name',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: cardNumber,
                              decoration: const InputDecoration(
                                labelText: 'Card Number',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: cardType,
                              decoration: const InputDecoration(
                                labelText: 'Card Type',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: cardExpMonth,
                                    decoration: const InputDecoration(
                                      labelText: 'Exp. Month',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: cardExpYear,
                                    decoration: const InputDecoration(
                                      labelText: 'Exp. Year',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (bookingError != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  bookingError!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: bookingLoading
                                    ? null
                                    : submitBooking,
                                child: bookingLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Confirm Booking'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Need assistance? Tel. ****1234****',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
