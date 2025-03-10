import 'package:flutter/foundation.dart';
import 'package:motorbike/model/booking.dart'; // Import โมเดล Booking ที่คุณใช้ในแอป

class BookingProvider with ChangeNotifier {
  Booking? _currentBooking;  // ตัวแปรเก็บข้อมูลการจองปัจจุบัน
  String? _currentBookingId; // ตัวแปรเก็บ bookingId ของการจองปัจจุบัน

  // Getter สำหรับการดึงข้อมูลการจองปัจจุบันและ bookingId
  Booking? get currentBooking => _currentBooking;
  String? get currentBookingId => _currentBookingId;

  // Setter สำหรับตั้งค่าข้อมูลการจองปัจจุบัน
  void setCurrentBooking(Booking booking, String bookingId) {
    _currentBooking = booking;
    _currentBookingId = bookingId;
    notifyListeners(); // แจ้งให้ UI อัปเดตเมื่อมีการเปลี่ยนแปลงข้อมูล
  }
}
