import 'package:flutter/material.dart';
import 'package:motorbike/model/motorbike.dart'; // นำเข้า Motorbike

class VehicleDetailsPage extends StatelessWidget {
  final Motorbike motorbike;

  VehicleDetailsPage({required this.motorbike});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(motorbike.name),
      ),
      body: SingleChildScrollView( // ใช้ SingleChildScrollView เพื่อรองรับการเลื่อน
        child: Column(
          children: [
            // แสดงรูปภาพของมอเตอร์ไซค์
            Container(
              margin: EdgeInsets.all(10.0),
              child: Image.asset(
                motorbike.images.first, // แสดงรูปแรก
                fit: BoxFit.cover,
                height: 200, // กำหนดความสูงของรูปภาพ
                width: double.infinity, // กำหนดความกว้างให้เต็ม
              ),
            ),
            // แสดงรายละเอียดของมอเตอร์ไซค์
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายละเอียด: ${motorbike.description}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'สี: ${motorbike.color}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ราคา: ${motorbike.totalPrice}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ฟีเจอร์: ${motorbike.features}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
