import 'package:flutter/material.dart';
import 'package:motorbike/features/vehicle_details.dart'; // นำเข้าหน้ารายละเอียดรถมอเตอร์ไซค์
import 'package:motorbike/model/motorbike.dart'; // นำเข้าโมเดล Motorbike

class MotorcycleListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการมอเตอร์ไซค์'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // สร้างข้อมูลมอเตอร์ไซค์เป็นอ็อบเจ็กต์ Motorbike
            final Motorbike motorbike = Motorbike(
              id: 'bike001',
              images: ['assets/images/filano_g2023.png'],
              name: 'Grand Filano Hybrid ABS',
              brand: 'YAMAHA',
              description: 'สกูตเตอร์ดีไซน์หรู พร้อมเทคโนโลยีไฮบริดและ ABS ประหยัดน้ำมัน ปลอดภัย',
              color: 'สีเทา (Elixir Silver)',
              totalPrice: 400.0,
              features: [
                MotorbikeFeature(icon: Icons.people, name: '2'),
                MotorbikeFeature(icon: Icons.security, name: 'ABS'),
                MotorbikeFeature(icon: Icons.smart_toy, name: 'ระบบสมาร์ทคีย์'),
                MotorbikeFeature(icon: Icons.local_gas_station, name: 'ประหยัดน้ำมัน'),
              ],
            );

            // นำทางไปยังหน้ารายละเอียดรถมอเตอร์ไซค์
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VehicleDetailsPage(motorbike: motorbike),
              ),
            );
          },
          child: const Text('แสดงรายละเอียดมอเตอร์ไซค์'),
        ),
      ),
    );
  }
}
