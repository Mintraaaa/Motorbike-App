import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:motorbike/features/vehicle_summary.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late GoogleMapController _mapController;
  final ValueNotifier<LatLng> _selectedPosition =
      ValueNotifier(LatLng(18.7967, 98.9817)); // พิกัดเริ่มต้นที่เชียงใหม่
  final ValueNotifier<Set<Marker>> _markers = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _pickupDateController.dispose();
    _returnDateController.dispose();
    _selectedPosition.dispose();
    _markers.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted
    } else if (status.isDenied) {
      // Permission denied
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng position) async {
    final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(64, 64)),
      'assets/custom_marker.png',
    );

    _selectedPosition.value = position;
    _markers.value = {
      Marker(
        markerId: const MarkerId('selectedPosition'),
        position: position,
        icon: customIcon,
      ),
    };
  }

  Future<void> _saveLocation() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        DateTime? pickupDate = DateTime.tryParse(_pickupDateController.text);
        DateTime? returnDate = DateTime.tryParse(_returnDateController.text);

        if (pickupDate == null || returnDate == null || pickupDate.isAfter(returnDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('โปรดระบุวันใหม่')),
          );
          return;
        }

        if (_selectedPosition.value == LatLng(18.7967, 98.9817)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('โปรดเลือกตำแหน่งรับ-คืนรถบนแผนที่')),
          );
          return;
        }

        final location = {
          'pickup_date': _pickupDateController.text,
          'return_date': _returnDateController.text,
          'userid': FirebaseAuth.instance.currentUser?.uid,
          'latitude': _selectedPosition.value.latitude,
          'longitude': _selectedPosition.value.longitude,
        };

        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final locationDocRef = FirebaseFirestore.instance
              .collection('Locations')
              .doc();

          await locationDocRef.set({
            ...location,
            'location_id': locationDocRef.id,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ข้อมูลสถานที่และวันที่ถูกบันทึกเรียบร้อยแล้ว')),
          );

          _pickupDateController.clear();
          _returnDateController.clear();
          _markers.value = {};

          // นำทางไปยังหน้า VehicleSummaryPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VehicleSummaryPage()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'สถานที่รับ-คืนรถ',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(6, 61, 140, 1.0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: ValueListenableBuilder<Set<Marker>>(
                valueListenable: _markers,
                builder: (context, markers, _) {
                  return GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(18.7967, 98.9817),
                      zoom: 12,
                    ),
                    onTap: _onTap,
                    markers: markers,
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _pickupDateController,
                    decoration: InputDecoration(
                      labelText: 'วันที่รับรถ (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context, _pickupDateController),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _returnDateController,
                    decoration: InputDecoration(
                      labelText: 'วันที่คืนรถ (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context, _returnDateController),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _saveLocation,
                    child: Text(
                      'บันทึกข้อมูล',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
