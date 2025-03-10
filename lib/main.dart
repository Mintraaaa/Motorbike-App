import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:motorbike/features/booking.dart';
import 'package:motorbike/features/booking_details.dart';
import 'package:motorbike/features/location.dart';
import 'package:motorbike/features/motorbike_detail.dart';
import 'package:motorbike/model/motorbike.dart';
import 'package:motorbike/page/driver_license.dart';
import 'package:motorbike/page/emergency_contact.dart';
import 'package:motorbike/page/personal.dart';
import 'package:motorbike/page/home.dart';
import 'package:motorbike/page/login.dart';
import 'package:motorbike/page/signup.dart';
import 'package:motorbike/page/forgot_password.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:motorbike/features/vehicle_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 
import 'package:motorbike/providers/booking_provider.dart';
import 'package:motorbike/providers/motorbike_provider.dart';
import 'package:provider/provider.dart'; // provider
import 'package:motorbike/brand_notifier.dart'; 
import 'package:motorbike/motorbike_list.dart';
import 'package:motorbike/motorbike_features.dart';
import 'package:motorbike/bank_account_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:motorbike/model/booking.dart';
import 'package:motorbike/features/booking_info.dart'; 
import 'package:motorbike/page/map_screen.dart';

Future<void> updateExistingDocumentsToDouble() async {
  final String collectionName = "motorbikes";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    QuerySnapshot snapshot = await firestore.collection(collectionName).get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      Map<String, dynamic> updates = {};

      // ตรวจสอบและแปลงฟิลด์จาก int เป็น double
      if (data['totalPrice'] != null && data['totalPrice'] is num) {
        updates['totalPrice'] = (data['totalPrice'] as num).toDouble();
      }
      if (data['deposit'] != null && data['deposit'] is num) {
        updates['deposit'] = (data['deposit'] as num).toDouble();
      }
      if (data['pricePerDay'] != null && data['pricePerDay'] is num) {
        updates['pricePerDay'] = (data['pricePerDay'] as num).toDouble();
      }

      // หากมีฟิลด์ที่ต้องอัปเดต
      if (updates.isNotEmpty) {
        await firestore.collection(collectionName).doc(doc.id).update(updates);
        print("Updated document ${doc.id} with $updates");
      }
    }

    print("Finished updating all documents in $collectionName.");
  } catch (e) {
    print("Error updating documents: $e");
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await updateExistingDocumentsToDouble();
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MotorbikeProvider()),
        ChangeNotifierProvider(create: (context) => BrandNotifier()),
        ChangeNotifierProvider(create: (context) => BookingProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Motorbike',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('th', ''),
      ],
      initialRoute: '/vehicle_summary', // เส้นทางเริ่มต้น
      onGenerateRoute: (settings) {
        final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/booking':
            if (args != null) {
              final motorbike = args['motorbike'] as Motorbike?;
              final booking = args['booking'] as Booking?;
              final totalPrice = args['totalPrice'] as double?;
              final returnTime = args['returnTime'] as TimeOfDay?;

              if (motorbike != null && booking != null && totalPrice != null) {
                return MaterialPageRoute(
                  builder: (context) => BookingPage(
                    motorbikeId: motorbike.id,
                    motorbike: motorbike,
                    booking: booking,
                    totalPrice: totalPrice,
                    returnTime: returnTime, // ส่งเวลาคืนรถ (ถ้ามี)
                  ),
                );
              }
            }
            return _errorRoute();

          // ปรับการรับค่าใน /booking_details
          case '/booking_details':
            if (args != null) {
              final bookingId = args['bookingId'] as String?;
              final pickupDateTime = args['pickupDateTime'] as DateTime?;
              final returnDateTime = args['returnDateTime'] as DateTime?;
              final totalprice = args['totalprice'] as double?;

              if (bookingId != null) {
                return MaterialPageRoute(
                  builder: (context) => BookingDetailsPage(
                    bookingId: bookingId,
                    pickupDateTime: pickupDateTime, // ส่งค่า pickupDateTime (ถ้ามี)
                    returnDateTime: returnDateTime, // ส่งค่า returnDateTime (ถ้ามี)
                    pricePerDay: totalprice ?? 0.0, 
                  ),
                );
              }
            }
            return _errorRoute();

          default:
            return MaterialPageRoute(builder: (context) => const HomePage());
        }
      },

      routes: {
        '/': (context) => const HomePage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/personal': (context) => PersonalPage(),
        '/emergency_contact': (context) => const EmergencyContactPage(),
        '/driver_license': (context) => const DriverLicensePage(),
        '/location': (context) => LocationPage(),
        '/vehicle_summary': (context) => VehicleSummaryPage(),
        '/qr': (context) => MyQrWidget(promptPayData: '1234567890'),
        '/map_screen': (context) => MapScreen(),
      },

    );
  }

  // ฟังก์ชันคืนค่า Widget เมื่อเส้นทางไม่ถูกต้อง
  Widget _errorPage() {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('ไม่พบหน้า หรือข้อมูลไม่ถูกต้อง')),
    );
  }

  // ฟังก์ชันคืนค่า Route เมื่อเส้นทางไม่ถูกต้อง
  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('ไม่พบหน้า หรือข้อมูลไม่ถูกต้อง')),
      ),
    );
  }
}
