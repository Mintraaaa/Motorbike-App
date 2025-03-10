import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MotorbikeFeature {
  final IconData icon; // เก็บข้อมูลไอคอนของฟีเจอร์
  final String name; // ชื่อฟีเจอร์

  MotorbikeFeature({
    required this.icon,
    required this.name,
  });
}
class Motorbike {
  final String id;
  final List<String> images;
  final String name;
  final String brand;
  final String description;
  final String color;
  final double totalPrice;
  final List<MotorbikeFeature> features;
  bool isBooked; // ฟิลด์ที่มีอยู่เดิม
  bool isPaid; // ฟิลด์ใหม่สำหรับสถานะการชำระเงิน

  Motorbike({
    required this.id,
    required this.images,
    required this.name,
    required this.brand,
    required this.description,
    required this.color,
    required this.totalPrice,
    required this.features,
    this.isBooked = false,
    this.isPaid = false, // กำหนดค่าเริ่มต้นเป็น false
  });

  // Convert Motorbike object to a Map for Firestore
   Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'images': images,
      'name': name,
      'brand': brand,
      'description': description,
      'color': color,
      'totalprice': totalPrice,
      'features': features.map((feature) => {
        'icon': feature.icon.codePoint,
        'name': feature.name,
        'fontFamily': feature.icon.fontFamily, // บันทึก fontFamily ของไอคอน
      }).toList(), // แปลงฟีเจอร์เป็น Map
      'isBooked': isBooked,
      'isPaid': isPaid,
    };
  }
  
  // แปลงข้อมูล Map จาก Firestore กลับมาเป็น Motorbike
  factory Motorbike.fromFirestore(Map<String, dynamic> map) {
    return Motorbike(
      id: map['id'],
      images: List<String>.from(map['images']),
      name: map['name'],
      brand: map['brand'],
      description: map['description'],
      color: map['color'],
      totalPrice: map['totalprice'].toDouble(),
      features: (map['features'] as List).map((featureMap) => MotorbikeFeature(
        // ดึงข้อมูล icon และฟอนต์มาใช้สร้าง IconData
        icon: IconData(
          featureMap['icon'],
          fontFamily: featureMap['fontFamily'],  // ใช้ฟอนต์ที่บันทึกไว้
        ),
        name: featureMap['name'],
      )).toList(),
    );
  }
}


/// บริการ Firestore สำหรับเพิ่มและจัดการข้อมูล Motorbike
class MotorbikeService {
  final CollectionReference motorbikesRef =
      FirebaseFirestore.instance.collection('motorbikes');

  // ฟังก์ชันเพิ่มมอเตอร์ไซค์ใหม่ลง Firestore พร้อมกับกำหนด id เอง
  Future<void> addMotorbikeToFirestore(Motorbike motorbike) async {
    try {
      DocumentReference docRef = motorbikesRef.doc(motorbike.id); // กำหนด id เอง
      await docRef.set(motorbike.toFirestore());  // ใช้ set() แทน add()
      print('Motorbike added successfully with id: ${motorbike.id}');
    } catch (error) {
      print('Error adding motorbike: $error');
    }
  }

  // เพิ่มมอเตอร์ไซค์ทั้งหมด
  Future<void> addAllMotorbikes(List<Motorbike> motorbikeList) async {
    for (var motorbike in motorbikeList) {
      try {
        print('Adding motorbike with id: ${motorbike.id}'); // เพิ่ม print เพื่อตรวจสอบ
        await addMotorbikeToFirestore(motorbike);
      } catch (error) {
        print('Error adding motorbike: $error');
      }
    }
    print('All motorbikes added successfully');
  }

  // ฟังก์ชันรีเซ็ตสถานะ isBooked เป็น false สำหรับมอเตอร์ไซค์ทุกคันใน Firestore
  Future<void> resetAllMotorbikesStatus() async {
    final motorbikesSnapshot = await motorbikesRef.get();

    for (var doc in motorbikesSnapshot.docs) {
      await doc.reference.update({'isBooked': false});
    }
    print('All motorbikes have been reset to isBooked: false');
  }
}

