import 'package:flutter/material.dart';
import 'package:motorbike/model/motorbike.dart';

class PaymentPage extends StatelessWidget {
  final double totalPrice;
  final Motorbike motorbike; 
  final DateTime pickupDate;
  final TimeOfDay pickupTime;
  final DateTime returnDate;
  final TimeOfDay returnTime;
  final String selectedLocation; 

  // คอนสตรัคเตอร์
  const PaymentPage({
    Key? key,
    required this.totalPrice,
    required this.motorbike,
    required this.pickupDate,
    required this.pickupTime,
    required this.returnDate,
    required this.returnTime,
    required this.selectedLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // โค้ด UI ของ PaymentPage
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Page'),
      ),
      body: Center(
        child: Text('Total Price: $totalPrice'),
      ),
    );
  }
}
