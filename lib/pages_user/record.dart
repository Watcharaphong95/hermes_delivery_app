import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/request/rider_where_id.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:hermes_app/models/response/user_search_res.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Record extends StatefulWidget {
  String docId = "";
  Record({super.key, required this.docId});

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  var db = FirebaseFirestore.instance;
  String url = "";
  List<OrderRes> orders = [];
  List<PhoneSearchRes> senderData = [];
  List<PhoneSearchRes> receiverData = [];
  List<SelectRiderRid> riderData = [];

  int pictureNumber = 1;
  double screenWidth = 0;
  double screenHeight = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getApiKey();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
                        "รายละเอียดรายการ",
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.75,
                decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.05,
                      screenHeight * 0.01,
                      screenWidth * 0.05,
                      screenHeight * 0.03),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (orders.isNotEmpty &&
                              senderData.isNotEmpty &&
                              receiverData.isNotEmpty &&
                              riderData.isNotEmpty)
                          ? [
                              Text(
                                getStatus(orders[0].status),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: getStatusColor(orders[0].status),
                                ),
                              ),
                              Text(
                                'หมายเลขคำสั่งซื้อ (Order Number): ${orders[0].documentId}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                'ชื่อผู้ส่ง: ${senderData[0].name}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'ที่อยู่ผู้ส่ง: ${senderData[0].address}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'เบอร์ผู้ส่ง: ${senderData[0].phone}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                '\nชื่อผู้รับ: ${receiverData[0].name}', // Receiver's name
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'ที่อยู่ผู้รับ: ${receiverData[0].address}', // Receiver's address
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'เบอร์ผู้ส่ง: ${receiverData[0].phone}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                '\nวันที่จัดส่ง: ${DateFormat('yyyy-MM-dd, HH:mm').format(orders[0].createAt)}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'วันที่รับของ: ${DateFormat('yyyy-MM-dd, HH:mm').format(orders[0].endAt!)}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                '\nชื่อไรเดอร์: ${riderData[0].name}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'หมายเลขโทรศัพท์ไรเดอร์: ${riderData[0].phone}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'ป้ายทะเบียน: ${riderData[0].plate}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 25, 0, 0),
                                    child: SizedBox(
                                      width: screenWidth * 0.25,
                                      height: screenHeight * 0.052,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            pictureNumber = 1;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pictureNumber == 1
                                              ? const Color(0xFFFF7723)
                                              : const Color(0xFFbfbdbc),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          'รอไรเดอร์รับสินค้า',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 25, 0, 0),
                                    child: SizedBox(
                                      width: screenWidth * 0.25,
                                      height: screenHeight * 0.052,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            pictureNumber = 2;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pictureNumber == 2
                                              ? const Color(0xFFFF7723)
                                              : const Color(0xFFbfbdbc),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          'ไรเดอร์รับสินค้า',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 25, 0, 0),
                                    child: SizedBox(
                                      width: screenWidth * 0.25,
                                      height: screenHeight * 0.052,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            pictureNumber = 3;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pictureNumber == 3
                                              ? const Color(0xFFFF7723)
                                              : const Color(0xFFbfbdbc),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          'ส่งสินค้าเสร็จสิ้น',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    0, screenHeight * 0.01, 0, 0),
                                child: Container(
                                  width: screenWidth *
                                      0.8, // Set the width based on screenWidth
                                  height: screenHeight *
                                      0.3, // Set the height based on screenHeight
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        15), // Set your desired border radius
                                    color: Colors
                                        .white, // Set the background color or use Colors.transparent
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey
                                            .withOpacity(0.5), // Shadow color
                                        spreadRadius: 2, // Spread radius
                                        blurRadius: 5, // Blur radius
                                        offset: const Offset(0,
                                            3), // Changes the position of the shadow
                                      ),
                                    ],
                                  ),
                                  child: pictureNumber == 1
                                      ? imagePerStatus(1)
                                      : pictureNumber == 2
                                          ? imagePerStatus(2)
                                          : pictureNumber == 3
                                              ? imagePerStatus(3)
                                              : const Center(
                                                  child:
                                                      CircularProgressIndicator()), // Center the loading indicator
                                ),
                              )
                            ]
                          : [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.3),
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Image imagePerStatus(int status) {
    String imageUrl;

    if (status == 1) {
      imageUrl = orders[0].picture;
    } else if (status == 2) {
      imageUrl = orders[0].picture_2;
    } else if (status == 3) {
      imageUrl = orders[0].picture_3;
    } else {
      imageUrl = 'assets/default_image.png'; // Default image or placeholder
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child; // The image has loaded
        } else {
          return Center(
            // Show a loading indicator
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        // Show an error widget if the image fails to load
        return const Icon(Icons.error,
            color: Colors.red); // Change this to your error widget
      },
    );
  }

  Future<void> getApiKey() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    setState(() {});
  }

  void readData() async {
    await initializeDateFormatting('th', null);
    var result = await db.collection('order').doc(widget.docId).get();

    orders = [OrderRes.fromFirestore(result.data()!, result.id)];

    if (orders.isNotEmpty) {
      await getUserReceiver();
      await getUserSender();
      await getRider();
    }
    setState(() {});
  }

  Future<void> getUserSender() async {
    var res = await http.get(Uri.parse('$url/user/${orders[0].senderUid}'));
    senderData = phoneSearchResFromJson(res.body);
    log(senderData[0].name);
    setState(() {});
  }

  Future<void> getRider() async {
    var res = await http.get(Uri.parse('$url/rider/${orders[0].riderRid}'));
    riderData = selectRiderRidFromJson(res.body);
    log(riderData[0].name);
    setState(() {});
  }

  Future<void> getUserReceiver() async {
    var res = await http.get(Uri.parse('$url/user/${orders[0].receiverUid}'));
    receiverData = phoneSearchResFromJson(res.body);
    log(receiverData[0].name);
    setState(() {});
  }

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
}
