import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrWidget extends StatelessWidget {
  final String promptPayData;

  MyQrWidget({required this.promptPayData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              if (promptPayData.isNotEmpty)
                QrImageView(
                  data: '1234567890', // QR code data
                  version:
                      QrVersions.auto, // Automatically determine the version
                  size: 200.0, // Size of the QR code
                  gapless: false, // To prevent gaps in the QR code
                )
              else
                Text(
                  'No data available', // ข้อความเมื่อไม่มีข้อมูล
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 20),
              if (promptPayData.isEmpty)
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('กรุณาใส่ข้อมูล QR Code')),
                    );
                  },
                  child: Text('Try Again'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyQrWidget(
      promptPayData:
          '1234567890', // ใส่ข้อมูลสำหรับ QR Code เช่น หมายเลข PromptPay
    ),
  ));
}
