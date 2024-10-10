import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:hermes_app/pages_user/status.dart';
import 'package:intl/date_symbol_data_local.dart';

class ItemsList extends StatefulWidget {
  const ItemsList({super.key});

  @override
  State<ItemsList> createState() => _ListpageState();
}

class _ListpageState extends State<ItemsList> {
  final box = GetStorage();

  var db = FirebaseFirestore.instance;
  late StreamSubscription listener;

  List<OrderRes> ordersReceive = [];
  List<OrderRes> ordersSend = [];
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
  void initState() {
    super.initState();
    readDataReceive();
    readDataSend();
    startRealtimeGet();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      onPopInvoked: (didpop) async {
        listener.cancel();
      },
      child: Scaffold(
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
                            isReceived = true;
                            readDataReceive(); // Show received items
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
                            isReceived = false;
                            readDataSend(); // Show delivery items
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
                        isReceived ? ordersReceive.length : ordersSend.length,
                    itemBuilder: (context, index) {
                      final item =
                          isReceived ? ordersReceive[index] : ordersSend[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => Statuspage(
                                  docId: item.documentId,
                                ));
                          },
                          child: Card(
                            color: const Color(0xFFE8E8E8),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getStatus(item.status),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: getStatusColor(item.status),
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
                                          item.item ?? '',
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
                                          item.senderName ?? '',
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
                                          item.receiverName ?? '',
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
                                      item.createAt.toString() ?? '',
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
      ),
    );
  }

  // Get status color based on the status value
  String getStatus(String status) {
    switch (status) {
      case "1":
        return "รอไรเดอร์รับงาน"; // Waiting for the rider to pick up
      case "2":
        return "ไรเดอร์รับงาน และกำลังเดินทางไปเอาสินค้า"; // Rider has accepted the job
      case "3":
        return "ไรเดอร์รับสินค้าแล้วและกำลังเดินทาง"; // Rider has picked up the item and is on the way
      case "4":
        return "ไรเดอร์นำส่งสินค้าแล้ว"; // Rider has delivered the item
      case "5":
        return "ยกเลิก"; // Canceled
      default:
        return "สถานะไม่ระบุ"; // Status unknown
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "1":
        return const Color(0xFFFFC107); // Amber for "Waiting for the rider"
      case "2":
        return const Color(0xFFF3A72B); // Orange
      case "3":
        return const Color(0xFF2196F3); // Blue
      case "4":
        return const Color(0xFF4CAF50); // Green
      case "5":
        return const Color(0xFFFF5722); // Red
      default:
        return const Color(0xFF000000); // Default
    }
  }

  void readDataReceive() async {
    await initializeDateFormatting('th', null);
    var result = await db
        .collection('order')
        .where('receiverUid', isEqualTo: box.read('uid'))
        .get();
    // log(result.docs.length.toString());

    ordersReceive = result.docs.map((doc) {
      return OrderRes.fromFirestore(doc.data(), doc.id);
    }).toList();

    // Sort by time latest first
    ordersReceive.sort((a, b) => b.createAt.compareTo(a.createAt));

    // for (OrderRes order in ordersReceive) {
    //   log('Item: ${order.item}');
    //   log('Sender UID: ${order.senderId}');
    //   log('Receiver UID: ${order.receiverUid}');
    //   log('Detail: ${order.detail}');
    //   log('Picture URL: ${order.picture}');
    //   log('Status: ${order.status}');
    //   log('Rider: ${order.riderUid}');
    //   log('Formatted Date: ${order.formattedDate}');
    //   log('Document ID: ${order.documentId}');
    // }
    setState(() {});
  }

  void readDataSend() async {
    await initializeDateFormatting('th', null);
    var result = await db
        .collection('order')
        .where('senderId', isEqualTo: box.read('uid'))
        .get();
    // log(result.docs.length.toString());

    ordersSend = result.docs.map((doc) {
      return OrderRes.fromFirestore(doc.data(), doc.id);
    }).toList();

    // Sort by time latest first
    ordersSend.sort((a, b) => b.createAt.compareTo(a.createAt));

    // for (OrderRes order in ordersSend) {
    //   log('Item: ${order.item}');
    //   log('Sender UID: ${order.senderId}');
    //   log('Receiver UID: ${order.receiverUid}');
    //   log('Detail: ${order.detail}');
    //   log('Picture URL: ${order.picture}');
    //   log('Status: ${order.status}');
    //   log('Rider: ${order.riderUid}');
    //   log('Formatted Date: ${order.formattedDate}');
    //   log('Document ID: ${order.documentId}');
    // }
    setState(() {});
  }

  void startRealtimeGet() {
    final docRef = db.collection("order");
    docRef.snapshots().listen((event) {
      setState(() {
        readDataReceive();
        readDataSend();
      });
    }, onError: (error) => log("Listen failed"));
  }
}
