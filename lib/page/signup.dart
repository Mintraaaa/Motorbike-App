import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorbike/page/login.dart';

class SignUpPage extends StatefulWidget {
  final String? email;  // รับข้อมูลอีเมลจาก ForgotPasswordPage
  final String? password;  // รับข้อมูลรหัสผ่านจาก ForgotPasswordPage

  const SignUpPage({super.key, this.email, this.password});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ตั้งค่าอีเมลและรหัสผ่านถ้ามีการส่งมาจาก ForgotPasswordPage
    if (widget.email != null) {
      emailController.text = widget.email!;
    }
    if (widget.password != null) {
      passwordController.text = widget.password!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(225, 245, 254, 1.0), // พื้นหลังฟ้าอ่อนเหมือน Login
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 24, 
            color: Colors.white,
            fontFamily: 'Noto Sans Thai',
            fontWeight: FontWeight.w500, 
          ),
        ),
        backgroundColor: const Color.fromRGBO(13, 71, 161, 1.0), // สี AppBar เหมือนกับหน้าจอ Login
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // สีปุ่ม Sign Up
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    try {
                      // ลงทะเบียนผู้ใช้ใหม่
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      // ไปที่หน้า LoginPage หลังจากสมัครสำเร็จ
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      _showErrorDialog("Failed to sign up: ${e.toString()}");
                    }
                  }
                },
                child: const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20, 
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Up Failed'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
