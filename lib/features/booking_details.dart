import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorbike/features/vehicle_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorbike/model/booking.dart';
import 'package:motorbike/service/motorbike_service.dart';

class BookingDetailsPage extends StatefulWidget {
  final String bookingId;
  final DateTime? pickupDateTime;
  final DateTime? returnDateTime;
  final double pricePerDay;
  final bool isReturned;

  const BookingDetailsPage({
    Key? key,
    required this.bookingId,
    this.pickupDateTime, 
    this.returnDateTime,
    required this.pricePerDay,  
    this.isReturned = false,
  }) : super(key: key);

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  Map<String, dynamic>? bookingData;
  bool isPaid = false;
  bool isPenaltyPaid = false; // สถานะค่าปรับที่ชำระแล้ว
  double pricePerDay = 0.0;
  bool isOverdue = false; // ติดตามว่าการจองเลยกำหนดหรือไม่
  double penaltyAmount = 0.0; // กำหนดค่าปรับ
  bool isReturned = false; // สถานะคืนรถ
  final MotorbikeService motorbikeService = MotorbikeService();

  @override
  void initState() {
    super.initState();
    _loadBookingData(); // โหลดข้อมูลการจองจาก Firestore
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfOverdue(); // ตรวจสอบว่าการจองเลยกำหนดหรือไม่
  }

  Future<void> returnVehicle(String bookingId) async {
    final bookingDoc = FirebaseFirestore.instance.collection('bookings').doc(bookingId);
    final bookingHistoryDoc = FirebaseFirestore.instance.collection('bookingHistory').doc(bookingId);

    // ตรวจสอบว่ามีอยู่ใน bookingHistory แล้วหรือยัง
    final bookingHistorySnapshot = await bookingHistoryDoc.get();
    if (bookingHistorySnapshot.exists) {
      print("รายการนี้มีอยู่ใน bookingHistory แล้ว");
      return; // หยุดการทำงานเพื่อป้องกันข้อมูลซ้ำ
    }

    // ย้ายข้อมูลไปยัง bookingHistory
    final bookingSnapshot = await bookingDoc.get();
    if (bookingSnapshot.exists) {
      final bookingData = bookingSnapshot.data();
      await bookingHistoryDoc.set({
        ...bookingData!,
        'status': 'คืนรถแล้ว',
        'isReturned': true,
        'returnedAt': FieldValue.serverTimestamp(),
      });

      // ลบข้อมูลออกจาก bookings
      await bookingDoc.delete();
      print('ข้อมูลการจองถูกย้ายไปที่ bookingHistory และลบจาก bookings เรียบร้อยแล้ว');
    } else {
      print('ไม่พบข้อมูลการจองใน bookings');
    }
  }

