import 'package:flutter/material.dart';
import 'package:motorbike/page/signup.dart';
import 'package:motorbike/page/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Color myColor;
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 71, 161, 1.0),
      body: Stack(
        children: [
          Positioned(child: _buildTop()),
        ],
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Image.asset(
              'assets/images/logo1.png',
              height: 250, // ขนาดโลโก้
            ),
          ),
          // ใช้ Transform เพื่อเลื่อนข้อความขึ้นให้ชิดกับโลโก้มากขึ้น
          Transform.translate(
            offset: const Offset(0, -50), // เลื่อนข้อความขึ้น (ค่าติดลบทำให้ใกล้โลโก้)
            child: const Text(
              'Bike Buddy',
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // เพิ่มความโค้งมน
              ),
              backgroundColor: Colors.transparent, // สีพื้นหลังโปร่งใส
              shadowColor: Colors.black45, // เพิ่มเงา
              elevation: 5, // เพิ่มเงาเล็กน้อย
            ),
            child: Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff6DC8F3), // ฟ้า
                    Color(0xff2196F3), // ฟ้าน้ำเงิน
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [ // เพิ่มเงาให้ปุ่ม
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.black45,
              elevation: 5,
            ),
            child: Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff6DC8F3), // ฟ้า
                    Color(0xff2196F3), // ฟ้าน้ำเงิน
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
