import 'package:flutter/material.dart';
import 'package:motorbike/model/motorbike.dart';
import 'package:motorbike/features/motorbike_detail.dart';

class PricePage extends StatefulWidget {
  final List<Motorbike> motorbikes; // รับลิสต์ motorbikes

  const PricePage({Key? key, required this.motorbikes}) : super(key: key);

  @override
  _PricePageState createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  bool _isAscending = true; // Flag for sorting order
  String? _selectedPriceRange;
  List<Motorbike> _filteredMotorbikes = [];

  @override
  void initState() {
    super.initState();
    _filteredMotorbikes = widget.motorbikes; // Initialize filtered motorbikes
  }

  void _filterMotorbikes(String? selectedRange) {
    if (selectedRange == null || selectedRange == 'ทั้งหมด') {
      setState(() {
        _filteredMotorbikes = widget.motorbikes; // Reset to all motorbikes
      });
      return;
    }

    double minPrice = 0;
    double maxPrice = double.infinity;

    // Set price range based on the selected value
    switch (selectedRange) {
      case '100-200':
        minPrice = 100;
        maxPrice = 200;
        break;
      case '200-300':
        minPrice = 200;
        maxPrice = 300;
        break;
      case '300-400':
        minPrice = 300;
        maxPrice = 400;
        break;
      case '400-500':
        minPrice = 400;
        maxPrice = 500;
        break;
      case '500+':
        minPrice = 500;
        maxPrice = double.infinity;
        break;
    }

    setState(() {
      _filteredMotorbikes = widget.motorbikes
          .where((motorbike) =>
              motorbike.totalPrice >= minPrice && motorbike.totalPrice < maxPrice)
          .toList();
    });
  }

  List<Motorbike> get sortedMotorbikes {
    final List<Motorbike> sortedList = List.from(_filteredMotorbikes);
    sortedList.sort((a, b) => _isAscending
        ? a.totalPrice.compareTo(b.totalPrice)
        : b.totalPrice.compareTo(a.totalPrice));
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                hint: const Text('Select Price Range'),
                value: _selectedPriceRange,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPriceRange = newValue;
                    _filterMotorbikes(newValue);
                  });
                },
                items: <String>[
                  'ทั้งหมด',
                  '100-200',
                  '200-300',
                  '300-400',
                  '400-500',
                  '500+'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('ราคา $value บาท'),
                  );
                }).toList(),
              ),
              IconButton(
                icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () {
                  setState(() {
                    _isAscending = !_isAscending;
                  });
                },
              ),
            ],
          ),
        ),
          Expanded(
            child: ListView.builder(
              itemCount: sortedMotorbikes.length,
              itemBuilder: (context, index) {
                final motorbike = sortedMotorbikes[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4.0, // เพิ่มเงาให้กับ Card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // ปรับขอบมนของ Card
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), // เพิ่มขอบมนให้รูปภาพ
                      child: Image.asset(
                        motorbike.images.isNotEmpty
                            ? motorbike.images[0]
                            : 'assets/images/placeholder.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      motorbike.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // ปรับขนาดตัวอักษรให้ใหญ่ขึ้น
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4.0),
                        Text(
                          'แบรนด์: ${motorbike.brand}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // ปรับขนาดตัวอักษร
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'ราคา: ${motorbike.totalPrice} บาท/วัน',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                            fontSize: 16, // ปรับขนาดตัวอักษร
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MotorbikeDetailPage(motorbike: motorbike),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
