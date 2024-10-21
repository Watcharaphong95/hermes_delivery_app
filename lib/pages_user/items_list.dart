import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:hermes_app/pages_user/all_status.dart';
import 'package:hermes_app/pages_user/record.dart';
import 'package:hermes_app/pages_user/status.dart';
import 'package:intl/date_symbol_data_local.dart';

class ItemsList extends StatefulWidget {
  const ItemsList({super.key});

  @override
  State<ItemsList> createState() => _ListpageState();
}

class _ListpageState extends State<ItemsList> {
  double screenWidth = 0;
  double screenHeight = 0;
  final box = GetStorage();

  var db = FirebaseFirestore.instance;
  late StreamSubscription listener;

  List<OrderRes> ordersReceive = [];
  List<OrderRes> ordersSend = [];
  bool isReceived =
      true; // Track the active button (true for received, false for delivery)

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
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      onPopInvoked: (didpop) async {
        listener.cancel();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
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
                  child: Column(
                    children: [
                      if (isReceived && ordersReceive.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Text(
                                'ไม่มีของที่ต้องรับ',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Color(0xFFBFBDBC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (!isReceived && ordersSend.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'ไม่มีของที่ส่ง',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.black),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: isReceived
                                ? ordersReceive.length
                                : ordersSend.length,
                            itemBuilder: (context, index) {
                              // log('test');
                              if (isReceived && ordersReceive.isEmpty) {
                                log('test');
                                return const Center(
                                  child: Text('No received orders available.'),
                                );
                              } else if (!isReceived && ordersSend.isEmpty) {
                                return const Center(
                                  child: Text('No sent orders available.'),
                                );
                              }

                              final item = isReceived
                                  ? ordersReceive[index]
                                  : ordersSend[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    if (item.status != '4') {
                                      Get.to(() => Statuspage(
                                            docId: item.documentId,
                                          ));
                                    } else {
                                      Get.to(() => Record(
                                            docId: item.documentId,
                                          ));
                                    }
                                  },
                                  child: Card(
                                    color: const Color(0xFFE8E8E8),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 0, 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getStatus(item.status),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  getStatusColor(item.status),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
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
                                            padding:
                                                const EdgeInsets.only(top: 0),
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
                                            padding:
                                                const EdgeInsets.only(top: 15),
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

                      // Add button for the "Received" list
                      if (isReceived &&
                          ordersSend.isNotEmpty &&
                          ordersReceive.any((order) =>
                              order.status != 4.toString() &&
                              order.status != 5.toString()))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => AllStatus(
                                    isReceive: true,
                                  ));
                              log('recieve');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7723),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'แผนที่รายการรับทั้งหมด',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Add button for the "Send" list
                      if (!isReceived &&
                          ordersSend.isNotEmpty &&
                          ordersSend.any((order) =>
                              order.status != '4' && order.status != '5'))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => AllStatus(
                                    isReceive: false,
                                  ));
                              log('send');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7723),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'แผนที่รายการส่งทั้งหมด',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
        .where('receiverUid', isEqualTo: int.parse(box.read('uid')))
        .get();
    // log(result.docs.length.toString());

    ordersReceive = result.docs.map((doc) {
      return OrderRes.fromFirestore(doc.data(), doc.id);
    }).toList();

    // Sort by time latest first
    ordersReceive.sort((a, b) => b.createAt.compareTo(a.createAt));

    // for (OrderRes order in ordersReceive) {
    //   log('Item: ${order.item}');
    //   log('Sender UID: ${order.senderUid}');
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
        .where('senderUid', isEqualTo: box.read('uid'))
        .get();
    // log(result.docs.length.toString());

    ordersSend = result.docs.map((doc) {
      return OrderRes.fromFirestore(doc.data(), doc.id);
    }).toList();

    // Sort by time latest first
    ordersSend.sort((a, b) => b.createAt.compareTo(a.createAt));

    // for (OrderRes order in ordersSend) {
    //   log('Item: ${order.item}');
    //   log('Sender UID: ${order.senderUid}');
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
