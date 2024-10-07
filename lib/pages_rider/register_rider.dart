import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/rider_register_req.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  String url = '';

  TextEditingController phoneCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmpasswordCtl = TextEditingController();
  TextEditingController licenseplateCtl = TextEditingController();

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
                child: image != null
                    ? ClipOval(
                        child: Image.file(
                          File(image!.path),
                          width: screenWidth * 0.38,
                          height: screenWidth * 0.38,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/Logo_register.png',
                        width: screenWidth,
                        height: screenWidth * 0.38,
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
                      child: TextField(
                        controller: phoneCtl,
                        decoration: const InputDecoration(
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
                      child: TextField(
                        controller: nameCtl,
                        decoration: const InputDecoration(
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
                      child: TextField(
                        controller: passwordCtl,
                        decoration: const InputDecoration(
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
                      child: TextField(
                        controller: confirmpasswordCtl,
                        decoration: const InputDecoration(
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
                      child: TextField(
                        controller: licenseplateCtl,
                        decoration: const InputDecoration(
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
    log(image?.path ?? 'No image selected');
    if (image == null) return;

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref();
    Reference refUserProfile = ref.child('profile');
    Reference imageToUpload = refUserProfile.child(fileName);

    try {
      await imageToUpload.putFile(File(image!.path));
      log('Image uploaded successfully');
      pictureUrl = await imageToUpload.getDownloadURL();
      log('Picture URL: $pictureUrl');
    } catch (e) {
      log('Error uploading image: $e');
      return; // Exit if upload fails
    }

    var config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    if (phoneCtl.text.isEmpty ||
        nameCtl.text.isEmpty ||
        passwordCtl.text.isEmpty ||
        confirmpasswordCtl.text.isEmpty ||
        licenseplateCtl.text.isEmpty ||
        pictureUrl.isEmpty) {
      log('All fields must be filled in.');
      return; // Exit if validation fails
    }

    int type = 2;
    if (phoneCtl.text.length == 10) {
      if (passwordCtl.text == confirmpasswordCtl.text) {
        RiderRegisterReq userRegisterReq = RiderRegisterReq(
          phone: phoneCtl.text,
          name: nameCtl.text,
          password: passwordCtl.text,
          picture: pictureUrl,
          plate: licenseplateCtl.text,
          type: type.toString(),
        );

        try {
          final response = await http.post(
            Uri.parse("$url/user/registerRider"),
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: json.encode(userRegisterReq.toJson()),
          );

          log('Registration response: ${response.statusCode} ${response.body}');
          if (response.statusCode == 200) {
            log('Registration successful!');
          } else {
            log('Registration failed with status code: ${response.statusCode}');
          }
        } catch (error) {
          log('Error during registration: $error');
        }
      } else {
        log('Passwords do not match.');
      }
    } else {
      log('Phone number must be 10 digits.');
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
    // Pick an image from the camera
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      image = pickedImage; // Store XFile directly
      pictureUrl =
          pickedImage.path; // Store the path of the image in pictureUrl
      log(image!.path);
    } else {
      log('No image');
    }
    setState(() {}); // Update UI
  }

  Future<void> imageFromFile() async {
    // Pick an image from the gallery
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = pickedImage; // Store XFile directly
      pictureUrl =
          pickedImage.path; // Store the path of the image in pictureUrl
      log(image!.path);
    } else {
      log('No image');
    }
    setState(() {}); // Update UI
  }
}
