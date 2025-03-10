// import 'package:flutter/material.dart';
// import 'package:motorbike/features/vehicle_summary.dart';
// import 'package:motorbike/features/booking_details.dart';
// import 'package:motorbike/model/booking.dart';  // Import Booking model

// class SuccessPage extends StatelessWidget {
//   // รับข้อมูล Booking จากการชำระเงิน
//   final Booking booking;
//   final String bookingId;

//   const SuccessPage({
//     Key? key, 
//     required this.booking,
//     required this.bookingId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('การชำระเงินสำเร็จ'),
//         backgroundColor: Colors.pinkAccent,
//         centerTitle: true,
//         toolbarHeight: 70.0,
//         titleTextStyle: const TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//         iconTheme: const IconThemeData(
//           color: Colors.white, // กำหนดสีของไอคอนใน AppBar เป็นสีขาว
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 100),
//             const SizedBox(height: 20),
//             const Text(
//               'การชำระเงินสำเร็จแล้ว!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // ส่งกลับไปยัง VehicleSummaryPage พร้อมกับการตั้งค่า index ให้เป็น 0 (หน้าหลัก)
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                     builder: (context) => VehicleSummaryPage(initialIndex: 0),
//                   ),
//                   (Route<dynamic> route) => false,  // ลบหน้าอื่นออกจาก stack
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 textStyle: const TextStyle(fontSize: 18),
//               ),
//               child: const Text('กลับสู่หน้าแรก'),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 // ส่งข้อมูลการจองไปยัง BookingDetailsPage
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => BookingDetailsPage(
//                       booking: booking,  // ส่งข้อมูลการจองที่ถูกต้อง
//                       bookingId: bookingId,
//                     ),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 textStyle: const TextStyle(fontSize: 18),
//               ),
//               child: const Text('ดูข้อมูลการจอง'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
