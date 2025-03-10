import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motorbike/features/vehicle_summary.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // เพิ่มสำหรับ inputFormatters
import 'dart:io'; // สำหรับใช้กับ File

class DriverLicensePage extends StatefulWidget {
  const DriverLicensePage({super.key});

  @override
  State<DriverLicensePage> createState() => _DriverLicensePageState();
}

class _DriverLicensePageState extends State<DriverLicensePage> {
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _licenseIssueDateController = TextEditingController();
  final TextEditingController _licenseExpiryDateController = TextEditingController();
  final TextEditingController _licenseStatusController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _licenseType;
  XFile? _licenseImage;
  Color? _licenseStatusColor;
  bool isLoading = false; // ตัวแปรสถานะการอัปโหลดรูปภาพ

  // ฟังก์ชันแสดง DatePicker สำหรับเลือกวันที่
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        _validateDates(); // ตรวจสอบวันที่หลังจากเลือก
      });
    }
  }

  void _validateDates() {
    if (_licenseIssueDateController.text.isEmpty || _licenseExpiryDateController.text.isEmpty) {
      return; // ไม่ตรวจสอบหากข้อมูลวันที่ว่างเปล่า
    }

    try {
      DateTime issueDate = DateFormat('yyyy-MM-dd').parse(_licenseIssueDateController.text);
      DateTime expiryDate = DateFormat('yyyy-MM-dd').parse(_licenseExpiryDateController.text);
      int differenceInDays = expiryDate.difference(issueDate).inDays;

      // ตรวจสอบประเภทใบขับขี่กับวันที่
      if (_licenseType == 'รถจักรยานยนต์ส่วนบุคคล (2 ปี)' && differenceInDays != 730) {
        _showErrorDialogWithNewDateSelection('ใบขับขี่ชั่วคราวควรมีอายุ 2 ปี');
        return;
      } else if (_licenseType == 'รถจักรยานยนต์สาธารณะ (3 ปี)' && differenceInDays != 1095) {
        _showErrorDialogWithNewDateSelection('ใบขับขี่สาธารณะควรมีอายุ 3 ปี');
        return;
      } else if (_licenseType == 'รถจักรยานยนต์ส่วนบุคคล (5 ปี)') {
        if (differenceInDays != 1825) {
          _showInfoDialog('ใบขับขี่ถาวรควรมีอายุ 5 ปี แต่ใบขับขี่นี้มีอายุ ${differenceInDays ~/ 365} ปี ${differenceInDays % 365} วัน');
        }
      }


      _updateLicenseStatus(); // อัพเดตสถานะใบขับขี่
    } catch (e) {
      _showErrorDialog('รูปแบบวันที่ไม่ถูกต้อง');
    }
  }

  // ฟังก์ชันแสดงแจ้งเตือนแบบเบา ๆ
  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อมูลเพิ่มเติม'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateLicenseStatus() {
    try {
      DateTime expiryDate = DateFormat('yyyy-MM-dd').parse(_licenseExpiryDateController.text); // วันที่หมดอายุ
      DateTime currentDate = DateTime.now(); // วันที่ปัจจุบัน

      if (expiryDate.isAfter(currentDate)) {
        setState(() {
          _licenseStatusController.text = 'Valid'; // สถานะใบขับขี่ยังไม่หมดอายุ
          _licenseStatusColor = Colors.green; // เปลี่ยนสีข้อความเป็นสีเขียว
        });
      } else {
        setState(() {
          _licenseStatusController.text = 'Expired'; // สถานะใบขับขี่หมดอายุแล้ว
          _licenseStatusColor = Colors.red; // เปลี่ยนสีข้อความเป็นสีแดง
        });
      }
    } catch (e) {
      _showErrorDialog('รูปแบบวันที่ไม่ถูกต้อง');
    }
  }

  // ฟังก์ชันแสดงกล่องข้อความแจ้งเตือนเมื่อเกิดข้อผิดพลาด
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันแสดงข้อความแจ้งเตือนและให้เลือกวันใหม่
  void _showErrorDialogWithNewDateSelection(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
                _selectDate(context, _licenseExpiryDateController); // ให้ผู้ใช้เลือกวันหมดอายุใหม่
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับเลือกและอัปโหลดภาพใบขับขี่ไปยัง Firebase Storage
  Future<String?> _uploadLicenseImage() async {
    if (_licenseImage == null) return null;

    setState(() {
      isLoading = true; // แสดง Loading Indicator ขณะอัปโหลด
    });

    try {
      String fileName = 'driver_license/${FirebaseAuth.instance.currentUser?.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      // อัปโหลดรูปไปยัง Firebase Storage
      UploadTask uploadTask = storageRef.putFile(File(_licenseImage!.path));
      TaskSnapshot snapshot = await uploadTask;

      // ดึง URL ของภาพที่อัปโหลดได้
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false; // ซ่อน Loading Indicator เมื่ออัปโหลดเสร็จสิ้น
      });
      return downloadUrl;
    } catch (e) {
      setState(() {
        isLoading = false; // ซ่อน Loading Indicator เมื่อเกิดข้อผิดพลาด
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปโหลดภาพ: $e')));
      return null;
    }
  }

  // ฟังก์ชันสำหรับเลือกภาพจากอุปกรณ์
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _licenseImage = XFile(pickedImage.path); // เก็บภาพที่เลือก
      });
    }
  }

  // ฟังก์ชันตรวจสอบข้อมูลทั้งหมดก่อนบันทึก
  Future<void> _validateBeforeSave() async {
    if (_licenseType == null || _licenseType!.isEmpty) {
      _showErrorDialog('กรุณาเลือกประเภทใบขับขี่');
      return;
    }

    if (_licenseNumberController.text.isEmpty ||
        _licenseIssueDateController.text.isEmpty ||
        _licenseExpiryDateController.text.isEmpty) {
      _showErrorDialog('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    if (_licenseNumberController.text.length < 8 || _licenseNumberController.text.length > 9) {
      _showErrorDialog('หมายเลขใบขับขี่ต้องมี 8 หรือ 9 หลัก');
      return;
    }

    if (_licenseImage == null) {
      _showErrorDialog('กรุณาแนบรูปใบขับขี่');
      return;
    }

    // อัปโหลดภาพใบขับขี่ก่อนบันทึกข้อมูล
    String? imageUrl = await _uploadLicenseImage();
    if (imageUrl != null) {
      _saveDriverLicense(imageUrl); // บันทึกข้อมูลใบขับขี่พร้อม URL ของรูป
    } else {
      _showErrorDialog('การอัปโหลดรูปภาพล้มเหลว กรุณาลองใหม่อีกครั้ง');
    }
  }

  // ฟังก์ชันบันทึกข้อมูลใบขับขี่
  Future<void> _saveDriverLicense(String imageUrl) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final driverLicense = {
          'license_number': _licenseNumberController.text,
          'license_issuedate': _licenseIssueDateController.text,
          'license_expirydate': _licenseExpiryDateController.text,
          'license_status': _licenseStatusController.text,
          'license_type': _licenseType,
          'license_image_url': imageUrl, // เพิ่ม URL ของรูปใบขับขี่ที่อัปโหลดแล้ว
          'userid': FirebaseAuth.instance.currentUser?.uid,
        };

        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final drivingDocRef = FirebaseFirestore.instance.collection('DriverLicense').doc();

          await drivingDocRef.set({
            ...driverLicense,
            'drivingid': drivingDocRef.id,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ข้อมูลใบขับขี่ถูกบันทึกเรียบร้อยแล้ว')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VehicleSummaryPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่อีกครั้ง')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(225, 245, 254, 1.0),
      appBar: AppBar(
        title: const Text(
          'ข้อมูลใบอนุญาตขับขี่',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(13, 71, 161, 1.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _licenseType,
                decoration: InputDecoration(
                  labelText: _licenseType != null ? 'ประเภทใบขับขี่' : null, // แสดง labelText หลังจากเลือกข้อมูลแล้ว
                  labelStyle: TextStyle(
                    fontSize: 20, 
                    color: Color.fromRGBO(13, 71, 161, 1.0), 
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(13, 71, 161, 1.0), 
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always, // กำหนดให้แสดงตลอดเวลาเมื่อมีการเลือก
                  filled: true,
                  fillColor: Color.fromRGBO(225, 245, 254, 1.0),
                ),
                hint: Text(
                  'ประเภทใบอนุญาตขับขี่',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'รถจักรยานยนต์ส่วนบุคคล(2 ปี)',
                    child: Text(
                      'รถจักรยานยนต์ส่วนบุคคล(ชั่วคราว 2 ปี)',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'รถจักรยานยนต์ส่วนบุคคล(5 ปี)',
                    child: Text(
                      'รถจักรยานยนต์ส่วนบุคคล(ถาวร 5 ปี)',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'รถจักรยานยนต์สาธารณะ(3 ปี)',
                    child: Text(
                      'รถจักรยานยนต์สาธารณะ(3 ปี)',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _licenseType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเลือกประเภทใบอนุญาตขับขี่';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'หมายเลขใบขับขี่',
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9), // จำกัดความยาวไม่เกิน 9 หลัก
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกหมายเลขใบขับขี่';
                  } else if (value.length < 8 || value.length > 9) {
                    return 'หมายเลขใบขับขี่ต้องมี 8 หรือ 9 หลัก';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseIssueDateController,
                decoration: const InputDecoration(
                  labelText: 'วันอนุญาต',
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
                readOnly: true,
                onTap: () {
                  _selectDate(context, _licenseIssueDateController);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseExpiryDateController,
                decoration: const InputDecoration(
                  labelText: 'วันสิ้นอายุ',
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
                readOnly: true,
                onTap: () {
                  _selectDate(context, _licenseExpiryDateController);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseStatusController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'สถานะใบขับขี่',
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
                style: TextStyle(color: _licenseStatusColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.attach_file),
                label: const Text('แนบไฟล์ใบขับขี่'),
              ),
              if (_licenseImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  child: Text('ไฟล์ที่แนบ: ${_licenseImage!.name}'),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: _validateBeforeSave,
                child: const Text(
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
