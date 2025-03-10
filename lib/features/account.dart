import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:motorbike/features/booking_details.dart';
import 'package:motorbike/page/home.dart';
import 'package:motorbike/service/motorbike_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> _getUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.data();
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
    return null;
  }

  Future<List<Map<String, dynamic>>> _getCurrentBookings() async {
    final user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .where('isBooked', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'pickupDate': data['pickupDate'] ?? Timestamp.now(),
          'returnDate': data['returnDate'] ?? Timestamp.now(),
          'motorbike': {
            'name': data['motorbike']?['name'] ?? 'ไม่ทราบชื่อรถ',
            'totalprice': data['motorbike']?['totalprice'] ?? 0.0,
          },
        };
      }).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _getBookingHistory() async {
    final user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookingHistory')
          .where('userId', isEqualTo: user.uid)
          .orderBy('returnDate', descending: true) // เรียงจากล่าสุด
          .limit(5) // จำกัดแค่ 5 รายการ
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'pickupDate': data['pickupDate'] ?? Timestamp.now(),
          'returnDate': data['returnDate'] ?? Timestamp.now(),
          'motorbike': {
            'name': data['motorbike']?['name'] ?? 'ไม่ทราบชื่อรถ',
            'totalprice': data['motorbike']?['totalprice'] ?? 0.0,
          },
        };
      }).toList();
    }
    return [];
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บัญชีของฉัน'),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1.0),
        centerTitle: true,
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 100.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getUserInfo(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!userSnapshot.hasData) {
              return const Text('ไม่พบข้อมูลผู้ใช้');
            }

            final userInfo = userSnapshot.data!;
            final displayName = userInfo['firstname'] ?? 'ไม่ระบุ';
            final email = _auth.currentUser?.email ?? 'ไม่ระบุ';
            final phone = userInfo['phone'] ?? 'ไม่ระบุ';

            return ListView(
              children: [
                _buildSectionTitle('ข้อมูลส่วนตัว'),
                _buildUserInfoRow(Icons.person, 'ชื่อผู้ใช้', displayName),
                _buildUserInfoRow(Icons.email, 'อีเมล', email),
                _buildUserInfoRow(Icons.phone, 'เบอร์โทรศัพท์', phone),
                const SizedBox(height: 20),

                _buildSectionTitle('ข้อมูลการจอง'),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getCurrentBookings(),
                  builder: (context, bookingSnapshot) {
                    if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bookings = bookingSnapshot.data ?? [];
                    if (bookings.isEmpty) {
                      return const Center(child: Text('ไม่มีข้อมูลการจอง'));
                    }

                    return Column(
                      children: bookings.map((booking) {
                        final motorbike = booking['motorbike'] ?? {};
                        return ListTile(
                          leading: const Icon(Icons.motorcycle, color: Colors.blue),
                          title: Text(motorbike['name'] ?? 'ไม่ทราบชื่อรถ'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('วันที่รับ: ${booking['pickupDate'] != null ? _formatTimestamp(booking['pickupDate']) : 'ไม่ระบุ'}'),
                              Text('วันที่คืน: ${booking['returnDate'] != null ? _formatTimestamp(booking['returnDate']) : 'ไม่ระบุ'}'),
                              //Text('ราคาต่อวัน: ฿${motorbike['totalprice'] ?? 0.0}'),
                            ],
                          ),
                          trailing: const Text(
                            'จองแล้ว',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailsPage(
                                  bookingId: booking['id'],
                                  pickupDateTime: booking['pickupDate'] != null
                                      ? (booking['pickupDate'] as Timestamp).toDate()
                                      : DateTime.now(), // กำหนดค่าเริ่มต้น
                                  returnDateTime: booking['returnDate'] != null
                                      ? (booking['returnDate'] as Timestamp).toDate()
                                      : DateTime.now(), // กำหนดค่าเริ่มต้น
                                  pricePerDay: motorbike['totalprice'] ?? 0.0, // กำหนดค่าเริ่มต้น
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('ประวัติการจอง'),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getBookingHistory(),
                  builder: (context, historySnapshot) {
                    if (historySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final history = historySnapshot.data ?? [];
                    if (history.isEmpty) {
                      return const Center(child: Text('ไม่มีประวัติการจอง'));
                    }

                    return Column(
                      children: history.map((historyItem) {
                        final motorbike = historyItem['motorbike'] ?? {};
                        return ListTile(
                          leading: const Icon(Icons.history, color: Colors.blue),
                          title: Text(motorbike['name'] ?? 'ไม่ทราบชื่อรถ'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('วันที่รับ: ${historyItem['pickupDate'] != null ? _formatTimestamp(historyItem['pickupDate']) : 'ไม่ระบุ'}'),
                              Text('วันที่คืน: ${historyItem['returnDate'] != null ? _formatTimestamp(historyItem['returnDate']) : 'ไม่ระบุ'}'),
                              // Text('ราคาต่อวัน: ฿${motorbike['totalprice'] ?? 0.0}'),
                            ],
                          ),
                          trailing: const Text(
                            'คืนแล้ว',
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('การตั้งค่าบัญชี'),
                ListTile(
                  leading: const Icon(Icons.lock, color: Color.fromRGBO(13, 71, 161, 1.0)),
                  title: const Text('เปลี่ยนรหัสผ่าน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('ออกจากระบบ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color.fromRGBO(13, 71, 161, 1.0), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
