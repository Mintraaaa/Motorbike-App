import 'package:cloud_firestore/cloud_firestore.dart'; // เพิ่มเพื่อเชื่อม Firebase
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorbike/model/booking.dart';

class ReturnVehiclePage extends StatelessWidget {
  final Booking booking;

  const ReturnVehiclePage({Key? key, required this.booking}) : super(key: key);

  // ฟังก์ชันอัปเดตสถานะการคืนรถไปยัง Firebase
  Future<void> updateReturnStatus(String bookingId, DateTime actualReturnTime, double penalty) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'isReturned': true,
        'actualReturnTime': actualReturnTime,
        'penalty': penalty,
      });
      print('สถานะการคืนรถถูกอัปเดตแล้ว');
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปเดตสถานะการคืนรถ: $e');
    }
  }

  // ฟังก์ชันฟอร์แมตวันที่และเวลา
  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  }

  // ฟังก์ชันคืนรถ
  void _returnMotorbike(BuildContext context) {
    DateTime currentTime = DateTime.now();
    bool isLate = currentTime.isAfter(booking.returnDate);

    // คำนวณค่าปรับ (ถ้าคืนรถล่าช้า)
    double penalty = 0.0;
    if (isLate) {
      Duration difference = currentTime.difference(booking.returnDate);
      int hoursLate = difference.inHours;
      penalty = hoursLate * 50.0;  // สมมติค่าปรับชั่วโมงละ 50 บาท
    }

    // อัปเดตสถานะการคืนรถใน Firebase
    updateReturnStatus(booking.bookingId, currentTime, penalty);

    // อัปเดตสถานะการคืนใน local booking object
    booking.isReturned = true;
    booking.actualReturnTime = currentTime;
    booking.penalty = penalty;

    // แสดงข้อความยืนยันการคืนรถ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('คืนรถเรียบร้อยแล้ว! ค่าปรับ: ${penalty.toStringAsFixed(2)} บาท'),
        backgroundColor: Colors.green,
      ),
    );

    // กลับไปยังหน้าแสดงรายละเอียดการจอง
    Navigator.pop(context, booking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คืนรถ'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายละเอียดการคืนรถของคุณ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('ข้อมูลรถที่จอง'),
            _buildDetailRow('ชื่อรถ', booking.motorbike.name),
            _buildDetailRow('สี', booking.motorbike.color),

            const Divider(height: 40, thickness: 2),

            _buildSectionTitle('วันและเวลาที่รับรถ'),
            _buildDetailRow('วันรับรถ', formatDateTime(booking.pickupDate)),
            _buildDetailRow('วันคืนรถที่กำหนด', formatDateTime(booking.returnDate)),

            const Divider(height: 40, thickness: 2),

            _buildSectionTitle('สถานที่รับรถ'),
            _buildDetailRow('สถานที่รับรถ', booking.location),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showReturnConfirmationDialog(context);  // เรียกฟังก์ชันคืนรถ
                },
                child: const Text('ยืนยันการคืนรถ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันแสดง Dialog ยืนยันการคืนรถ
  void _showReturnConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการคืนรถ'),
          content: const Text('คุณต้องการคืนรถหรือไม่?'),
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
                _returnMotorbike(context);  // เรียกฟังก์ชันคืนรถ
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสร้างหัวข้อแต่ละส่วน
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  // ฟังก์ชันสร้างแถวแสดงรายละเอียด
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
