import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LocationData? _currentLocation;
  Location _location = Location();
  FirebaseFirestore _firestore = FirebaseFirestore.instance; // สร้าง instance ของ Firestore

  final LatLng _initialPosition = const LatLng(13.736717, 100.523186); // ตำแหน่งเริ่มต้นที่กรุงเทพฯ
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    
    // ติดตามตำแหน่งผู้ใช้
    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        _updateUserMarker(); // อัปเดตตำแหน่งผู้ใช้ปัจจุบัน
        _saveCurrentLocationToFirestore(); // บันทึกตำแหน่งผู้ใช้ลง Firestore
      });
    });

    // ฟังก์ชันเพื่อดึงข้อมูลตำแหน่งรถเช่าจาก Firestore แบบเรียลไทม์
    _listenToRentalBikeLocations();
  }

  // ฟังก์ชันขอสิทธิ์ตำแหน่งที่ตั้ง
  Future<void> _requestLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _location.getLocation();
  }

  // ฟังก์ชันบันทึกตำแหน่งรถเช่าลง Firestore พร้อม User ID
  Future<void> _saveRentalBikeToFirestore(double latitude, double longitude, String status, String userId) async {
    await _firestore.collection('rentalBikes').add({
      'latitude': latitude,
      'longitude': longitude,
      'status': status, // สถานะการจอง เช่น available หรือ booked
      'userId': userId, // ระบุ User ID ของผู้ใช้ที่จอง
    });
  }

  // ฟังก์ชันบันทึกตำแหน่งผู้ใช้ลง Firestore
  Future<void> _saveCurrentLocationToFirestore() async {
    if (_currentLocation != null) {
      await _firestore.collection('locations').add({
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // ฟังก์ชันเพิ่ม Marker สำหรับตำแหน่งผู้ใช้
  void _updateUserMarker() {
    if (_currentLocation != null) {
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

  // ฟังก์ชันฟังข้อมูลตำแหน่งรถเช่าจาก Firestore แบบเรียลไทม์
  void _listenToRentalBikeLocations() {
    _firestore.collection('rentalBikes').snapshots().listen((snapshot) {
      setState(() {
        _markers.clear(); // ล้าง Marker ก่อนเพิ่มใหม่
        for (var doc in snapshot.docs) {
          var data = doc.data();
          var position = LatLng(data['latitude'], data['longitude']);
          String status = data['status'];

          // ตรวจสอบสถานะการจองรถ
          String statusLabel;
          if (status == 'available') {
            statusLabel = 'ว่าง';
          } else if (status == 'booked') {
            statusLabel = 'ถูกจอง';
          } else if (status == 'paid') {
            statusLabel = 'ชำระเงินแล้ว';
          } else {
            statusLabel = 'ไม่ทราบสถานะ';
          }

          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: position,
              infoWindow: InfoWindow(
                title: 'รถเช่า ${doc.id}',
                snippet: 'สถานะ: $statusLabel', // แสดงสถานะ
              ),
            ),
          );
        }
      });
    });
  }


  // ตัวอย่างการบันทึกตำแหน่งรถเช่า
  void _saveSampleBikeData() async {
  String userId = FirebaseAuth.instance.currentUser!.uid; // รับ User ID ของผู้ใช้ปัจจุบัน

  await _saveRentalBikeToFirestore(13.746717, 100.523186, 'available', userId); // รถเช่าที่ 1
  await _saveRentalBikeToFirestore(13.726717, 100.533186, 'booked', userId);    // รถเช่าที่ 2
  await _saveRentalBikeToFirestore(13.736717, 100.543186, 'available', userId); // รถเช่าที่ 3
}

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _saveSampleBikeData(); // บันทึกตำแหน่งรถเช่าตัวอย่างเมื่อสร้างแผนที่เสร็จ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator()) // แสดง loading ขณะดึงข้อมูลตำแหน่ง
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 11.0,
              ),
              markers: _markers, // แสดง Markers
              myLocationEnabled: true, // แสดงตำแหน่งปัจจุบัน
              myLocationButtonEnabled: true, // ปุ่มแสดงตำแหน่งปัจจุบัน
            ),
    );
  }
}
