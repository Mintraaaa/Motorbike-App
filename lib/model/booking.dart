import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // สำหรับการจัดรูปแบบวันที่
import 'package:motorbike/model/motorbike.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // สำหรับ Firestore

class Booking {
  final String bookingId;
  final String id; 
  final DateTime pickupDate;
  final DateTime returnDate;
  final String location;
  final int days;
  final double deposit;
  final double distance;
  final Motorbike motorbike;
  final double totalPrice;
  final bool isPaid;
  final String? paymentImageUrl; // เพิ่มตัวแปรเก็บ URL หลักฐานการชำระเงิน

  bool isReturned;
  DateTime? actualReturnTime;
  double penalty;
  bool isPenaltyPaid = false;  // เก็บสถานะการชำระค่าปรับ
  final bool isBooked;

  Booking({
    required this.bookingId,
    required this.id, 
    required this.pickupDate,
    required this.returnDate,
    required this.location,
    required this.days,
    required this.deposit,
    required this.distance,
    required this.motorbike,
    required this.totalPrice,
    this.isPaid = false,
    this.isReturned = false, 
    this.actualReturnTime,
    this.penalty = 0.0,
    this.isPenaltyPaid = false,
    this.paymentImageUrl, // เพิ่มเข้าไปใน constructor
    required this.isBooked,
  });

  // Getter สำหรับ Id
  String get getid => id;

  // ฟังก์ชันคืนรถ
  void returnMotorbike() {
    DateTime currentTime = DateTime.now();
    isReturned = true;
    actualReturnTime = currentTime;

    // คำนวณค่าปรับถ้าคืนล่าช้า
    if (currentTime.isAfter(returnDate)) {
      Duration lateDuration = currentTime.difference(returnDate);
      int hoursLate = lateDuration.inHours;
      penalty = hoursLate * 50.0;
    } else {
      penalty = 0.0;
    }
  }

  // ฟังก์ชันบันทึกการจองลงใน Firestore
  Future<void> saveBookingToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).set(toFirestore());
      print("Booking saved to Firestore.");
    } catch (e) {
      print("Error saving booking to Firestore: $e");
    }
  }

  // ฟังก์ชันอัปเดตสถานะการคืนรถใน Firestore
  Future<void> updateReturnStatusInFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'isReturned': isReturned,
        'actualReturnTime': actualReturnTime,
        'penalty': penalty,
      });
      print("Return status updated in Firestore.");
    } catch (e) {
      print("Error updating return status in Firestore: $e");
    }
  }

  // Getter สำหรับรายละเอียดการจองพื้นฐาน
  String get basicBookingDetails => 
    'Booking ID: $bookingId, Motorbike: ${motorbike.name}, Price: $totalPrice';

  // Getter สำหรับรายละเอียดการจองพร้อมจัดรูปแบบวันที่
  String get detailedBookingDetails => 
    'Pickup: ${DateFormat('dd/MM/yyyy').format(pickupDate)}, Return: ${DateFormat('dd/MM/yyyy').format(returnDate)}, Motorbike: ${motorbike.name}, Price: $totalPrice';

  // Method สำหรับคำนวณราคารวม
  double getTotalPrice() {
    if (days <= 0 || totalPrice < 0) {
      throw ArgumentError('จำนวนวันหรือราคาต่อวันไม่ถูกต้อง');
    }
    return (totalPrice * days) + deposit;
  }

  // Method สำหรับแปลงข้อมูลจาก Firestore มาเป็น Booking object
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Booking(
      bookingId: data['bookingId'] ?? '',
      id: doc.id,
      pickupDate: (data['pickupDate'] as Timestamp).toDate(),
      returnDate: (data['returnDate'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      days: data['days'] ?? 0,
      deposit: (data['deposit'] ?? 0).toDouble(),
      distance: (data['distance'] ?? 0).toDouble(),
      motorbike: Motorbike.fromFirestore(data['motorbike']),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      isPaid: data['isPaid'] ?? false,
      isReturned: data['isReturned'] ?? false,
      actualReturnTime: data['actualReturnTime'] != null ? (data['actualReturnTime'] as Timestamp).toDate() : null,
      penalty: (data['penalty'] ?? 0).toDouble(),
      isPenaltyPaid: data['isPenaltyPaid'] ?? false,
      paymentImageUrl: data['paymentImageUrl'],
      isBooked: data['isBooked'] ?? false,
    );
  }

  // Method สำหรับแปลง Booking object ไปเป็นรูปแบบที่เหมาะสำหรับบันทึกใน Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'id': id,
      'pickupDate': pickupDate,
      'returnDate': returnDate,
      'location': location,
      'days': days,
      'deposit': deposit,
      'distance': distance,
      'motorbike': motorbike.toFirestore(), // Assuming Motorbike has toFirestore method
      'totalPrice': totalPrice,
      'isPaid': isPaid,
      'isReturned': isReturned,
      'actualReturnTime': actualReturnTime,
      'penalty': penalty,
      'isPenaltyPaid': isPenaltyPaid,
      'paymentImageUrl': paymentImageUrl, // เก็บ URL รูปภาพที่อัปโหลด
    };
  }

  @override
  String toString() {
    return 'Booking(pickupDate: ${DateFormat('dd/MM/yyyy').format(pickupDate)}, returnDate: ${DateFormat('dd/MM/yyyy').format(returnDate)}, location: $location, motorbike: ${motorbike.name}, totalPrice: $totalPrice, isPaid: $isPaid)';
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // สร้าง Motorbike object
  Motorbike motorbike = Motorbike(
    id: 'bike001',
    name: 'Yamaha NMAX',
    brand: 'Yamaha',
    description: 'A powerful and stylish scooter.',
    color: 'Blue',
    totalPrice: 100.0,
    images: [],
    features: [],
  );

  // สร้าง Booking object
  Booking booking = Booking(
    bookingId: '12345',
    id: 'bike001', // ใส่ id สำหรับการจองนี้
    pickupDate: DateTime.now(),
    returnDate: DateTime.now().add(Duration(days: 3)),
    location: 'Chiang Mai',
    days: 3,
    deposit: 500.0,
    distance: 20.0,
    motorbike: motorbike,
    totalPrice: 300.0,
    paymentImageUrl: "https://example.com/payment.jpg", // ตัวอย่าง URL รูปภาพ
    isBooked: false,
);

  // คืนรถ
  booking.returnMotorbike();

  // อัปเดตสถานะการคืนรถใน Firestore
  await booking.updateReturnStatusInFirestore();

  // แสดงรายละเอียดการจองหลังคืนรถ
  print('After returning the motorbike:');
  print(booking.detailedBookingDetails);
  print('Penalty: ${booking.penalty}');
}
