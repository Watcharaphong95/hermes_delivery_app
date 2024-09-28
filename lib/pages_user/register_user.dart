import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterUserpage extends StatefulWidget {
  const RegisterUserpage({super.key});

  @override
  State<RegisterUserpage> createState() => _RegisterUserpageState();
}

class _RegisterUserpageState extends State<RegisterUserpage> {
  @override
  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * 0.25,
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
                      "สร้างบัญชีผู้ใช้",
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
            Padding(
              padding: const EdgeInsets.all(18),
              child: Image.asset(
                'assets/images/Logo_register.png',
                width: screenWidth,
                height: screenHeight * 0.18,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.06,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'หมายเลขโทรศัพท์',
                          hintStyle: TextStyle(
                              fontSize: 14, color: Color.fromARGB(97, 0, 0, 0)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.06,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'ชื่อ',
                          hintStyle: TextStyle(
                              fontSize: 14, color: Color.fromARGB(97, 0, 0, 0)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.06,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'รหัสผ่าน',
                          hintStyle: TextStyle(
                              fontSize: 14, color: Color.fromARGB(97, 0, 0, 0)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.06,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'ยืนยันรหัสผ่าน',
                          hintStyle: TextStyle(
                              fontSize: 14, color: Color.fromARGB(97, 0, 0, 0)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.06,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'ที่อยู่',
                          hintStyle: TextStyle(
                              fontSize: 14, color: Color.fromARGB(97, 0, 0, 0)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.06,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0), // ระยะห่างจาก TextField
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7723),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'ปักหมุดที่อยู่ของคุณ',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.06,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0), // ระยะห่างจาก TextField
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7723),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'สร้างบัญชี',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
