import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hermes_app/pages_user/edit_profile_user.dart';

class HomeRiderpage extends StatefulWidget {
  const HomeRiderpage({super.key});

  @override
  State<HomeRiderpage> createState() => _HomeRiderpageState();
}

class _HomeRiderpageState extends State<HomeRiderpage> {
  @override
  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight * 0.16,
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
                  padding: const EdgeInsets.fromLTRB(8, 45, 0, 0),
                  child: Image.asset(
                    'assets/images/Logo_home.png',
                    width: screenWidth * 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            child: SizedBox(
              width: screenWidth,
              height: screenHeight * 0.15,
              child: Card(
                color: const Color(0xFFE8E8E8),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 34, 0, 15),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("สินค้า: "),
                              Text("หนังสือ การเดินทางแห่งความฝัน"),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text("ผู้ส่ง: "),
                                  Text("คุณสมชาย "),
                                ],
                              ),
                              SizedBox(width: 20),
                              Row(
                                children: [
                                  Text("ผู้รับ: "), // Updated here
                                  Text("คุณสมหมาย "),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        // width: screenWidth * 0.25,
                        height: screenHeight * 0.052,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0), // ระยะห่างจาก TextField
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => const EditProfileUserpage());
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
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
