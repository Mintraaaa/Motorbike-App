import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(225, 245, 254, 1.0), // พื้นหลังฟ้าอ่อน
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 24, 
            color: Colors.white,
            fontFamily: 'Noto Sans Thai',
            fontWeight: FontWeight.w500, 
          ),
        ),
        backgroundColor: const Color.fromRGBO(13, 71, 161, 1.0), // สี AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 35.0, 16.0, 30.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
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
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 35),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
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
                  return 'Please enter your new password';
                }
                return null;
              },
            ),

            const SizedBox(height: 35),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
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
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // สีฟ้าของปุ่ม Reset Password
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                if (_emailController.text.isNotEmpty &&
                    _newPasswordController.text.isNotEmpty &&
                    _confirmPasswordController.text.isNotEmpty) {
                  _changePassword();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: Center(
                child: const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 20, 
                    color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (_newPasswordController.text == _confirmPasswordController.text) {
          await user.updatePassword(_newPasswordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successfully.')),
          );

          Navigator.pushReplacementNamed(context, '/login', arguments: {
            'email': _emailController.text,
            'password': _newPasswordController.text,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not signed in')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password: ${e.message}')),
      );
    }
  }
}
