import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hermes_app/pages_user/navbuttom.dart';
import 'package:hermes_app/pages_user/user_type.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom; // ความสูงของแป้นพิมพ์

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 600,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C262A),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(50, 120, 50, 50),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Logo.png',
                            width: 210,
                            height: 150,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'HERMES',
                            style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF7723),
                            ),
                          ),
                          const Text(
                            'DELIVERY APP',
                            style: TextStyle(
                              fontSize: 25,
                              color: Color(0xFFFF7723),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 250),
              ],
            ),
            Positioned(
              top: 450 - keyboardHeight, // ปรับตำแหน่งตามความสูงของแป้นพิมพ์
              left: 25,
              right: 25,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50, // ลดความกว้าง
                height: 400,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(35, 50, 35, 35),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E1E1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.phone),
                                hintText: 'เบอร์โทรศัพท์',
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(97, 0, 0, 0)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E1E1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock),
                                hintText: 'รหัส',
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(97, 0, 0, 0)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: false,
                                      onChanged: (bool? value) {}),
                                  const Text('จดจำฉัน',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8), // เพิ่มระยะห่างถ้าต้องการ
                            const Text(
                              'ลืมรหัสผ่าน?',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.016),
                        SizedBox(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.06,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0), // ระยะห่างจาก TextField
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => Navbuttompage(
                                      selectedPage: 0,
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7723),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'มีบัญชีหรือยัง?',
                              style: TextStyle(fontSize: 12),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.to(() => const UserTypepage());
                              },
                              child: const Text(
                                'สร้างบัญชี!',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
