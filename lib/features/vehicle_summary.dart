import 'package:flutter/material.dart';
import 'package:motorbike/features/account.dart';
import 'package:motorbike/features/motor_recommendations.dart';
import 'package:motorbike/features/motor_model.dart';
import 'package:motorbike/features/price.dart';
import 'package:motorbike/model/booking.dart';
import 'package:motorbike/model/motorbike.dart';
import 'package:motorbike/features/booking_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'; // Import Google Maps & Location

class VehicleSummaryPage extends StatefulWidget {
  final int initialIndex;

  VehicleSummaryPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _VehicleSummaryPageState createState() => _VehicleSummaryPageState();
}

class _VehicleSummaryPageState extends State<VehicleSummaryPage> {
  late int _selectedIndex;
  Booking? _currentBooking; // เก็บข้อมูลการจองล่าสุด
  String? _bookingId; // เก็บ bookingId
  GoogleMapController? mapController;
  LocationData? _currentLocation;
  Location _location = Location(); // สร้าง instance ของ Location
  final LatLng _initialPosition = const LatLng(13.736717, 100.523186); // ตำแหน่งเริ่มต้น
  final Set<Marker> _markers = {}; // Marker สำหรับแผนที่

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    print('Initial Tab Index: $_selectedIndex'); // ตรวจสอบว่าเริ่มต้นที่แท็บไหน

