import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorbike/model/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveBookingToFirestore(Booking booking) async {
    try {
      await _firestore.collection('bookings').add({
        'motorbike': {
          'name': booking.motorbike.name,
          'color': booking.motorbike.color,
          'totalPrice': booking.motorbike.totalPrice,
          'brand': booking.motorbike.brand,
          'description': booking.motorbike.description,
        },
        'days': booking.days,
        'deposit': booking.deposit,
        'distance': booking.distance,
        'location': booking.location,
        'pickupDate': booking.pickupDate,
        'returnDate': booking.returnDate,
        'totalPrice': booking.totalPrice,
        'isPaid': booking.isPaid,
      });
    } catch (e) {
      throw Exception('Error saving booking to Firestore: $e');
    }
  }
}
