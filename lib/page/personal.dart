import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';   //วันเดือนปี
import 'package:motorbike/page/emergency_contact.dart';

class PersonalPage extends StatefulWidget {
  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _nationalidController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _nationalidController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _savePersonal() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final personalInfo = {
          'firstname': _firstnameController.text,
          'lastname': _lastnameController.text,
          'nationalid': _nationalidController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'date': _dateController.text,
        };

        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set(personalInfo, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ข้อมูลถูกบันทึกเรียบร้อยแล้ว')),
          );

          // ล้างข้อมูลในฟิลด์หลังจากบันทึกข้อมูลเสร็จ
          _firstnameController.clear();
          _lastnameController.clear();
          _nationalidController.clear();
          _addressController.clear();
          _phoneController.clear();
          _dateController.clear();

          // นำทางไปยังหน้า EmergencyContactPage หลังจากบันทึกข้อมูลเสร็จ
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmergencyContactPage()),
          );
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,  // ปรับขนาดอัตโนมัติเมื่อมีคีย์บอร์ดขึ้นมา
      backgroundColor: Color.fromRGBO(225, 245, 254, 1.0),
      appBar: AppBar(
        title: Text(
          'ข้อมูลส่วนตัว',
          style: TextStyle(
            fontSize: 24, 
            color: Colors.white,
            fontFamily: 'Noto Sans Thai',
            fontWeight: FontWeight.w500, 
          ),
        ),
        backgroundColor: const Color.fromRGBO(13, 71, 161, 1.0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstnameController,
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
                controller: _lastnameController,
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
                controller: _nationalidController,
                decoration: InputDecoration(
                  labelText: 'เลขบัตรประชาชน',
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
                validator: (value) {
                  if (value == null ||
                      value.length != 13 ||
                      !RegExp(r'^\d+$').hasMatch(value)) {
                    return 'กรุณากรอกเลขบัตรประชาชน';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'ที่อยู่',
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
                style: TextStyle(fontFamily: 'Sarabun'), // ใช้ฟอนต์ภาษาไทย
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกที่อยู่';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
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
                  FilteringTextInputFormatter.digitsOnly, // รับเฉพาะตัวเลข
                ],
                validator: (value) {
                  if (value == null ||
                      value.length != 10 ||
                      !RegExp(r'^\d+$').hasMatch(value)) {
                    return 'กรุณากรอกเบอร์โทรศัพท์';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'วัน-เดือน-ปีเกิด (YYYY-MM-DD)',
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
                readOnly: true, // ป้องกันไม่ให้พิมพ์เอง
                onTap: () => _selectDate(context), // เปิด DatePicker เมื่อกด
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเลือกวัน-เดือน-ปีเกิด';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: _savePersonal,
                child: Text(
                  'บันทึกข้อมูล',
                  style: TextStyle(
                    fontSize: 20, 
                    color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
