import 'package:flutter/material.dart';
import 'package:motorbike/page/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      if (arguments != null) {
        emailController.text = arguments['email'] ?? '';
        passwordController.text = arguments['password'] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(225, 245, 254, 1.0), // สีฟ้าอ่อน
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1.0), // สีฟ้าน้ำเงินเข้ม
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontSize: 20, 
                    color: Colors.grey, // สีเริ่มต้นของ label
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

              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontSize: 20, 
                    color: Colors.grey, // สีเริ่มต้นของ label
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

              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(33, 150, 243, 1.0), // สีฟ้าสำหรับปุ่ม
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    try {
                      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      // ไปที่หน้า HomePage หลังจากเข้าสู่ระบบสำเร็จ
                      Navigator.pushReplacementNamed(context, '/personal');
                    } catch (e) {
                      _showErrorDialog("Failed to sign in: ${e.toString()}");
                    }
                  }
                },
                child: const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20, 
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot_password');
                },
                child: const Center(
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 16, color: Colors.red),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }
}
