import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorbike/features/booking_details.dart';
import 'package:motorbike/model/booking.dart';

class BookingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการการจองทั้งหมด'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var bookings = snapshot.data!.docs.map((doc) => Booking.fromFirestore(doc)).toList();
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];

              return ListTile(
                title: Text(booking.motorbike.name),
                subtitle: Text('สถานะการคืนรถ: ${booking.isReturned ? 'คืนแล้ว' : 'ยังไม่คืน'}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailsPage(
                        bookingId: booking.bookingId,
                        pricePerDay: booking.totalPrice, // ส่งค่า pricePerDay ให้ถูกต้อง
                        pickupDateTime: booking.pickupDate, // ส่งวันที่รับ
                        returnDateTime: booking.returnDate, // ส่งวันที่คืน
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
