import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hermes_app/pages_user/status.dart';

class ItemsReceivedpage extends StatefulWidget {
  const ItemsReceivedpage({super.key});

  @override
  State<ItemsReceivedpage> createState() => _ListpageState();
}

class _ListpageState extends State<ItemsReceivedpage> {
  String status = 'ไรเดอร์นำส่งสินค้าแล้ว';
  bool isReceived =
      true; // Track the active button (true for received, false for delivery)

  // Sample data for cards
  final List<Map<String, String>> receivedData = [
    {
      "สินค้า": "หนังสือ 'การเดินทางแห่งความฝัน'",
      "ผู้ส่ง": "คุณสมชาย",
      "ผู้รับ": "คุณสมศรี",
      "เวลา": "15 ก.ย 2024 14.16"
    },
    {
      "สินค้า": "เสื้อยืด 'แบรนด์ X'",
      "ผู้ส่ง": "คุณสมจิตร",
      "ผู้รับ": "คุณสมนึก",
      "เวลา": "16 ก.ย 2024 10.30"
    },
    {
      "สินค้า": "อุปกรณ์ออกกำลังกาย",
      "ผู้ส่ง": "คุณสมปอง",
      "ผู้รับ": "คุณสมหญิง",
      "เวลา": "17 ก.ย 2024 09.45"
    },
  ];

  final List<Map<String, String>> deliveryData = [
    {
      "สินค้า": "นาฬิกา 'แบรนด์ Y'",
      "ผู้ส่ง": "คุณสมชาย",
      "ผู้รับ": "คุณสมบัติ",
      "เวลา": "18 ก.ย 2024 12.00"
    },
    {
      "สินค้า": "ลำโพงบลูทูธ",
      "ผู้ส่ง": "คุณสมชาย",
      "ผู้รับ": "คุณสมศักดิ์",
      "เวลา": "19 ก.ย 2024 13.15"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top container with back button and title
            Container(
              width: screenWidth,
              height: screenHeight * 0.2,
              decoration: const BoxDecoration(
                color: Color(0xFF2C262A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 10),
                    child: Center(
                      child: Text(
                        "รายการ",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Buttons for switching views
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 25, 0, 0),
                  child: SizedBox(
                    width: screenWidth * 0.35,
                    height: screenHeight * 0.052,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isReceived = true; // Show received items
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isReceived
                            ? const Color(0xFFFF7723)
                            : const Color(0xFFbfbdbc),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'สิ่งของที่ได้รับ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 25, 40, 0),
                  child: SizedBox(
                    width: screenWidth * 0.35,
                    height: screenHeight * 0.052,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isReceived = false; // Show delivery items
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isReceived
                            ? const Color(0xFFFF7723)
                            : const Color(0xFFbfbdbc),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'รายการจัดส่ง',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Display items based on button selection
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
              child: SizedBox(
                width: screenWidth,
                height: screenHeight * 0.6,
                child: ListView.builder(
                  itemCount:
                      isReceived ? receivedData.length : deliveryData.length,
                  itemBuilder: (context, index) {
                    final item =
                        isReceived ? receivedData[index] : deliveryData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const Statuspage());
                        },
                        child: Card(
                          color: const Color(0xFFE8E8E8),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: getStatusColor(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'สินค้า : ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        item["สินค้า"] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'ผู้ส่ง : ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        item["ผู้ส่ง"] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 50),
                                      const Text(
                                        'ผู้รับ : ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        item["ผู้รับ"] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text(
                                    item["เวลา"] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFBFBDBC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get status color based on the status value
  Color getStatusColor() {
    switch (status) {
      case "ไรเดอร์รับงาน":
        return const Color(0xFFF3A72B); // Orange
      case "รอไรเดอร์มารับสินค้า":
        return const Color(0xFFFFC107); // Amber
      case "ไรเดอร์รับสินค้าแล้วและกำลังเดินทาง":
        return const Color(0xFF2196F3); // Blue
      case "ไรเดอร์นำส่งสินค้าแล้ว":
        return const Color(0xFF4CAF50); // Green
      case "ยกเลิก":
        return const Color(0xFFFF5722); // Red
      default:
        return const Color(0xFF000000); // Default
    }
  }
}
