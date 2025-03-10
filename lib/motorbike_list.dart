import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motorbike/model/motorbike.dart'; // อย่าลืมนำเข้าโมเดล Motorbike ของคุณ

class MotorbikeListPage extends StatelessWidget {
  final CollectionReference motorbikesRef =
      FirebaseFirestore.instance.collection('motorbikes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motorbike List'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: motorbikesRef.snapshots(), // ดึงข้อมูลแบบเรียลไทม์
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // ดึงข้อมูลจาก snapshot และแปลงกลับเป็นรายการมอเตอร์ไซค์
          final motorbikes = snapshot.data!.docs.map((doc) {
            return Motorbike.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: motorbikes.length,
            itemBuilder: (context, index) {
              final motorbike = motorbikes[index];
              return ListTile(
                leading: Image.asset(
                  motorbike.images[0], // รูปภาพของมอเตอร์ไซค์
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(motorbike.name),
                subtitle: Text(motorbike.description),
              );
            },
          );
        },
      ),
    );
  }
}
