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
  // ข้อมูลจำลองสำหรับการแสดงผล Card
  final List<Map<String, String>> data = [
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

  @override
  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * 0.2,
              decoration: const BoxDecoration(
                color: Color(0xFF2C262A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18), // โค้งที่มุมล่างซ้าย
                  bottomRight: Radius.circular(18), // โค้งที่มุมล่างขวา
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 25, 0, 0),
                  child: SizedBox(
                    width: screenWidth * 0.35,
                    height: screenHeight * 0.052,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7723),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFbfbdbc),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'รายการจัดส่ง',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
              child: SizedBox(
                width: screenWidth,
                height: screenHeight * 0.6,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
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
                                    color: status == "ไรเดอร์รับงาน"
                                        ? const Color(
                                            0xFFF3A72B) // Orange - Active work
                                        : status == "รอไรเดอร์มารับสินค้า"
                                            ? const Color(
                                                0xFFFFC107) // Amber - Waiting
                                            : status ==
                                                    "ไรเดอร์รับสินค้าแล้วและกำลังเดินทาง"
                                                ? const Color(
                                                    0xFF2196F3) // Blue - In transit
                                                : status ==
                                                        "ไรเดอร์นำส่งสินค้าแล้ว"
                                                    ? const Color(
                                                        0xFF4CAF50) // Green - Delivery complete
                                                    : status == "ยกเลิก"
                                                        ? const Color(
                                                            0xFFFF5722) // Red - Cancelled
                                                        : const Color(
                                                            0xFF000000), // Default color
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
}
