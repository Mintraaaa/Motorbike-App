import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:motorbike/page/driver_license.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  final TextEditingController _contactnameController = TextEditingController();
  final TextEditingController _contactlastnameController = TextEditingController();
  final TextEditingController _contactphoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _contactnameController.dispose();
    _contactlastnameController.dispose();
    _contactphoneController.dispose();
    super.dispose();
  }

  void fetchEmergencyContacts() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('emergencycontacts')
            .where('userid', isEqualTo: userId)  // กรองข้อมูลโดย `userid`
            .get();

        querySnapshot.docs.forEach((doc) {
          print('Contact Name: ${doc["contactname"]}');
          print('Contact Last Name: ${doc["contactlastname"]}');
          print('Contact Phone Number: ${doc["contactphone"]}');
        });
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error fetching emergency contacts: $e');
    }
  }


  Future<void> _saveEmergencyContact() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final emergencyContact = {
          'contactname': _contactnameController.text,
          'contactlastname': _contactlastnameController.text,
          'contactphone': _contactphoneController.text,
          'userid': FirebaseAuth.instance.currentUser?.uid, 
        };

        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final contactDocRef = FirebaseFirestore.instance
              .collection('emergencycontacts')
              .doc();  // Generate a new document ID for each contact

          await contactDocRef.set({
            ...emergencyContact,
            'contactid': contactDocRef.id,  // Save the generated contact ID
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ข้อมูลถูกบันทึกเรียบร้อยแล้ว')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverLicensePage()),
          );
          
          _contactnameController.clear();
          _contactlastnameController.clear();
          _contactphoneController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่อีกครั้ง')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(225, 245, 254, 1.0),
      appBar: AppBar(
        title: Text(
          'ข้อมูลการติดต่อในกรณีฉุกเฉิน',
          style: TextStyle(
            fontSize: 24, 
            color: Colors.white,
            fontFamily: 'Noto Sans Thai',
            fontWeight: FontWeight.w500, 
          ),
        ),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1.0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _contactnameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ',
                  border: OutlineInputBorder(),
                  labelStyle: const TextStyle(
                    fontSize: 20, 
                    color: Colors.grey, 
                    fontFamily: 'Noto Sans Thai',
                    fontWeight: FontWeight.w500,   
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(13, 71, 161, 1.0), // เส้นขอบสีน้ำเงินเข้มเมื่อ focus
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // เส้นขอบสีน้ำเงินเข้มเมื่อกรอกข้อมูลเสร็จ
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      fontSize: 22, 
                      color: Color.fromRGBO(13, 71, 161, 1.0), // เปลี่ยนเป็นสีน้ำเงินเข้มตามธีม
                    ),
                    filled: true,
                    fillColor: Color.fromRGBO(225, 245, 254, 1.0), // สีพื้นหลังของช่องกรอกข้อมูล
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactlastnameController,
                decoration: InputDecoration(
                  labelText: 'นามสกุล',
                  border: OutlineInputBorder(),
                  labelStyle: const TextStyle(
                    fontSize: 20, 
                    color: Colors.grey, 
                    fontFamily: 'Noto Sans Thai',
                    fontWeight: FontWeight.w500,   
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(13, 71, 161, 1.0), // เส้นขอบสีน้ำเงินเข้มเมื่อ focus
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // เส้นขอบสีน้ำเงินเข้มเมื่อกรอกข้อมูลเสร็จ
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      fontSize: 22, 
                      color: Color.fromRGBO(13, 71, 161, 1.0), // เปลี่ยนเป็นสีน้ำเงินเข้มตามธีม
                    ),
                    filled: true,
                    fillColor: Color.fromRGBO(225, 245, 254, 1.0), // สีพื้นหลังของช่องกรอกข้อมูล
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกนามสกุล';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactphoneController,
                decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  border: OutlineInputBorder(),
                  labelStyle: const TextStyle(
                    fontSize: 20, 
                    color: Colors.grey, 
                    fontFamily: 'Noto Sans Thai',
                    fontWeight: FontWeight.w500,   
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(13, 71, 161, 1.0), // เส้นขอบสีน้ำเงินเข้มเมื่อ focus
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // เส้นขอบสีน้ำเงินเข้มเมื่อกรอกข้อมูลเสร็จ
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      fontSize: 22, 
                      color: Color.fromRGBO(13, 71, 161, 1.0), // เปลี่ยนเป็นสีน้ำเงินเข้มตามธีม
                    ),
                    filled: true,
                    fillColor: Color.fromRGBO(225, 245, 254, 1.0), // สีพื้นหลังของช่องกรอกข้อมูล
                  ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.length != 10 || !RegExp(r'^\d+$').hasMatch(value)) {
                    return 'กรุณากรอกเบอร์โทรศัพท์ 10 หลัก';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () async {
                  // บันทึกข้อมูลฉุกเฉิน
                  await _saveEmergencyContact();

                  // หลังจากบันทึกข้อมูลแล้ว เด้งไปยังหน้า DriverLicensePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverLicensePage()),
                  );
                },
                child: Text(
                  'บันทึกข้อมูล',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
