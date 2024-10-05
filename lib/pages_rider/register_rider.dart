import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RegisterRiderpage extends StatefulWidget {
  const RegisterRiderpage({super.key});

  @override
  State<RegisterRiderpage> createState() => _RegisterRiderpageState();
}

class _RegisterRiderpageState extends State<RegisterRiderpage> {
  double screenWidth = 0;
  double screenHeight = 0;

  String pictureUrl = "";

  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? savedFile;

  @override
  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
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
              child: GestureDetector(
                onTap: addProfileImage,
                child: Image.asset(
                  'assets/images/Logo_register.png',
                  width: screenWidth,
                  height: screenHeight * 0.18,
                ),
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
                          hintText: 'ป้ายทะเบียนรถ',
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
                        onPressed: createAccount,
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
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> createAccount() async {
    log(image!.path);
    if (image == null) return;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref();
    Reference refUserProfile = ref.child('profile');
    Reference imageToUpload = refUserProfile.child(fileName);

    try {
      await imageToUpload.putFile(File(image!.path));
      log('test');
      pictureUrl = await imageToUpload.getDownloadURL();
      log(pictureUrl);
    } catch (e) {
      log('Error!');
    }
  }

  void addProfileImage() {
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
