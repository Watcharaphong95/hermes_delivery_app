import 'dart:developer';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hermes_app/navbar/navbuttom.dart';
import 'package:image_picker/image_picker.dart';

class Shippingpage extends StatefulWidget {
  Shippingpage({super.key});

  @override
  State<Shippingpage> createState() => _ShippingpageState();
}

class _ShippingpageState extends State<Shippingpage> {
  XFile? image;
  final ImagePicker picker = ImagePicker();

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
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("รายละเอียดผู้รับ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),
                  Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E1E1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ผู้รับ: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            Text(
                              'นายสมนึก ใจดี',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'เบอร์ผู้รับ: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            Text(
                              '0987654321',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ที่อยู่: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "123 หมู่ 4 ซอยสุขสันต์ ถนนเพลินสุข ตำบลบางหว้า อำเภอภาษีเจริญ จังหวัดกรุงเทพฯ 10160",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("รายละเอียดพัสดุ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: screenHeight * 0.2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E1E1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'เพิ่มรายละเอียดพัสดุ...',
                          hintStyle: TextStyle(
                              fontSize: 14, color: Color.fromARGB(97, 0, 0, 0)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("เพิ่มรูปภาพ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),
                  DottedBorder(
                    color: Colors.black,
                    strokeWidth: 2,
                    dashPattern: const [6, 3],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(30),
                    child: GestureDetector(
                      onTap: () async {
                        image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          log(image!.path);
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E1E1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        child: image == null
                            ? Image.asset(
                                'assets/images/Logo_camera.png',
                                width: screenWidth * 0.1,
                              )
                            : Image.file(
                                File(image!.path),
                                fit: BoxFit.cover,
                                width: screenWidth * 0.9,
                                height: screenHeight * 0.20,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.35,
                        height: screenHeight * 0.052,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => Navbuttompage(
                                    selectedPage: 0,
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFbfbdbc),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'ยกเลิก',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.35,
                        height: screenHeight * 0.052,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7723),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'ยืนยัน',
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