// รายการมอเตอร์ไซค์
List<Motorbike> motorbikeList = [
  Motorbike(
    id: 'bike001',
    images: ['assets/images/filano_g2023.png'],
    name: 'Grand Filano Hybrid ABS',
    brand: 'YAMAHA',
    description: 'สกูตเตอร์ดีไซน์หรู พร้อมเทคโนโลยีไฮบริดและ ABS ประหยัดน้ำมัน ปลอดภัย',
    color: 'สีเทา (Elixir Silver)',
    totalPrice: 400.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'ABS'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike002',
    images: ['assets/images/filano_b2023.png'],
    name: 'Grand Filano Hybrid ABS',
    brand: 'YAMAHA',
    description: 'สกูตเตอร์ดีไซน์หรู พร้อมเทคโนโลยีไฮบริดและ ABS ประหยัดน้ำมัน ปลอดภัย',
    color: 'สีน้ำเงิน (Prestige Blue)',
    totalPrice: 400.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'ABS'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike003',
    images: ['assets/images/pcx_g.png'],
    name: 'PCX160',
    brand: 'HONDA',
    description: 'Honda PCX160 เป็นมอเตอร์ไซค์ออโตเมติก ดีไซน์ทันสมัย ประหยัดน้ำมัน มี ABS และระบบสมาร์ทคีย์',
    color: 'สีขาว-ดำ (White-Black)',
    totalPrice: 550.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'ABS'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '160 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike004',
    images: ['assets/images/pcx_r.png'],
    name: 'PCX160',
    brand: 'HONDA',
    description: 'Honda PCX160 เป็นมอเตอร์ไซค์ออโตเมติก ดีไซน์ทันสมัย ประหยัดน้ำมัน มี ABS และระบบสมาร์ทคีย์',
    color: 'สีแดง-ดำ (Red-Black)',
    totalPrice: 550.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'ABS'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '160 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),  
  Motorbike(
    id: 'bike005',
    images: ['assets/images/scoopy_bk.png'],
    name: 'Scoopy Urban',
    brand: 'HONDA',
    description: 'ระบบเบรกที่ปลอดภัยและพื้นที่เก็บของที่สะดวกสบาย มีการตกแต่งที่มีเอกลักษณ์และการออกแบบที่เน้นความเรียบหรู',
    color: 'สีดำ-ขาว (Black-White)',
    totalPrice: 300.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '110 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike006',
    images: ['assets/images/scoopy_bw.png'],
    name: 'Scoopy Urban',
    brand: 'HONDA',
    description: 'ระบบเบรกที่ปลอดภัยและพื้นที่เก็บของที่สะดวกสบาย มีการตกแต่งที่มีเอกลักษณ์และการออกแบบที่เน้นความเรียบหรู',
    color: 'สีน้ำตาล-ขาว (Brown-White)',
    totalPrice: 300.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '110 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike007',
    images: ['assets/images/click_rd.png'],
    name: 'Click 125',
    brand: 'HONDA',
    description: 'สกูตเตอร์ขนาดกลางที่ทันสมัย ขับขี่คล่องตัว ประหยัดน้ำมัน และมีฟีเจอร์เทคโนโลยีที่ทันสมัย',
    color: 'สีแดง-ดำ (Red-Black)',
    totalPrice: 300.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike008',
    images: ['assets/images/fino_b.png'],
    name: 'Fino 125',
    brand: 'YAMAHA',
    description: 'Fino Final Edition เป็นสกูตเตอร์สุดคลาสสิก ประหยัดน้ำมัน มีระบบเบรกที่ปลอดภัย',
    color: 'สีดำ (Original Black)',
    totalPrice: 280.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike009',
    images: ['assets/images/fino_r.png'],
    name: 'Fino 125',
    brand: 'YAMAHA',
    description: 'Fino Final Edition เป็นสกูตเตอร์สุดคลาสสิก ประหยัดน้ำมัน มีระบบเบรกที่ปลอดภัย',
    color: 'สีแดง (Red)',
    totalPrice: 280.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike010',
    images: ['assets/images/abs_rb.png'],
    name: 'Giorno+',
    brand: 'HONDA',
    description: 'สกูตเตอร์สไตล์คลาสสิกที่มาพร้อมฟีเจอร์ทันสมัย ขับขี่สบายและมีการออกแบบที่โดดเด่น',
    color: 'สีแดง-ดำ (Red-Black)',
    totalPrice: 400.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: ' Combi-Brake'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '110 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike011',
    images: ['assets/images/cbs_yb.png'],
    name: 'Giorno+',
    brand: 'HONDA',
    description: 'สกูตเตอร์สไตล์คลาสสิกที่มาพร้อมฟีเจอร์ทันสมัย ขับขี่สบายและมีการออกแบบที่โดดเด่น',
    color: 'สีเหลือง-ดำ (Yellow-Black)',
    totalPrice: 400.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: ' Combi-Brake'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '110 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
  Motorbike(
    id: 'bike012',
    images: ['assets/images/abs_gp.png'],
    name: 'AEROX',
    brand: 'YAMAHA',
    description: 'สกูตเตอร์สปอร์ตที่เน้นการออกแบบทันสมัยและการขับขี่ที่เร็วแรง มีระบบเทคโนโลยีขั้นสูงและความสะดวกสบายในการใช้งาน',
    color: 'สีเทา-ม่วง (Magic Purple)',
    totalPrice: 400.0,
    features: [
      MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
      MotorbikeFeature(icon: Icons.security, name: 'ABS'),
      MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
      MotorbikeFeature(icon: Icons.memory, name: '155 cc'),
      MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
    ],
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // สำหรับการใช้งาน Firestore
  await Firebase.initializeApp(); // เริ่มต้น Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MotorbikeService motorbikeService = MotorbikeService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motorbike App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Motorbike Upload'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    await motorbikeService.addAllMotorbikes(motorbikeList);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Motorbike data has been uploaded')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to upload motorbikes: $error')),
                    );
                  }
                },
                child: const Text('Upload Motorbikes to Firestore'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await motorbikeService.resetAllMotorbikesStatus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('All motorbikes have been reset to available')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to reset motorbikes: $error')),
                    );
                  }
                },
                child: const Text('Reset All Motorbikes to Available'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