  Future<void> _loadBookingData() async {
    try {
      // ดึงข้อมูลจาก bookings
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (bookingSnapshot.exists) {
        print('Booking data loaded: ${bookingSnapshot.data()}');
        setState(() {
          bookingData = bookingSnapshot.data() as Map<String, dynamic>?;
          isPaid = bookingData?['isPaid'] ?? false;
          isPenaltyPaid = bookingData?['isPenaltyPaid'] ?? false;
        });

        // ตรวจสอบ motorbikeId
        final String motorbikeId = bookingData?['motorbike']['id'] ?? '';
        print('motorbikeId: $motorbikeId');

        if (motorbikeId.isNotEmpty) {
          // ดึงข้อมูลจาก motorbikes
          DocumentSnapshot motorbikeSnapshot = await FirebaseFirestore.instance
              .collection('motorbikes')
              .doc(motorbikeId)
              .get();

          if (motorbikeSnapshot.exists) {
            final motorbikeData = motorbikeSnapshot.data() as Map<String, dynamic>?;
            print('Motorbike data: $motorbikeData');
            setState(() {
              pricePerDay = (motorbikeData?['pricePerDay'] ?? 0.0).toDouble();
              print("ราคาต่อวัน (จาก motorbikes): $pricePerDay");
            });
          } else {
            print('ไม่พบข้อมูลใน motorbikes สำหรับ motorbikeId: $motorbikeId');
          }
        } else {
          print('motorbikeId ว่างเปล่าในข้อมูลการจอง');
        }

        _checkIfOverdue();
      } else {
        print('ไม่พบข้อมูลการจองสำหรับ bookingId: ${widget.bookingId}');
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการโหลดข้อมูลการจอง: $e");
    }
  }


  Widget _buildBookingStatus() {
    String status;
    Color statusColor;

    if (isReturned) {
      status = 'คืนรถแล้ว';
      statusColor = Colors.blue;
    } else if (isPenaltyPaid) {
      status = 'ชำระค่าปรับแล้ว';
      statusColor = Colors.green;
    } else if (isOverdue) {
      status = 'เลยระยะการจอง';
      statusColor = Colors.red;
    } else {
      status = isPaid ? 'ชำระเงินแล้ว' : 'รอการชำระเงิน';
      statusColor = isPaid ? Colors.green : Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'สถานะการจอง',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  void _payPenalty(BuildContext context) async {
    if (isOverdue && !isPenaltyPaid) {
      setState(() {
        final remainingDeposit = (bookingData?['deposit'] ?? 0.0) - penaltyAmount;
        bookingData?['deposit'] = remainingDeposit > 0 ? remainingDeposit : 0.0;
        isPenaltyPaid = true;
      });

      await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update({
        'isBooked': false,
        'penaltyPaid': true,
        'status': 'ยกเลิกการจอง',
        'deposit': bookingData?['deposit'] ?? 0.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ชำระค่าปรับเรียบร้อยแล้ว! ค่าปรับที่ชำระ: ${penaltyAmount.toStringAsFixed(2)} บาท'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {});
    }
  }

  void _checkIfOverdue() {
    if (widget.returnDateTime != null && widget.returnDateTime!.isBefore(DateTime.now())) {
      setState(() {
        isOverdue = true;

        // คำนวณค่าปรับ
        final int hoursOverdue = DateTime.now().difference(widget.returnDateTime!).inHours;
        final double depositAmount = (bookingData?['deposit'] ?? 0.0).toDouble();

        penaltyAmount = (hoursOverdue * 50.0).clamp(0.0, depositAmount);

        // Debugging logs
        print('isOverdue: $isOverdue');
        print('เวลาที่เกินกำหนด: $hoursOverdue ชั่วโมง');
        print('ค่าปรับ: $penaltyAmount');
      });
    } else {
      // หากไม่เกินกำหนด
      setState(() {
        isOverdue = false;
        penaltyAmount = 0.0;
      });
    }
  }
 
  void _returnMotorbike(BuildContext context) async {
    if (bookingData != null) {
      final motorbikeId = bookingData!['motorbike']['id'];
      final bookingId = bookingData!['id'];

      DocumentSnapshot bookingHistorySnapshot = await FirebaseFirestore.instance
          .collection('bookingHistory')
          .doc(bookingId)
          .get();

      if (!bookingHistorySnapshot.exists) {
        await FirebaseFirestore.instance.collection('bookingHistory').doc(bookingId).set(bookingData!);
        await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();
        await motorbikeService.releaseMotorbike(motorbikeId);

        setState(() {
          isReturned = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('คืนรถเรียบร้อยแล้ว!'),
            backgroundColor: Colors.blue,
          ),
        );

        Navigator.pop(context);
      } else {
        print("รายการนี้มีอยู่ในประวัติการจองแล้ว ไม่บันทึกซ้ำ");
      }
    }
  }

  void _showReturnConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการคืนรถ'),
          content: const Text('คุณต้องการคืนรถหรือไม่?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () {
                Navigator.of(context).pop();
                _returnMotorbike(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (bookingData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('รายละเอียดการจอง'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final motorbikeName = bookingData?['motorbike']?['name'] ?? 'ไม่มีข้อมูล';
    final motorbikeColor = bookingData?['motorbike']?['color'] ?? 'ไม่มีข้อมูล';
    final pickupDate = bookingData?['pickupDate'] != null
        ? DateFormat('dd/MM/yyyy HH:mm').format((bookingData!['pickupDate'] as Timestamp).toDate())
        : 'ไม่มีข้อมูล';
    final returnDate = bookingData?['returnDate'] != null
        ? DateFormat('dd/MM/yyyy HH:mm').format((bookingData!['returnDate'] as Timestamp).toDate())
        : 'ไม่มีข้อมูล';
    final totalPrice = (bookingData?['totalPrice'] ?? 0.0).toDouble();
    final penalty = (bookingData?['penalty'] ?? 0.0).toDouble();
    final location = bookingData?['location'] ?? 'ไม่มีข้อมูล';
    final distance = bookingData?['distance'] != null ? '${bookingData!['distance']} กม.' : 'ไม่มีข้อมูล';
    final days = bookingData?['days'] ?? 1;
    final deposit = (bookingData?['deposit'] ?? 0.0).toDouble();
    final pricePerDay = (bookingData?['motorbike']?['pricePerDay'] ?? widget.pricePerDay).toDouble();    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายละเอียดการจอง',
          style: TextStyle(
            color: Colors.white, // กำหนดสีฟอนต์เป็นสีขาว
            fontSize: 22.0, // กำหนดขนาดฟอนต์
            fontWeight: FontWeight.bold, // กำหนดความหนาของฟอนต์
          ),
        ),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1.0), // สีพื้นหลังของ AppBar
        centerTitle: true,
        automaticallyImplyLeading: false, // ปิดการแสดงลูกศรย้อนกลับ
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('ข้อมูลรถ'),
              _buildDetailRow('ชื่อรถ', motorbikeName),
              _buildDetailRow('สี', motorbikeColor),
              const Divider(height: 40, thickness: 2),
              _buildSectionTitle('วันและเวลาที่รับ-คืนรถ'),
              _buildDetailRow('วันรับรถ', pickupDate),
              _buildDetailRow('วันคืนรถ', returnDate),
              _buildDetailRow('จำนวนวัน', '$days วัน'),
              const Divider(height: 40, thickness: 2),
              _buildSectionTitle('สถานที่'),
              _buildDetailRow('สถานที่', location),
              _buildDetailRow('ระยะทาง', distance),
              const Divider(height: 40, thickness: 2),
              _buildSectionTitle('ข้อมูลการชำระเงิน'),
              _buildDetailRow('ราคาต่อวัน', '${pricePerDay.toStringAsFixed(2)} บาท'),
              _buildDetailRow('ค่ามัดจำ', '${deposit.toStringAsFixed(2)} บาท'),
              _buildDetailRow('ราคารวม', '${totalPrice.toStringAsFixed(2)} บาท'), // หาก totalPrice เป็น null จะใช้ค่า 0.0
              _buildDetailRow('ค่าปรับ', '${penalty.toStringAsFixed(2)} บาท'),
              const Divider(height: 40, thickness: 2),
              _buildSectionTitle('สถานะการจอง'),
              _buildBookingStatus(),
              const SizedBox(height: 20),
              if (!widget.isReturned)
                Center(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        _showReturnConfirmationDialog(context);
                      },
                      child: const Text('คืนรถ'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (isOverdue && !isPenaltyPaid && !widget.isReturned)
                Center(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        _payPenalty(context);
                      },
                      child: Text('ชำระค่าปรับ ${penaltyAmount.toStringAsFixed(2)} บาท'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleSummaryPage(),
                        ),
                      );
                    },
                    child: const Text('ย้อนกลับ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
