import 'package:flutter/material.dart';

class Statuspage extends StatefulWidget {
  const Statuspage({super.key});

  @override
  State<Statuspage> createState() => _StatuspageState();
}

class _StatuspageState extends State<Statuspage> {
  @override
  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.35,
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
                      Center(
                        child: Image.asset(
                          'assets/images/Logo_status.png',
                          width: screenWidth * 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.045,
                screenHeight * 0.28,
                screenWidth * 0.045,
                0,
              ),
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.7,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(18), // โค้งที่มุมทั้งหมด
                ),
                child: const Text(
                  'x',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
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
