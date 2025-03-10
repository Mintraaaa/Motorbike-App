import 'package:flutter/material.dart';

class BrandNotifier extends ChangeNotifier {
  String _selectedBrand = '';

  String get selectedBrand => _selectedBrand;

  void selectBrand(String brand) {
    _selectedBrand = brand;
    notifyListeners(); // แจ้งเตือนผู้ฟังเมื่อมีการเปลี่ยนแปลง
  }

  void clearSelection() {
    _selectedBrand = '';
    notifyListeners(); // แจ้งเตือนผู้ฟังเมื่อมีการเปลี่ยนแปลง
  }
}
