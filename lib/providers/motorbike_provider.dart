import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorbike/model/motorbike.dart';

class MotorbikeProvider with ChangeNotifier {
  List<Motorbike> _motorbikes = [];  // เก็บลิสต์ของมอเตอร์ไซค์

  List<Motorbike> get motorbikes => _motorbikes;  // getter สำหรับลิสต์มอเตอร์ไซค์

  // ฟังก์ชันดึงข้อมูลจาก Firestore
  Future<void> fetchMotorbikesFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('motorbikes').get();
      _motorbikes = snapshot.docs.map((doc) => Motorbike.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
      notifyListeners();  // แจ้งเตือนเมื่อข้อมูลมีการอัปเดต
    } catch (error) {
      print('Error fetching motorbikes: $error');
    }
  }

  // ฟังก์ชันเพิ่มมอเตอร์ไซค์ใหม่
  Future<void> addMotorbike(Motorbike motorbike) async {
    try {
      await FirebaseFirestore.instance.collection('motorbikes').add(motorbike.toFirestore());
      _motorbikes.add(motorbike);
      notifyListeners();  // แจ้งเตือนเมื่อข้อมูลมีการอัปเดต
    } catch (error) {
      print('Error adding motorbike: $error');
    }
  }
}
