import 'package:flutter/material.dart'; //หน้าแนะนำ
import 'package:motorbike/model/motorbike.dart';
import 'package:motorbike/features/motorbike_detail.dart';  // นำเข้าหน้ารายละเอียด

class MotorRecommendationsPage extends StatelessWidget {
  final List<Motorbike> motorbikes;
  final Function(Motorbike) onMotorbikeTap;

  MotorRecommendationsPage({
    required this.motorbikes,
    required this.onMotorbikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: motorbikes.length,
        itemBuilder: (context, index) {
          final motorbike = motorbikes[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 4.0, // เพิ่มเงาให้กับ Card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // ปรับขอบมนของ Card
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // เพิ่มขอบมนให้รูปภาพ
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: FittedBox(
                    fit: BoxFit.cover, // ใช้ BoxFit.cover เพื่อให้ภาพเต็มพื้นที่
                    child: Image.asset(
                      motorbike.images.isNotEmpty
                          ? motorbike.images[0]
                          : 'assets/images/placeholder.png', // ตรวจสอบว่ามีรูปภาพหรือไม่
                    ),
                  ),
                ),
              ),
              title: Text(
                motorbike.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // กำหนดขนาดตัวอักษรให้ใหญ่ขึ้น
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4.0),
                  Text(
                    'แบรนด์: ${motorbike.brand}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // ปรับขนาดตัวอักษร
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'ราคา: ${motorbike.totalPrice} บาท/วัน',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 16, // ปรับขนาดตัวอักษร
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MotorbikeDetailPage(motorbike: motorbike),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
