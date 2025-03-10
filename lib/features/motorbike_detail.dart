import 'package:flutter/material.dart';
import 'package:motorbike/model/booking.dart';
import 'package:motorbike/model/motorbike.dart';
import 'package:motorbike/features/booking.dart';

class MotorbikeDetailPage extends StatefulWidget {
  final Motorbike motorbike;

  MotorbikeDetailPage({required this.motorbike});

  @override
  _MotorbikeDetailPageState createState() => _MotorbikeDetailPageState();
}

class _MotorbikeDetailPageState extends State<MotorbikeDetailPage> {
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _returnDate;
  TimeOfDay? _returnTime;
  String? _selectedLocation;
  double? _distance;

  final double depositFee = 1500.0;
  final double lateFeePerHour = 50.0;

  int _calculateNumberOfDays() {
    if (_pickupDate != null && _returnDate != null) {
      return _returnDate!.difference(_pickupDate!).inDays + 1;
    }
    return 0;
  }

  double _calculateTotalPrice() {
    int numberOfDays = _calculateNumberOfDays();
    double dailyRate = widget.motorbike.totalPrice;
    double distance = _distance ?? 0.0;
    double extraCharge = distance > 10.0 ? (distance - 10) * 5.0 : 0.0;
    return (numberOfDays * dailyRate) + depositFee + extraCharge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.motorbike.name),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1.0),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        toolbarHeight: 70.0,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(widget.motorbike.images[0], fit: BoxFit.cover),
              const SizedBox(height: 16.0),
              _buildRichText('รายละเอียด: ', widget.motorbike.description),
              const SizedBox(height: 16.0),
              _buildRichText('สี: ', widget.motorbike.color),
              const SizedBox(height: 16.0),
              _buildRichText('ราคา: ', '${widget.motorbike.totalPrice.toStringAsFixed(0)} บาท/วัน'),
              const SizedBox(height: 16.0),
              const Text(
                'ฟีเจอร์:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 8.0,
                children: widget.motorbike.features.map((feature) {
                  return Chip(
                    avatar: Icon(feature.icon),
                    label: Text(feature.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24.0),

              // Updated ElevatedButton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // ลบการตรวจสอบเงื่อนไขข้อมูลที่กรอกเพื่อให้สามารถกดปุ่มได้เลย
                    Booking booking = Booking(
                      bookingId: '12345',
                      id: 'bike001',
                      pickupDate: _pickupDate ?? DateTime.now(),
                      returnDate: _returnDate ?? DateTime.now().add(const Duration(days: 1)),
                      location: _selectedLocation ?? 'ที่ตั้งเริ่มต้น',
                      days: _calculateNumberOfDays(),
                      deposit: depositFee,
                      distance: _distance ?? 0.0,
                      motorbike: widget.motorbike,
                      totalPrice: _calculateTotalPrice(),
                      isBooked: false,
                    );

                    // Navigate to the BookingPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(
                          motorbikeId: widget.motorbike.id,
                          motorbike: widget.motorbike,
                          booking: booking,
                          totalPrice: booking.totalPrice,
                          returnTime: _returnTime, // Pass the return time
                        ),
                      ),
                    );
                  },
                  child: const Text('จองรถคันนี้'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create RichText
  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 18.0,
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
