import 'package:flutter/material.dart';
import 'package:motorbike/model/booking.dart'; // Import โมเดล Booking
import 'package:cloud_firestore/cloud_firestore.dart'; // สำหรับจัดการ Firestore
import 'package:intl/intl.dart';

class BookingInfoPage extends StatelessWidget {
  final Booking booking; // ข้อมูลการจองทั้งหมด
  final String bookingId; // เก็บ ID ของการจอง

  const BookingInfoPage({
    required this.booking,
    required this.bookingId, // รับ bookingId เพื่อใช้ในการยกเลิกการจอง
  });

  // ฟังก์ชันฟอร์แมตวันที่และเวลา
  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime); // แสดงวันที่ และเวลาในรูปแบบ 12 ชั่วโมง พร้อม AM/PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลการจอง'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('มอเตอร์ไซค์ที่จอง: ${booking.motorbike.name}', style: TextStyle(fontSize: 18)),
            Text('ยี่ห้อ: ${booking.motorbike.brand}', style: TextStyle(fontSize: 18)),
            Text('สี: ${booking.motorbike.color}', style: TextStyle(fontSize: 18)),

            // แสดงวันและเวลาที่รับและคืนรถ
            const SizedBox(height: 20),
            const Text('วันและเวลาที่รับ-คืนรถ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('วันรับรถ', style: TextStyle(fontSize: 18)),
                Text(formatDateTime(booking.pickupDate), style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('วันคืนรถ', style: TextStyle(fontSize: 18)),
                Text(formatDateTime(booking.returnDate), style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'สถานที่รับรถ: ${booking.location}', 
                    style: TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis, // ตัดข้อความที่ยาวเกิน
                    maxLines: 1, // จำกัดแค่ 1 บรรทัด
                  ),
                ),
                Text(
                  '${booking.distance.toStringAsFixed(1)} กม.', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text('ราคารวม: ${booking.totalPrice} บาท', style: TextStyle(fontSize: 18, color: Colors.red)),

            // แสดงสถานะการชำระเงิน
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('สถานะการชำระเงิน', style: TextStyle(fontSize: 18)),
                Text(
                  booking.isPaid ? 'ชำระเงินแล้ว' : 'ยังไม่ได้ชำระ',
                  style: TextStyle(
                    fontSize: 18,
                    color: booking.isPaid ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),

            // เพิ่มปุ่มยกเลิกการจอง
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showCancelConfirmationDialog(context, bookingId);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.red,
                ),
                child: const Text('ยกเลิกการจอง'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // แสดงการยืนยันการยกเลิกการจอง
  void _showCancelConfirmationDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการยกเลิก'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการจองนี้?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelBooking(bookingId, context); // เรียกฟังก์ชันยกเลิกการจอง
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันยกเลิกการจอง
  Future<void> _cancelBooking(String bookingId, BuildContext context) async {
    try {
      // ลบข้อมูลการจองจาก Firestore
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยกเลิกการจองสำเร็จ')),
      );

      // นำทางกลับไปยังหน้าแรกหรือหน้าที่ต้องการหลังจากยกเลิก
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }
}
