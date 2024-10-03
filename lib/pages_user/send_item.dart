import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class SendItem extends StatefulWidget {
  const SendItem({super.key});

  @override
  State<SendItem> createState() => _SendItemState();
}

class _SendItemState extends State<SendItem> {
  double screenWidth = 0, screenHeight = 0;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? savedFile;

  TextEditingController itemDetails = TextEditingController();

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 45, 0, 0),
                      child: Image.asset(
                        'assets/images/Logo_home.png',
                        width: screenWidth * 0.3,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE6E1E1),
                          borderRadius: BorderRadius.circular(11)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ผู้รับ: นายสมนึก ใจดี',
                              style: TextStyle(fontSize: 18),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                              child: Text('เบอร์ผู้รับ: 0987654321',
                                  style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                              child: Text(
                                  'ที่อยู่: 123 หมู่ 4 ซอยสุขสันต์ ถนนเพลินสุข ตำบลบางหว้า อำเภอภาษีเจริญ จังหวัดกรุงเทพฯ 10160',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                        'รายละเอียดพัสดุ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.15,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6E1E1),
                            borderRadius: BorderRadius.circular(11)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: SizedBox(
                            child: TextField(
                              controller: itemDetails,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'เพิ่มรายละเอียดพัสดุ',
                                  hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(97, 0, 0, 0))),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                        'เพิ่มรูปภาพ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.3,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: InkWell(
                          onTap: imagePicker,
                          child: Center(
                            // Center the image within the container
                            child: (image != null)
                                ? Image.file(
                                    File(image!.path),
                                    fit: BoxFit.contain,
                                    width: screenWidth *
                                        0.85, // Ensure the image doesn't overflow horizontally
                                    height: screenHeight *
                                        0.3, // Ensure the image doesn't overflow vertically
                                  )
                                : SvgPicture.asset(
                                    'assets/images/cameraAdd.svg',
                                    fit: BoxFit
                                        .contain, // Make sure the SVG fits properly
                                    width: screenWidth *
                                        0.85, // Same size for the SVG
                                    height: screenHeight *
                                        0.2, // Adjust the height for SVG
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Container(
                        width: screenWidth * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFBFBDBC)),
                              child: const Text(
                                'ยกเลิก',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF7723)),
                              child: const Text('ยืนยัน',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void imagePicker() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('เลือกวิธีเพิ่มรูปภาพ')),
            content: Container(
              width: screenWidth * 0.5, // Adjust width
              height: screenHeight * 0.5, // Adjust height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: imageFromCamera,
                      child: SvgPicture.asset(
                        'assets/images/cameraAdd.svg',
                        width: screenWidth * 0.3,
                      )),
                  SizedBox(
                    width: screenWidth * 0.07,
                  ),
                  InkWell(
                      onTap: imageFromFile,
                      child: SvgPicture.asset(
                        'assets/images/fileAdd.svg',
                        width: screenWidth * 0.3,
                      )),
                ],
              ),
            ),
            actions: [
              Center(
                child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('ปิด')),
              )
            ],
          );
        });
  }

  Future<void> imageFromCamera() async {
    image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      log(image!.path);
    } else {
      log('No image');
    }
    setState(() {});
  }

  Future<void> imageFromFile() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      log(image!.path);
    } else {
      log('No image');
    }
    setState(() {});
  }
}
