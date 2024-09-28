import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hermes_app/pages_rider/register_rider.dart';
import 'package:hermes_app/pages_user/register_user.dart';

class UserTypepage extends StatefulWidget {
  const UserTypepage({super.key});

  @override
  State<UserTypepage> createState() => _UserTypepageState();
}

class _UserTypepageState extends State<UserTypepage> {
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
                      "เลือกประเภทผู้ใช้ของคุณ",
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
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0),
              child: SizedBox(
                width: screenWidth,
                height: screenHeight * 0.84, // ปรับเป็น 50% ของความสูงหน้าจอ
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.80,
                  color: const Color(0xFFE8E8E8),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.75,
                          height: screenHeight * 0.30,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const RegisterUserpage());
                            },
                            child: Card(
                              color: const Color(0xFFBFBDBC),
                              child: Padding(
                                padding: EdgeInsets.all(screenHeight * 0.03),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/Type_user.png',
                                      width: screenWidth,
                                      height: screenHeight * 0.16,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Text(
                                        "ผู้ใช้ทั่วไป",
                                        style: TextStyle(
                                          fontSize: 23,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.060),
                        SizedBox(
                            width: screenWidth * 0.75,
                            height: screenHeight * 0.30,
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => const RegisterRiderpage());
                              },
                              child: Card(
                                color: const Color(0xFFBFBDBC),
                                child: Padding(
                                  padding: EdgeInsets.all(screenHeight * 0.03),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          'assets/images/Type_rider.png',
                                          width: screenWidth,
                                          height: screenHeight * 0.16),
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 8, 0, 0),
                                        child: Text(
                                          "ไรเดอร์",
                                          style: TextStyle(
                                            fontSize: 23,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))
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
}
