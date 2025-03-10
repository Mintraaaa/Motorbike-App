import 'dart:io'; // สำหรับการจัดการไฟล์รูปภาพ
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // สำหรับการเลือกภาพ
import 'package:motorbike/features/booking_details.dart';
import 'package:motorbike/model/booking.dart';

class PaymentPage extends StatefulWidget {
  final Booking booking;
  final double totalPrice;
  final String motorbikeName;
  final String motorbikeColor;
  final double motorbikePricePerDay;
  final String bookingId;
  final String motorbikeId;
  final double pricePerDay;

  PaymentPage({
    Key? key,
    required this.booking,
    required this.totalPrice,
    required this.motorbikeName,
    required this.motorbikeColor,
    required this.motorbikePricePerDay,
    required this.bookingId,
    required this.motorbikeId,
    required this.pricePerDay,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _image; // ตัวแปรเก็บภาพที่เลือก
  String? _fileName;  // เพิ่มตัวแปรนี้เพื่อเก็บชื่อไฟล์
  bool isLoading = false; // ตัวแปรเก็บสถานะการอัปโหลด
  final FirebaseAuth _auth = FirebaseAuth.instance; // สำหรับ Firebase Authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // สำหรับ Firestore
  DateTime? _pickupDate;
  DateTime? _returnDate;

  double _calculateTotalPrice(double pricePerDay, int numberOfDays, double deposit, double distance) {
    double extraCharge = distance > 10.0 ? (distance - 10) * 5.0 : 0.0;
    return (pricePerDay * numberOfDays) + deposit + extraCharge;
  }
  // ฟังก์ชันเลือกภาพจากอุปกรณ์
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path); // เก็บภาพที่เลือก
        _fileName = pickedImage.name;
      });
    }
  }

  // ฟังก์ชันอัปโหลดภาพไปที่ Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = 'payments/${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // ฟังก์ชันบันทึกข้อมูลการชำระเงินไปที่ Firestore
  Future<void> _savePaymentToFirestore(String imageUrl) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถดึงข้อมูลผู้ใช้ได้ กรุณาล็อกอินใหม่')),
        );
        return;
      }

      // บันทึกข้อมูลการชำระเงินใน Firestore พร้อมกับ motorbikeId
      await _firestore.collection('payments').doc(widget.bookingId).set({
        'userId': userId,
        'bookingId': widget.bookingId,
        'motorbikeId': widget.motorbikeId, // เพิ่ม motorbikeId
        'totalPrice': widget.totalPrice,
        'paymentImageUrl': imageUrl,
        'paymentDate': FieldValue.serverTimestamp(),
        'isPaid': true,
      });

      // อัปเดตข้อมูลการชำระเงินใน Firestore
      await _firestore.collection('bookings').doc(widget.bookingId).update({
        'isPaid': true, // อัปเดตสถานะการชำระเงินเป็น true
        'paymentImageUrl': imageUrl,
        'paymentDate': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('การชำระเงินสำเร็จแล้ว')),
      );

      _navigateToBookingDetails();
    } catch (e) {
      print("Error saving payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูลการชำระเงิน: $e')),
      );
    }
  }

  // ฟังก์ชันยืนยันการชำระเงิน
  Future<void> _confirmPayment() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาแนบหลักฐานการชำระเงิน')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String? imageUrl = await _uploadImage(_image!);

    if (imageUrl != null) {
      await _savePaymentToFirestore(imageUrl);

      // อัปเดตสถานะการจองใน Firestore
      await FirebaseFirestore.instance
          .collection('motorbikes')
          .doc(widget.motorbikeId)
          .update({
        'isBooked': true, // เพิ่มฟิลด์ isBooked ให้เป็น true เมื่อจองแล้ว
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ชำระเงินสำเร็จและสถานะการจองอัปเดตแล้ว')),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('การอัปโหลดรูปภาพล้มเหลว กรุณาลองใหม่อีกครั้ง')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void _navigateToBookingDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsPage(
          // booking: widget.booking,
          bookingId: widget.bookingId,
          pickupDateTime: _pickupDate ?? widget.booking.pickupDate, // ส่งวันที่รับรถที่เลือก
          returnDateTime: _returnDate ?? widget.booking.returnDate, // ส่งวันที่คืนรถที่เลือก
          pricePerDay: widget.motorbikePricePerDay,
        ),
      ),
    );
  }

  // เพิ่มตัวแสดงการโหลดในหน้าจอ
  Widget _buildConfirmPaymentButton(double totalPrice) {
    return Center(
      child: isLoading 
        ? CircularProgressIndicator()  // แสดง loading ขณะกำลังอัปโหลด
        : ElevatedButton(
            onPressed: _confirmPayment, // อัพเดตสถานะการชำระเงินใน Firebase
            child: const Text('ยืนยันการชำระเงิน'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              backgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotalPrice(
      widget.motorbikePricePerDay ?? 0.0,
      widget.booking.days ?? 1, // ตั้งค่าเริ่มต้นที่ 1 วัน
      widget.booking.deposit ?? 0.0,
      widget.booking.distance ?? 0.0,
    );



    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลการชำระเงิน'),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1.0),
        centerTitle: true,
        toolbarHeight: 70.0,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBookingDetails(),
            const SizedBox(height: 20),
            _buildFramedQRPromptPayForm(),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text('เลือกไฟล์รูป'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            if (_fileName != null) // แสดงชื่อไฟล์ถ้ามี
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'ไฟล์ที่แนบ: $_fileName',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
              ),
              
            const SizedBox(height: 20),
            _buildConfirmPaymentButton(totalPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('ข้อมูลรถ'),
            _buildInfoRow(Icons.motorcycle, 'รุ่น:', widget.motorbikeName, Colors.blue),
            _buildInfoRow(Icons.color_lens, 'สี:', widget.motorbikeColor, Colors.red),
            const Divider(),

            _buildSectionTitle('รายละเอียดการจอง'),

            Padding(
              padding: const EdgeInsets.only(left: 8.0), // ขยับเข้าไปด้านซ้าย
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 24, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'วันและเวลาที่รับรถ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0), // ขยับข้อความเข้าไปจากไอคอน
                    child: Text(
                      formatDateTime(widget.booking.pickupDate),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 8.0), // ขยับเข้าไปด้านซ้าย
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 24, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'วันและเวลาที่คืนรถ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0), // ขยับข้อความเข้าไปจากไอคอน
                    child: Text(
                      formatDateTime(widget.booking.returnDate),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 8.0), // ขยับเข้าไปด้านซ้าย
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 24, color: Colors.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.booking.location,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${widget.booking.distance.toStringAsFixed(1)} กม.',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.right, // จัดชิดขวา
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildCostDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoWithSubtitle(IconData icon, String label, String location, String distance, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        Text(
          distance,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildCostDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('รายการค่าใช้จ่าย'),
        _buildRichTextWithSpacer('จำนวนวัน', '${widget.booking.days} วัน'),
        _buildRichTextWithSpacer('ราคาต่อวัน', '${widget.motorbikePricePerDay.toStringAsFixed(2)} บาท'),
        _buildRichTextWithSpacer('ค่ามัดจำ', '${widget.booking.deposit.toStringAsFixed(2)} บาท'),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              'ราคารวม',
              style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${widget.totalPrice.toStringAsFixed(2)} บาท',
              style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFramedQRPromptPayForm() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'ช่องทางการชำระเงิน',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/Qr1.jpg',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'โปรดสแกน QR Code เพื่อชำระเงิน',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label $value',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildRichTextWithSpacer(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