    _requestLocationPermission(); // ขอสิทธิ์ตำแหน่งที่ตั้ง
    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        _updateMarkers(); // เพิ่มตำแหน่งผู้ใช้ปัจจุบัน
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // ตรวจสอบว่าเปิดบริการ location หรือไม่
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // ตรวจสอบสิทธิ์การเข้าถึง location
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // ดึงตำแหน่งปัจจุบัน
    _currentLocation = await _location.getLocation();
  }

  void _updateMarkers() {
    if (_currentLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: InfoWindow(title: "ตำแหน่งปัจจุบันของคุณ"),
        ),
      );
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          14.0,
        ),
      );
    }
  }

  // ฟังก์ชันเปลี่ยนหน้าใน BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print('Tab Index Changed: $_selectedIndex'); // ตรวจสอบว่ามีการเปลี่ยนแท็บหรือไม่
  }

  // ฟังก์ชันสำหรับสร้างการจอง
  void _initiateBooking(Motorbike motorbike) {
    DateTime pickupDate = DateTime.now(); // วันรับรถ
    DateTime returnDate = pickupDate.add(Duration(days: 5)); // วันคืนรถ

    setState(() {
      _currentBooking = Booking(
        bookingId: '12345',
        id: 'bike001',
        pickupDate: pickupDate,
        returnDate: returnDate,
        motorbike: motorbike,
        days: 5, // สมมุติการใช้รถ 5 วัน
        deposit: 1500.0, // ค่ามัดจำ
        location: 'สนามบินเชียงใหม่', // สถานที่รับรถ
        distance: 20.0, // ระยะทาง
        totalPrice: motorbike.totalPrice * 5, // คิดราคารวมตามจำนวนวัน
        isBooked: false,
      );
      _bookingId = 'example_booking_id'; // สมมุติ bookingId
    });

    print('Booking Created: $_currentBooking'); // ตรวจสอบว่าการจองถูกสร้างหรือไม่
    print('Booking ID: $_bookingId');

    // นำทางไปที่หน้า BookingInfoPage พร้อมข้อมูลการจอง
    Navigator.pushNamed(
      context,
      '/booking_info',
      arguments: {
        'booking': _currentBooking,
        'bookingId': _bookingId,
      },
    ).then((_) {
      print('Navigated back to main page'); // ตรวจสอบการกลับมาหน้าหลัก
    });
  }
  Widget _buildMotorbikeCard(Motorbike motorbike) {
    bool isBooked = motorbike.isBooked ?? false;
    bool isPaid = motorbike.isPaid ?? false; // เพิ่มการตรวจสอบการชำระเงิน

    return Card(
      child: ListTile(
        leading: Image.asset(motorbike.images[0]), // แสดงภาพมอเตอร์ไซค์
        title: Text(motorbike.name),
        subtitle: Text("ราคา: ${motorbike.totalPrice} บาท/วัน"),
        trailing: isPaid
            ? const Text(
                'จองแล้ว',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
            : ElevatedButton(
                onPressed: () {
                  // ดำเนินการไปที่การจองถ้ารถยังไม่ถูกจองและยังไม่ได้ชำระเงิน
                  _initiateBooking(motorbike);
                },
                child: const Text('เลือก'),
              ),
      ),
    );
  }

  
  // สร้างลิสต์ motorbikes
  final List<Motorbike> motorbikes = [
    Motorbike(
      id: 'bike001',
      images: ['assets/images/filano_g2023.png'],
      name: 'Grand Filano Hybrid ABS',
      brand: 'YAMAHA',
      description: 'สกูตเตอร์ดีไซน์หรู พร้อมเทคโนโลยีไฮบริดและ ABS ประหยัดน้ำมัน ปลอดภัย',
      color: 'สีเทา (Elixir Silver)',
      totalPrice: 400.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'ABS'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike002',
      images: ['assets/images/filano_b2023.png'],
      name: 'Grand Filano Hybrid ABS',
      brand: 'YAMAHA',
      description: 'สกูตเตอร์ดีไซน์หรู พร้อมเทคโนโลยีไฮบริดและ ABS ประหยัดน้ำมัน ปลอดภัย',
      color: 'สีน้ำเงิน (Prestige Blue)',
      totalPrice: 400.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'ABS'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike003',
      images: ['assets/images/pcx_g.png'],
      name: 'PCX160',
      brand: 'HONDA',
      description: 'Honda PCX160 เป็นมอเตอร์ไซค์ออโตเมติก ดีไซน์ทันสมัย ประหยัดน้ำมัน มี ABS และระบบสมาร์ทคีย์',
      color: 'สีขาว-ดำ (White-Black)',
      totalPrice: 550.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'ABS'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '160 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike004',
      images: ['assets/images/pcx_r.png'],
      name: 'PCX160',
      brand: 'HONDA',
      description: 'Honda PCX160 เป็นมอเตอร์ไซค์ออโตเมติก ดีไซน์ทันสมัย ประหยัดน้ำมัน มี ABS และระบบสมาร์ทคีย์',
      color: 'สีแดง-ดำ (Red-Black)',
      totalPrice: 550.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'ABS'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '160 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),  
    Motorbike(
      id: 'bike005',
      images: ['assets/images/scoopy_bk.png'],
      name: 'Scoopy Urban',
      brand: 'HONDA',
      description: 'ระบบเบรกที่ปลอดภัยและพื้นที่เก็บของที่สะดวกสบาย มีการตกแต่งที่มีเอกลักษณ์และการออกแบบที่เน้นความเรียบหรู',
      color: 'สีดำ-ขาว (Black-White)',
      totalPrice: 300.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '110 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike006',
      images: ['assets/images/scoopy_bw.png'],
      name: 'Scoopy Urban',
      brand: 'HONDA',
      description: 'ระบบเบรกที่ปลอดภัยและพื้นที่เก็บของที่สะดวกสบาย มีการตกแต่งที่มีเอกลักษณ์และการออกแบบที่เน้นความเรียบหรู',
      color: 'สีน้ำตาล-ขาว (Brown-White)',
      totalPrice: 300.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '110 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike007',
      images: ['assets/images/click_rd.png'],
      name: 'Click 125',
      brand: 'HONDA',
      description: 'สกูตเตอร์ขนาดกลางที่ทันสมัย ขับขี่คล่องตัว ประหยัดน้ำมัน และมีฟีเจอร์เทคโนโลยีที่ทันสมัย',
      color: 'สีแดง-ดำ (Red-Black)',
      totalPrice: 300.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike008',
      images: ['assets/images/fino_b.png'],
      name: 'Fino 125',
      brand: 'YAMAHA',
      description: 'Fino Final Edition เป็นสกูตเตอร์สุดคลาสสิก ประหยัดน้ำมัน มีระบบเบรกที่ปลอดภัย',
      color: 'สีดำ (Original Black)',
      totalPrice: 280.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike009',
      images: ['assets/images/fino_r.png'],
      name: 'Fino 125',
      brand: 'YAMAHA',
      description: 'Fino Final Edition เป็นสกูตเตอร์สุดคลาสสิก ประหยัดน้ำมัน มีระบบเบรกที่ปลอดภัย',
      color: 'สีแดง (Red)',
      totalPrice: 280.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'Combi-Brake'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '125 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike010',
      images: ['assets/images/abs_rb.png'],
      name: 'Giorno+',
      brand: 'HONDA',
      description: 'สกูตเตอร์สไตล์คลาสสิกที่มาพร้อมฟีเจอร์ทันสมัย ขับขี่สบายและมีการออกแบบที่โดดเด่น',
      color: 'สีแดง-ดำ (Red-Black)',
      totalPrice: 400.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: ' Combi-Brake'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '110 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike011',
      images: ['assets/images/cbs_yb.png'],
      name: 'Giorno+',
      brand: 'HONDA',
      description: 'สกูตเตอร์สไตล์คลาสสิกที่มาพร้อมฟีเจอร์ทันสมัย ขับขี่สบายและมีการออกแบบที่โดดเด่น',
      color: 'สีเหลือง-ดำ (Yellow-Black)',
      totalPrice: 400.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: ' Combi-Brake'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '110 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
    Motorbike(
      id: 'bike012',
      images: ['assets/images/abs_gp.png'],
      name: 'AEROX',
      brand: 'YAMAHA',
      description: 'สกูตเตอร์สปอร์ตที่เน้นการออกแบบทันสมัยและการขับขี่ที่เร็วแรง มีระบบเทคโนโลยีขั้นสูงและความสะดวกสบายในการใช้งาน',
      color: 'สีเทา-ม่วง (Magic Purple)',
      totalPrice: 400.0,
      features: [
        MotorbikeFeature(icon: Icons.people, name: '2 ที่นั่ง'),
        MotorbikeFeature(icon: Icons.security, name: 'ABS'),
        MotorbikeFeature(icon: Icons.drive_eta, name: 'ออโต้'),
        MotorbikeFeature(icon: Icons.memory, name: '155 cc'),
        MotorbikeFeature(icon: Icons.local_gas_station, name: 'น้ำมันแก๊สโซฮอล์ 95'),
      ],
    ),
  ];

@override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.pink,
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่ตรงกลาง
      //     children: [
      //       Image.asset(
      //         'assets/images/logo1.png', // ตำแหน่งของโลโก้ในโฟลเดอร์ assets
      //         height: 120, // ปรับขนาดโลโก้
      //       ),
      //     ],
      //   ),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // หน้าการแนะนำมอเตอร์ไซค์
          DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100.0),
                child: AppBar(
                  backgroundColor: Color.fromRGBO(13, 71, 161, 1.0),
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(40.0),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        child: const TabBar(
                          indicator: BoxDecoration(), // ซ่อนเส้นใต้
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.amber,
                          labelStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Tab(text: 'แนะนำ'),
                            Tab(text: 'แบรนด์'),
                            Tab(text: 'ราคา'),
                          ],
                        )
                      ),
                    ),
                  ),
                ),
              ),

              body: TabBarView(
                children: [
                  MotorRecommendationsPage(
                    motorbikes: motorbikes,
                    onMotorbikeTap: (motorbike) {
                      // สร้างการจองเมื่อเลือกมอเตอร์ไซค์
                      _initiateBooking(motorbike);
                      setState(() {
                        _selectedIndex = 1; // ไปยังแท็บ "ข้อมูล"
                      });
                    },
                  ),
                  MotorModelPage(motorbikes: motorbikes),
                  PricePage(motorbikes: motorbikes),
                ],
              ),
            ),
          ),

          // แสดงหน้าแผนที่เมื่อเลือกแท็บ "แผนที่"
          Scaffold(
           appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0), // ปรับขนาดความสูงของ AppBar
            child: AppBar(
              backgroundColor: Color.fromRGBO(13, 71, 161, 1.0),
              automaticallyImplyLeading: false,
              flexibleSpace: Padding(
                padding: const EdgeInsets.only(top: 40.0), // เพิ่ม Padding เพื่อเลื่อนข้อความลงมา
                child: Center(
                  child: Text(
                    'แผนที่',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
            body: _currentLocation == null
                ? Center(child: CircularProgressIndicator()) // แสดง loading ขณะดึงข้อมูลตำแหน่ง
                : GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14.0,
                    ),
                    markers: _markers, // แสดง Markers
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
          ),

          // หน้าจอบัญชี
          AccountPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'แผนที',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'บัญชี',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
