import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/request/rider_where_id.dart';
import 'package:hermes_app/pages_rider/edit_profile_rider.dart';
import 'package:hermes_app/pages_rider/home_rider.dart';
import 'package:http/http.dart' as http;

class ProfileRider extends StatefulWidget {
  const ProfileRider({super.key});

  @override
  State<ProfileRider> createState() => _ProfileRiderState();
}

class _ProfileRiderState extends State<ProfileRider> {
  String url = " ";
  List<SelectRiderRid> user = [];
  final box = GetStorage();

  @override
  void initState() {
    // TODO: implement initState
    getTUser();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: null,
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
                      "แก้ไขโปรไฟล์",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.57,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 115, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                            child: Text("ชื่อ-นามสกุล"),
                          ),
                          SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.06,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: user.isNotEmpty ? user[0].name : '',
                                  hintStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 0, 0, 0)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 35),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                            child: Text("เบอร์โทรศัพท์"),
                          ),
                          SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.06,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText:
                                      user.isNotEmpty ? user[0].phone : '',
                                  hintStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 0, 0, 0)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 35),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                            child: Text("ป้ายทะเบียน"),
                          ),
                          SizedBox(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.06,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText:
                                      user.isNotEmpty ? user[0].plate : '',
                                  hintStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 0, 0, 0)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 35),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: screenHeight * 0.052,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => const EditProfileRider());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF7723),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'แก้ไข',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.052,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // dialog();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFbfbdbc),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'ออกจากระบบ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFFF3131),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -screenHeight * 0.001,
                  left: (screenWidth * 0.85 - 160) / 2,
                  child: user.isNotEmpty
                      ? (user[0].picture.isNotEmpty &&
                              !user[0]
                                  .picture
                                  .contains("ll") // ตรวจสอบว่าไม่เป็น "ll"
                          ? (user[0].picture.startsWith('http')
                              ? ClipOval(
                                  child: Image.network(
                                    user[0]
                                        .picture, // ใช้ Image.network ถ้าเป็น URL ที่ถูกต้อง
                                    width: 160,
                                    height:
                                        160, // กำหนดความสูงให้เท่ากับความกว้าง
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipOval(
                                  child: Image.asset(
                                    user[0]
                                        .picture, // ใช้ Image.asset ถ้าข้อมูลเป็น Asset
                                    width: 160,
                                    height:
                                        160, // กำหนดความสูงให้เท่ากับความกว้าง
                                    fit: BoxFit.cover,
                                  ),
                                ))
                          : ClipOval(
                              child: Image.asset(
                                'assets/images/Profileuser.png', // รูปภาพดีฟอลต์
                                width: 160,
                                height: 160, // กำหนดความสูงให้เท่ากับความกว้าง
                                fit: BoxFit.cover,
                              ),
                            ))
                      : ClipOval(
                          child: Image.asset(
                            'assets/images/Profileuser.png', // รูปภาพดีฟอลต์
                            width: 160,
                            height: 160, // กำหนดความสูงให้เท่ากับความกว้าง
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getTUser() async {
    log(box.read('uid'));
    String? phone = box.read('phone');
    String? uid = box.read('uid');
    var config = await Configuration.getConfig();
    url = config['apiEndPoint'];

    var res = await http.get(Uri.parse('$url/rider/$uid'));
    log(res.body);
    user = selectRiderRidFromJson(res.body);

    // log(singleUser[0].toString());

    // user = singleUser;
    log(user[0].phone.toString());
    setState(() {});
  }
}
