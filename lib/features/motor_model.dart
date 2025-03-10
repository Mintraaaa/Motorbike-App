import 'package:flutter/material.dart';
import 'package:motorbike/features/motorbike_detail.dart';
import 'package:motorbike/model/motorbike.dart';

class MotorModelPage extends StatefulWidget {
  final List<Motorbike> motorbikes; // รับลิสต์ motorbikes ผ่าน constructor

  const MotorModelPage({Key? key, required this.motorbikes}) : super(key: key);

  @override
  _MotorModelPageState createState() => _MotorModelPageState();
}

class _MotorModelPageState extends State<MotorModelPage> {
  // ใช้ ValueNotifier เพื่อเก็บค่ายรถที่เลือก
  final ValueNotifier<String> _selectedBrand = ValueNotifier<String>('');

  @override
  void dispose() {
    _selectedBrand.dispose(); // ปลดการเชื่อมต่อเมื่อไม่ใช้งานแล้ว
    super.dispose();
  }

  Widget buildMotorbikeTile(Motorbike motorbike) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // ปรับ margin ให้เหมาะสม
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // ปรับขอบให้มีความมนมากขึ้น
      ),
      elevation: 4.0, // เพิ่ม shadow ให้กับ Card
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            motorbike.images.isNotEmpty ? motorbike.images[0] : 'assets/images/placeholder.png',
            width: 100,
            height: 100, // กำหนดความสูงให้กับภาพ
            fit: BoxFit.cover, // ใช้ BoxFit.cover เพื่อให้ภาพเต็มพื้นที่
          ),
        ),
        title: Text(
          motorbike.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(
              'แบรนด์: ${motorbike.brand}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4.0),
            Text(
              'ราคา: ${motorbike.totalPrice} บาท/วัน',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 16),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MotorbikeDetailPage(motorbike: motorbike),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // แถวสำหรับเลือกค่ายรถ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: _selectedBrand,
                  builder: (context, selectedBrand, _) {
                    return _buildBrandButton('YAMAHA', Colors.black, Colors.blue, selectedBrand);
                  },
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _selectedBrand,
                  builder: (context, selectedBrand, _) {
                    return _buildBrandButton('HONDA', Colors.black, Colors.blue, selectedBrand);
                  },
                ),
              ],
            ),
          ),
          // รายการรถมอเตอร์ไซค์ที่กรองตามค่ายรถ
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _selectedBrand,
              builder: (context, selectedBrand, _) {
                final filteredMotorbikes = widget.motorbikes
                    .where((motorbike) => motorbike.brand == selectedBrand || selectedBrand.isEmpty)
                    .toList();

                return ListView.builder(
                  itemCount: filteredMotorbikes.length,
                  itemBuilder: (context, index) {
                    return buildMotorbikeTile(filteredMotorbikes[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandButton(
      String brand, Color activeColor, Color inactiveColor, String selectedBrand) {
    return ElevatedButton(
      onPressed: () {
        _selectedBrand.value = brand;
      },
      child: Text(
        brand,
        style: TextStyle(
          color: selectedBrand == brand ? Colors.yellow : Colors.white,
          fontSize: selectedBrand == brand ? 20 : 18,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedBrand == brand ? activeColor : inactiveColor,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // เพิ่มความมนให้ปุ่ม
        ),
      ),
    );
  }
}
