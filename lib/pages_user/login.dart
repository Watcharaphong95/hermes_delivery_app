import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/select_user_all.dart';
import 'package:hermes_app/models/user_login.dart';
import 'package:hermes_app/navbar/navbottomRider.dart';
import 'package:hermes_app/navbar/navbuttomUser.dart';
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
  bool rememberMe = false; // ตัวแปรสำหรับจดจำผู้ใช้
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลหากผู้ใช้เลือก "จดจำฉัน"
    bool? rememberMeValue = box.read('rememberMe');
    if (rememberMeValue == true) {
      rememberMe = true;
      phoneCtl.text = box.read('savedPhone') ?? '';
      passwordCtl.text = box.read('savedPassword') ?? ''; // ควรจัดการให้ปลอดภัย
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom; // Keyboard height

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
              top: 450 - keyboardHeight,
              left: 25,
              right: 25,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50,
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
                        // Phone TextField
                        SizedBox(
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E1E1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              controller: phoneCtl,
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.phone),
                                hintText: 'เบอร์โทรศัพท์',
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(97, 0, 0, 0)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Password TextField
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
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: rememberMe,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          rememberMe =
                                              value ?? false; // อัปเดตค่าตัวแปร
                                        });
                                      }),
                                  const Text('จดจำฉัน',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ลืมรหัสผ่าน?',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.012),
                        SizedBox(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.06,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
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
    String phoneError = '';
    String passwordError = '';

    if (phoneCtl.text.isNotEmpty && passwordCtl.text.isNotEmpty) {
      UserLogin userlogin = UserLogin(
        phone: phoneCtl.text,
        password: passwordCtl.text,
      );

      var config = await Configuration.getConfig();
      url = config['apiEndPoint'];

      try {
        // ส่งคำขอเข้าสู่ระบบไปยัง API
        final response = await http.post(
          Uri.parse('$url/user/login'),
          body: json.encode(userlogin.toJson()),
          headers: {"Content-Type": "application/json; charset=utf-8"},
        );

        log('Response status code: ${response.statusCode}');
        log('Response body: ${response.body}');

        if (response.statusCode == 200) {
          log('Login request successful.');
          var user = selectUserAllFromJson(response.body);

          // ตรวจสอบว่า user มีข้อมูลหรือไม่
          if (user == null) {
            showErrorDialog(
                'หมายเลขโทรศัพท์หรือรหัสผ่านไม่ถูกต้อง\nกรุณาลองอีกครั้ง');
            return;
          }

          log('Login success: ${user.phone}');

          // บันทึกข้อมูลใน GetStorage
          box.write('phone', user.phone);
          box.write('uid',
              user.uid != null ? user.uid.toString() : user.rid.toString());

          // บันทึกสถานะ "จดจำฉัน"
          if (rememberMe) {
            box.write('rememberMe', true);
            box.write('savedPhone', user.phone);
            box.write('savedPassword', user.password);
          } else {
            box.remove('rememberMe');
            box.remove('savedPhone');
            box.remove('savedPassword');
          }

          // นำผู้ใช้ไปยังหน้า Nav ตามประเภทของ user
          if (user.type == 1) {
            Get.to(() => NavbuttompageUser(
                  selectedPage: 0,
                  phoneNumber: user.phone,
                ));
          } else if (user.type == 2) {
            Get.to(() => NavbottompageRider(
                  selectedPages: 0,
                  phoneNumber: user.phone,
                ));
          }
        } else {
          // กรณีที่ status code ไม่ใช่ 200
          showErrorDialog(
              'หมายเลขโทรศัพท์หรือรหัสผ่านไม่ถูกต้อง\nกรุณาลองอีกครั้ง');
          log('Login failed with status code: ${response.statusCode}');
        }
      } catch (e) {
        // จับ error และ log ข้อความเพื่อดูรายละเอียด
        log('Login error: $e');
        showErrorDialog(
            'หมายเลขโทรศัพท์หรือรหัสผ่านไม่ถูกต้อง\nกรุณาลองอีกครั้ง');
      }
    } else {
      if (phoneCtl.text.isEmpty) {
        phoneError += 'กรุณากรอกหมายเลขโทรศัพท์\n';
      }
      if (passwordCtl.text.isEmpty) {
        passwordError += 'กรุณากรอกรหัสผ่าน';
      }
      showErrorDialog(phoneError + passwordError);
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 25, 10, 10),
                  child: Center(
                    child: Text(
                      "เกิดข้อผิดพลาด!", // "Error"
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    message, // แสดงข้อความข้อผิดพลาด
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: screenWidth * 0.6,
                        height: screenHeight * 0.06,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color(0xFFFF7723)), // สีพื้นหลัง
                          ),
                          child: const Text(
                            'ตกลง',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors
                                  .white, // เปลี่ยนสีข้อความให้เหมาะสมกับพื้นหลัง
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
