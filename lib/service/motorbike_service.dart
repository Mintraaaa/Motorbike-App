import 'package:cloud_firestore/cloud_firestore.dart';

class MotorbikeService {
  final CollectionReference motorbikesRef =
      FirebaseFirestore.instance.collection('motorbikes');

  // ฟังก์ชันสำหรับจองมอเตอร์ไซค์ (อัปเดต isBooked เป็น true)
  Future<void> bookMotorbike(String bikeId) async {
    try {
      DocumentReference motorbikeRef = motorbikesRef.doc(bikeId);
      await motorbikeRef.update({'isBooked': true});
      print('มอเตอร์ไซค์ $bikeId ถูกจองแล้ว');
    } catch (error) {
      print('Error booking motorbike: $error');
    }
  }

  // ฟังก์ชันสำหรับคืนมอเตอร์ไซค์ (อัปเดต isBooked เป็น false)
  Future<void> releaseMotorbike(String bikeId) async {
    try {
      DocumentReference motorbikeRef = motorbikesRef.doc(bikeId);
      await motorbikeRef.update({'isBooked': false});
      print('มอเตอร์ไซค์ $bikeId ถูกคืนแล้ว');
    } catch (error) {
      print('Error releasing motorbike: $error');
    }
  }
}
