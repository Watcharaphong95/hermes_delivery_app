import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hermes_app/pages_user/edit_profile_user.dart';
import 'package:hermes_app/pages_user/login.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
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
                            child: const Text(
                              'ธเนศ   ภูมิเขต',
                              style: TextStyle(
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
                            child: const Text(
                              '099999999',
                              style: TextStyle(
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
                            child: const Text(
                              ' 123 หมู่ 4 ซอยสุขสันต์ ถนนเพลินสุขตำบลบางหว้า อำเภอภาษีเจริญ จังหวัดกรุงเทพฯ 10160',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                              child: Text(
                                'Latitude: 103.124.25 Longitude: 85.3.14',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                              SizedBox(
                                // width: screenWidth * 0.25,
                                height: screenHeight * 0.052,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0), // ระยะห่างจาก TextField
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => const LoginPage());
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
                  child: Image.asset(
                    'assets/images/Profileuser.png',
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
}
