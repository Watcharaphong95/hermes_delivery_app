import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/select_user_all.dart';
import 'package:hermes_app/models/user_login.dart';
import 'package:hermes_app/navbar/navbottom.dart';
import 'package:hermes_app/navbar/navbottomRider.dart';
import 'package:hermes_app/navbar/navbuttom.dart';
import 'package:hermes_app/pages_rider/home_rider.dart';
import 'package:hermes_app/pages_user/user_type.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final box = GetStorage();

  TextEditingController phoneCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  String url = '';

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
                            child: TextField(
                              controller: phoneCtl,
                              decoration: const InputDecoration(
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
                            child: TextField(
                              controller: passwordCtl,
                              decoration: const InputDecoration(
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
                                login();
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

  void login() async {
    if (phoneCtl.text.isNotEmpty && passwordCtl.text.isNotEmpty) {
      UserLogin userlogin = UserLogin(
        phone: phoneCtl.text,
        password: passwordCtl.text,
      );

      var config = await Configuration.getConfig();
      url = config['apiEndpoint'];

      try {
        // ส่งคำขอเข้าสู่ระบบไปยัง API
        final response = await http.post(
          Uri.parse('$url/user/login'),
          body: json.encode(userlogin.toJson()),
          headers: {"Content-Type": "application/json; charset=utf-8"},
        );

        if (response.statusCode == 200) {
          var user = selectUserAllFromJson(response.body);
          log('Login success: ${user.phone}');

          box.write('phone', user.phone);
          box.write('uid', user.uid);
          log(box.read('phone'));
          if (user.type == 1) {
            Get.to(() => Navbuttompage(
                  selectedPage: 0,
                  phoneNumber: user.phone,
                ));
          } else if (user.type == 2) {
            Get.to(() => Navbottom(
                  selectedPages: 0,
                  phoneNumber: user.phone,
                ));
          }
        } else {
          log('Login failed: ${response.statusCode}');
          // แสดงข้อความแจ้งเตือนเมื่อเข้าสู่ระบบล้มเหลว
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid phone or password')),
          );
        }
      } catch (error) {
        log('Error during login: $error');
        // แสดงข้อความแจ้งเตือนเมื่อเกิดข้อผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } else {
      // แสดงข้อความแจ้งเตือนหากกรอกข้อมูลไม่ครบ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone and password')),
      );
    }
  }
}
