import 'package:flutter/material.dart';
import 'package:motorbike/features/booking_details.dart';
import 'package:motorbike/features/payment.dart';
import 'package:motorbike/model/booking.dart';
import 'package:motorbike/model/motorbike.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class BookingPage extends StatefulWidget {
  final Motorbike motorbike;
  final double totalPrice;
  final TimeOfDay? returnTime;
  final Booking booking;
  final String motorbikeId;

  const BookingPage({
    Key? key,
    required this.motorbike,
    required this.totalPrice,
    required this.returnTime,
    required this.booking,
    required this.motorbikeId,
  }) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _returnDate;
  TimeOfDay? _returnTime;
  String? _selectedLocation;
  double? _distance;

  bool isSaving = false;

  final double depositFee = 1500.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid uuid = Uuid();

  final Map<String, double> _locations = {
    'ประตูท่าแพ': 0.0,
    'สนามบินเชียงใหม่': 4.0,
    'สถานีรถไฟเชียงใหม่': 3.0,
    'สถานีขนส่งอาเขต': 5.0,
    'ถนนนิมมานเหมินทร์': 3.5,
    'เซ็นทรัลเฟสติวัล เชียงใหม่': 6.0,
    'สวนบวกหาด': 2.0,
    'ย่านเจ็ดยอด': 6.0,
    'ศูนย์การค้าเมญ่า': 4.0,
    'ศูนย์ประชุมนานาชาติ': 7.0,
    'ถนนราชพฤกษ์': 12.0,
    'วัดพระธาตุดอยสุเทพ': 15.0,
    'เชียงใหม่ไนท์บาซาร์': 1.5,
    'วัดพระสิงห์': 1.0,
    'ห้วยตึงเฒ่า': 15.0,
    'ดอยอินทนนท์': 100.0,
    'ดอยอ่างขาง': 160.0,
  };

  @override
  void initState() {
    super.initState();
    _checkBookingStatus();
  }

  Future<void> _selectDateTime(BuildContext context, {required bool isPickup}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isPickup ? (_pickupDate ?? DateTime.now()) : (_returnDate ?? _pickupDate ?? DateTime.now()),
      firstDate: isPickup ? DateTime.now() : (_pickupDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: isPickup ? (_pickupTime ?? TimeOfDay.now()) : (_returnTime ?? TimeOfDay.now()),
      );
      if (pickedTime != null) {
        setState(() {
          if (isPickup) {
            _pickupDate = pickedDate;
            _pickupTime = pickedTime;
          } else {
            _returnDate = pickedDate;
            _returnTime = pickedTime;
          }
        });
        print("Selected ${isPickup ? "Pickup" : "Return"} Date: $pickedDate, Time: $pickedTime");
      }
    }
  }

  DateTime? combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  double _calculateDistance() {
    if (_selectedLocation != null && _locations.containsKey(_selectedLocation!)) {
      double distance = _locations[_selectedLocation!]!;
      print("Selected Location: $_selectedLocation, Distance: $distance");
      return distance;
    }
    return 0.0;
  }

  int _calculateNumberOfDays() {
    int days = _returnDate != null && _pickupDate != null ? _returnDate!.difference(_pickupDate!).inDays : 0;
    print("Number of Days: $days");
    return days;
  }

  double _calculateTotalPrice() {
    int numberOfDays = _calculateNumberOfDays();
    double dailyRate = widget.motorbike.totalPrice ?? 0.0;
    double distance = _distance ?? 0.0;
    double extraCharge = distance > 10.0 ? (distance - 10) * 5.0 : 0.0;
    double total = (numberOfDays * dailyRate) + depositFee + extraCharge;
    print("Calculated Total Price: $total");
    return total;
  }

  void _navigateToPaymentPage(Booking booking, String bookingId) {
    Navigator.pop(context, true); // ส่งกลับไปที่ AccountPage เพื่อแจ้งว่าการจองสำเร็จ
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          booking: booking,
          totalPrice: booking.totalPrice,
          motorbikeName: booking.motorbike.name,
          motorbikeColor: booking.motorbike.color,
          motorbikePricePerDay: booking.motorbike.totalPrice,
          bookingId: bookingId,
          motorbikeId: widget.motorbikeId,
          pricePerDay: widget.motorbike.totalPrice,
        ),
      ),
    );
  }

  Future<void> _saveBookingToFirestore(Booking booking) async {
    setState(() {
      isSaving = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถดึงข้อมูลผู้ใช้ได้ กรุณาล็อกอินใหม่')),
        );
        return;
      }

      String motorbikeId = booking.motorbike.id;
      print("Motorbike ID: $motorbikeId");

      DocumentSnapshot motorbikeSnapshot = await _firestore.collection('motorbikes').doc(motorbikeId).get();
      bool isBooked = (motorbikeSnapshot.data() as Map<String, dynamic>?)?['isBooked'] ?? false;

      print("Is Motorbike Booked: $isBooked");

      if (isBooked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รถคันนี้ถูกจองแล้ว ไม่สามารถทำการจองได้อีก')),
        );
        setState(() {
          isSaving = false;
        });
        return;
      }

      Map<String, dynamic> bookingData = {
        'userId': userId,
        'motorbike': {
          'id': motorbikeId,
          'name': booking.motorbike.name,
          'color': booking.motorbike.color,
          'totalPrice': booking.motorbike.totalPrice,
          'brand': booking.motorbike.brand,
          'description': booking.motorbike.description,
        },
        'days': booking.days,
        'deposit': booking.deposit,
        'distance': booking.distance,
        'location': booking.location,
        'pickupDate': booking.pickupDate,
        'returnDate': booking.returnDate,
        'totalPrice': booking.totalPrice,
        'isPaid': false,
        'isBooked': true,
      };

      DocumentReference bookingRef = _firestore.collection('bookings').doc();
      await bookingRef.set(bookingData);

      await _firestore.collection('motorbikes').doc(motorbikeId).update({
        'isBooked': true,
      });

      print("Booking saved successfully with ID: ${bookingRef.id}");
      _navigateToPaymentPage(booking, bookingRef.id);
    } catch (e) {
      print("Error saving booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูลการจอง: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  void _showBookingConfirmationDialog() {
    final pickupDateTime = combineDateAndTime(_pickupDate, _pickupTime);
    final returnDateTime = combineDateAndTime(_returnDate, _returnTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการจอง'),
          content: Text('คุณต้องการยืนยันการจองหรือไม่? \nยอดรวม: ${_calculateTotalPrice().toStringAsFixed(2)} บาท'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () async {
                Navigator.of(context).pop();
                if (_pickupDate != null && _returnDate != null && _selectedLocation != null) {
                  String bookingId = uuid.v4();

                  Booking newBooking = Booking(
                    bookingId: bookingId,
                    id: widget.motorbike.id,
                    pickupDate: pickupDateTime!,
                    returnDate: returnDateTime!,
                    location: _selectedLocation!,
                    days: _calculateNumberOfDays(),
                    deposit: depositFee,
                    distance: _calculateDistance(),
                    motorbike: widget.motorbike,
                    totalPrice: _calculateTotalPrice(),
                    isBooked: true,
                  );

                  _saveBookingToFirestore(newBooking);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _checkBookingStatus() async {
    final motorbikeDoc = await _firestore.collection('motorbikes').doc(widget.motorbikeId).get();
    
    // Safely cast the data to Map<String, dynamic> if it exists
    final motorbikeData = motorbikeDoc.data() as Map<String, dynamic>?;

    bool isBooked = motorbikeData?['isBooked'] ?? false; // Use false if isBooked is missing

    if (isBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รถคันนี้ถูกจองแล้ว ไม่สามารถทำการจองได้อีก')),
      );

      setState(() {
        isSaving = true;
      });
    }
  }

  Widget _buildConfirmButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: isSaving
            ? ElevatedButton(
                onPressed: null,
                child: const Text('รถถูกจองแล้ว'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 100.0),
                  textStyle: const TextStyle(fontSize: 20.0),
                ),
              )
            : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showBookingConfirmationDialog();
                  }
                },
                child: const Text('ยืนยันการจอง'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(33, 150, 243, 1.0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 100.0),
                  textStyle: const TextStyle(fontSize: 20.0),
                ),
              ),
      ),
    );
  }

    Widget _buildPickupDateTimePicker() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('วันและเวลารับรถ:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateTime(context, isPickup: true),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 24.0),
                      const SizedBox(width: 8.0),
                      Text(
                        _pickupDate == null ? 'เลือกวันรับรถ' : '${_pickupDate!.toLocal()}'.split(' ')[0],
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateTime(context, isPickup: true),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 24.0),
                      const SizedBox(width: 8.0),
                      Text(
                        _pickupTime == null ? 'เลือกเวลารับรถ' : '${_pickupTime!.format(context)}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    Widget _buildReturnDateTimePicker() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('วันและเวลาคืนรถ:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateTime(context, isPickup: false),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 24.0),
                      const SizedBox(width: 8.0),
                      Text(
                        _returnDate == null ? 'เลือกวันคืนรถ' : '${_returnDate!.toLocal()}'.split(' ')[0],
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateTime(context, isPickup: false),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 24.0),
                      const SizedBox(width: 8.0),
                      Text(
                        _returnTime == null ? 'เลือกเวลาคืนรถ' : '${_returnTime!.format(context)}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    Widget _buildLocationDropdown() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('สถานที่รับรถ:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            hint: const Text('เลือกสถานที่'),
            items: _locations.keys.map((String location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedLocation = newValue;
                _distance = _calculateDistance();
              });
            },
            validator: (value) => value == null ? 'กรุณาเลือกสถานที่' : null,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.grey, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.green, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      );
    }

    Widget _buildCostRow(IconData icon, String label, String value, Color iconColor) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16.0)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    Widget _buildCostSummary() {
      return Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'รายละเอียด',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              _buildCostRow(Icons.calendar_today, 'จำนวนวันใช้งาน:', '${_calculateNumberOfDays()} วัน', Colors.orange),
              const SizedBox(height: 6.0),
              _buildCostRow(Icons.location_on, 'ระยะทาง:', '${_calculateDistance()} กม.', Colors.blue),
              const SizedBox(height: 6.0),
              _buildCostRow(Icons.attach_money, 'ราคาต่อวัน:', '${widget.motorbike.totalPrice} บาท', Colors.green),
              const SizedBox(height: 6.0),
              _buildCostRow(Icons.account_balance_wallet, 'ค่ามัดจำ:', '$depositFee บาท', Colors.purple),
              const SizedBox(height: 10.0),
              _buildCostRow(Icons.calculate, 'ราคารวม:', '${_calculateTotalPrice().toStringAsFixed(2)} บาท', Colors.red),
              const SizedBox(height: 10.0),
              const Text(
                '*คืนล่าช้าจะคิดเวลาชั่วโมงละ 50 บาท',
                style: TextStyle(fontSize: 14.0, color: Colors.orange),
              ),
            ],
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ข้อมูลการจองรถ'),
          backgroundColor: const Color.fromRGBO(13, 71, 161, 1.0),
          centerTitle: true,
          toolbarHeight: 70.0,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.motorbike.name}',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      _buildPickupDateTimePicker(),
                      const SizedBox(height: 16.0),
                      _buildReturnDateTimePicker(),
                      const SizedBox(height: 16.0),
                      _buildLocationDropdown(),
                      const SizedBox(height: 24.0),
                      if (_pickupDate != null && _returnDate != null)
                        _buildCostSummary(),
                    ],
                  ),
                ),
                _buildConfirmButton(),
              ],
            ),
          ),
        ),
      );
    }
  }
