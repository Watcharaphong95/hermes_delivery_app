import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/request/user_where_id.dart';
import 'package:hermes_app/pages_user/edit_profile_user.dart';
import 'package:hermes_app/pages_user/login.dart';
import 'package:http/http.dart' as http;

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  String url = "";
  final box = GetStorage();
  List<SelectUserWhereId> user = [];

  @override
  void initState() {
    super.initState();
    getTUser();
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: user.isEmpty // Check if user list is empty
            ? const Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : Column(
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
                            "โปรไฟล์",
                            style: TextStyle(
                              fontSize: 35,
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
                          height: screenHeight * 0.78,
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
                                Container(
                                  width: screenWidth * 0.8,
                                  height: screenHeight * 0.07,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                  child: Text(
                                    user[0].name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                                  child: Text("เบอร์โทรศัพท์"),
                                ),
                                Container(
                                  width: screenWidth * 0.8,
                                  height: screenHeight * 0.07,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                  child: Text(
                                    user[0].phone,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                                  child: Text("ที่อยู่"),
                                ),
                                Container(
                                  width: screenWidth * 0.8,
                                  height: screenHeight * 0.15,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  child: Text(
                                    user[0].address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 30),
                                    child: Text(
                                      'Latitude: ${user[0].lat} Longitude: ${user[0].lng}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.052,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.to(() =>
                                                const EditProfileUserpage());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFF7723),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
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
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.to(() => const LoginPage());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFbfbdbc),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
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
                                    !user[0].picture.contains(
                                        "ll") // ตรวจสอบว่าไม่เป็น "ll"
                                ? (user[0].picture.startsWith('http')
                                    ? Image.network(
                                        user[0]
                                            .picture, // ใช้ Image.network ถ้าเป็น URL ที่ถูกต้อง
                                        width: 160,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        user[0]
                                            .picture, // ใช้ Image.asset ถ้าข้อมูลเป็น Asset
                                        width: 160,
                                      ))
                                : Image.asset(
                                    'assets/images/Profileuser.png', // รูปภาพดีฟอลต์
                                    width: 160,
                                  ))
                            : Image.asset(
                                'assets/images/Profileuser.png', // รูปภาพดีฟอลต์
                                width: 160,
                              ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.09,
                  )
                ],
              ),
      ),
    );
  }

  Future<void> getTUser() async {
    String? phone = box.read('phone');
    String? uid = box.read('uid');
    var config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    var res = await http.get(Uri.parse('$url/user/$uid'));
    log(res.body);
    user = selectUserWhereIdFromJson(res.body);
    log(user.length.toString());
    setState(() {}); // Call setState to refresh UI after data is
  }
}
