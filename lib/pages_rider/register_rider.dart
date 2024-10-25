import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/rider_register_req.dart';
import 'package:hermes_app/pages_user/login.dart';
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
  final RxBool isPasswordVisible = true.obs;
  final RxBool isPasswordVisible1 = true.obs;

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
                        keyboardType: TextInputType.number,
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
                        obscureText: isPasswordVisible.value,
                        controller: passwordCtl,
                        decoration: InputDecoration(
                            hintText: 'รหัสผ่าน',
                            hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(97, 0, 0, 0)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 35),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  isPasswordVisible.value =
                                      !isPasswordVisible.value;
                                  setState(() {});
                                },
                                icon: Icon(isPasswordVisible.value
                                    ? Icons.visibility_off
                                    : Icons.visibility))),
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
                        obscureText: isPasswordVisible1.value,
                        controller: confirmpasswordCtl,
                        decoration: InputDecoration(
                            hintText: 'ยืนยันรหัสผ่าน',
                            hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(97, 0, 0, 0)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 35),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  isPasswordVisible1.value =
                                      !isPasswordVisible1.value;
                                  setState(() {});
                                },
                                icon: Icon(isPasswordVisible1.value
                                    ? Icons.visibility_off
                                    : Icons.visibility))),
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
    if (image == null) {
      showErrorDialog('กรุณาอัพโหลดรูปภาพ'); // "Please upload a picture"
      return;
    }

    if (phoneCtl.text.isEmpty ||
        RegExp(r'^\s+$').hasMatch(phoneCtl.text) ||
        !RegExp(r'^\d+$').hasMatch(phoneCtl.text)) {
      showErrorDialog(
          'กรุณากรอกหมายเลขโทรศัพท์'); // "Please enter your phone number"
      return;
    }

    if (nameCtl.text.isEmpty || RegExp(r'^\s+$').hasMatch(nameCtl.text)) {
      showErrorDialog('กรุณากรอกชื่อ'); // "Please enter your name"
      return;
    }

    if (passwordCtl.text.isEmpty ||
        RegExp(r'^\s+$').hasMatch(passwordCtl.text)) {
      showErrorDialog('กรุณากรอกรหัสผ่าน'); // "Please enter your password"
      return;
    }

    if (confirmpasswordCtl.text.isEmpty ||
        RegExp(r'^\s+$').hasMatch(passwordCtl.text)) {
      showErrorDialog(
          'กรุณากรอกรหัสผ่านอีกครั้ง'); // "Please confirm your password"
      return;
    }

    if (licenseplateCtl.text.isEmpty ||
        RegExp(r'^\s+$').hasMatch(licenseplateCtl.text)) {
      showErrorDialog('กรุณากรอกป้ายทะเบียน'); // "Please enter your address"
      return;
    }

    if (passwordCtl.text != confirmpasswordCtl.text) {
      showErrorDialog('รหัสผ่านไม่ตรงกัน'); // "Passwords do not match"
      return;
    }

    if (phoneCtl.text.length != 10) {
      showErrorDialog(
          'หมายเลขโทรศัพท์ต้องมี 10 หลัก'); // "Phone number must be 10 digits"
      return;
    }
    showLoadingDialog(context, true);
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

    if (phoneCtl.text.length == 10) {
      if (passwordCtl.text == confirmpasswordCtl.text) {
        RiderRegisterReq userRegisterReq = RiderRegisterReq(
          phone: phoneCtl.text,
          name: nameCtl.text,
          password: passwordCtl.text,
          picture: pictureUrl,
          plate: licenseplateCtl.text,
        );

        try {
          final response = await http.post(
            Uri.parse("$url/rider/register"),
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: json.encode(userRegisterReq.toJson()),
          );
          if (response.statusCode == 201) {
            showDialog(
              barrierDismissible: false,
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
                              "สมัครสมาชิกสำเร็จ!", // "Success"
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "ยินดีต้อนรับสู่ระบบขนส่ง HERMES ครับ", // "Item sent successfully"
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SizedBox(
                                width: screenWidth * 0.6,
                                height: screenHeight * 0.06,
                                child: FilledButton(
                                  onPressed: () {
                                    Get.to(() => const LoginPage());
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(0xFFFF7723)), // สีพื้นหลัง
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
          } else {
            showDialog(
              barrierDismissible: false,
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
                              "สมัครสมาชิกไม่สำเร็จ", // "Success"
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "เบอร์นี้ถูกใช้แล้ว", // "Item sent successfully"
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SizedBox(
                                width: screenWidth * 0.6,
                                height: screenHeight * 0.06,
                                child: FilledButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.back();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(0xFFFF7723)), // สีพื้นหลัง
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

  Future<void> addProfileImage() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.82,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'เลือกรูปภาพ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.camera, size: 30),
                  title: const Text('ถ่ายรูปจากกล้อง',
                      style: TextStyle(fontSize: 16)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        setState(() {
                          image = pickedFile;
                        });
                      }
                    } catch (e) {
                      log("Error picking image: $e");
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.photo_library, size: 30),
                  title: const Text('เลือกรูปจากแกลเลอรี',
                      style: TextStyle(fontSize: 16)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          image = pickedFile;
                        });
                      }
                    } catch (e) {
                      log("Error picking image: $e");
                    }
                  },
                ),
                const Divider(),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ปิด',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFFF7723),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLoadingDialog(BuildContext context, bool isLoading) {
    if (!isLoading) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 10,
                    ),
                  ),
                  SizedBox(height: 20), // Space between the indicator and text
                  Text(
                    "กำลังโหลด...",
                    style: TextStyle(color: Colors.white),
                  ), // Optional loading text
                ],
              ),
            ),
          ),
        );
      },
    );
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
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFFFF7723)), // สีพื้นหลัง
                          ),
                          child: const Text(
                            'ตกลง',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
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

//   void addProfileImage() {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Center(child: Text('เลือกวิธีเพิ่มรูปภาพ')),
//             content: Container(
//               width: screenWidth * 0.5, // Adjust width
//               height: screenHeight * 0.5, // Adjust height
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   InkWell(
//                       onTap: imageFromCamera,
//                       child: SvgPicture.asset(
//                         'assets/images/cameraAdd.svg',
//                         width: screenWidth * 0.3,
//                       )),
//                   SizedBox(
//                     width: screenWidth * 0.07,
//                   ),
//                   InkWell(
//                       onTap: imageFromFile,
//                       child: SvgPicture.asset(
//                         'assets/images/fileAdd.svg',
//                         width: screenWidth * 0.3,
//                       )),
//                 ],
//               ),
//             ),
//             actions: [
//               Center(
//                 child: FilledButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text('ปิด')),
//               )
//             ],
//           );
//         });
//   }

//   Future<void> imageFromCamera() async {
//     // Pick an image from the camera
//     final XFile? pickedImage =
//         await picker.pickImage(source: ImageSource.camera);
//     if (pickedImage != null) {
//       image = pickedImage; // Store XFile directly
//       pictureUrl =
//           pickedImage.path; // Store the path of the image in pictureUrl
//       log(image!.path);
//     } else {
//       log('No image');
//     }
//     setState(() {}); // Update UI
//   }

//   Future<void> imageFromFile() async {
//     // Pick an image from the gallery
//     final XFile? pickedImage =
//         await picker.pickImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       image = pickedImage; // Store XFile directly
//       pictureUrl =
//           pickedImage.path; // Store the path of the image in pictureUrl
//       log(image!.path);
//     } else {
//       log('No image');
//     }
//     setState(() {}); // Update UI
//   }
// }
}
