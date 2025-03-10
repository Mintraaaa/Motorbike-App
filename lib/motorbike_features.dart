import 'package:flutter/material.dart';

class MotorbikeFeatureDisplay extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const MotorbikeFeatureDisplay({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30, // ขนาดของวงกลม
          backgroundColor: Colors.grey[200], // สีพื้นหลังวงกลม
          child: Icon(icon, size: 30, color: Colors.grey[700]), // ไอคอนที่อยู่ในวงกลม
        ),
        SizedBox(height: 8), // ช่องว่างระหว่างไอคอนกับข้อความ
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class MotorbikeFeatureList extends StatelessWidget {
  // สร้างรายการฟีเจอร์เป็น List
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.directions_car, 'label': 'ประเภท', 'value': 'รถเก๋ง 4 ประตู'},
    {'icon': Icons.build, 'label': 'ระบบเกียร์', 'value': 'เกียร์ออโต้'},
    {'icon': Icons.local_gas_station, 'label': 'ระบบเชื้อเพลิง', 'value': 'น้ำมันเบนซิน'},
    {'icon': Icons.speed, 'label': 'ความจุเครื่องยนต์', 'value': '1200 cc'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Motorbike Features")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // จำนวนคอลัมน์
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: features.map((feature) {
            return MotorbikeFeatureDisplay(
              icon: feature['icon'],
              label: feature['label'],
              value: feature['value'],
            );
          }).toList(),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MotorbikeFeatureList(),
  ));
}
