import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingHistoryPage extends StatefulWidget {
  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  bool isReturned = false;

  Future<void> _returnMotorbike(String bookingId, Map<String, dynamic> bookingData) async {
    // ย้ายข้อมูลไปที่ bookingHistory
    await FirebaseFirestore.instance.collection('bookingHistory').doc(bookingId).set({
      'motorbikeId': bookingData['motorbikeId'],
      'userId': bookingData['userId'],
      'pickupDate': bookingData['pickupDate'],
      'returnDate': bookingData['returnDate'],
      'totalPrice': bookingData['totalPrice'],
      'location': bookingData['location'], // เพิ่มข้อมูลสถานที่ถ้ามี
    });

    // ลบข้อมูลการจองจาก collection bookings
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();

    setState(() {
      isReturned = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คืนรถเรียบร้อยแล้ว!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายละเอียดการจอง - ${booking['motorbikeId']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('วันรับรถ: ${booking['pickupDate']}'),
              Text('วันคืนรถ: ${booking['returnDate']}'),
              Text('สถานที่: ${booking['location']}'),
              Text('ราคารวม: ${booking['totalPrice'].toStringAsFixed(2)} บาท'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('ปิด'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ประวัติการจอง'),
      ),
      body: Column(
        children: [
          // ปุ่มคืนรถ
          if (!isReturned)
            ElevatedButton(
              onPressed: () {
                // ตรวจสอบและดึงข้อมูลการจองล่าสุด
                FirebaseFirestore.instance.collection('bookings').get().then((snapshot) {
                  if (snapshot.docs.isNotEmpty) {
                    final latestBooking = snapshot.docs.first;
                    final bookingId = latestBooking.id;
                    final bookingData = latestBooking.data() as Map<String, dynamic>;
                    _returnMotorbike(bookingId, bookingData);
                  }
                });
              },
              child: Text('คืนรถ'),
            ),

          // แสดงประวัติการจอง
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('bookingHistory').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    final data = document.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(Icons.history),
                      title: Text('มอเตอร์ไซค์: ${data['motorbikeId']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('วันรับ: ${data['pickupDate']}'),
                          Text('วันคืน: ${data['returnDate']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_drop_down),
                        onPressed: () => _showBookingDetails(context, data),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
