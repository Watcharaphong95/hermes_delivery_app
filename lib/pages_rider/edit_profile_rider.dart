import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/request/rider_where_id.dart';
import 'package:hermes_app/models/response/select_user_uid.dart';
import 'package:hermes_app/models/select_user_all.dart';
import 'package:hermes_app/pages_user/profile.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:map_picker/map_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileRider extends StatefulWidget {
  const EditProfileRider({super.key});

  @override
  State<EditProfileRider> createState() => _EditProfileUserState();
}

class _EditProfileUserState extends State<EditProfileRider> {
  String url = "";
  final box = GetStorage();
  List<SelectRiderRid> user = [];
  TextEditingController nameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  String pictureUrl = "";
  double screenWidth = 0, screenHeight = 0;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? savedFile;

  var db = FirebaseFirestore.instance;

  String apiKey = "", sameAddress = "";
  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();
  late CameraPosition initPosition;
  var place = const LatLng(0, 0);
  Set<Marker> markers = {};
  LatLng? currentLocation;
  late List<Placemark> placemarks = [];

  @override
  void initState() {
    super.initState();
    getTUser();
    getConfig();
    checkPermission();
    getCurrentPositionFromStart();
    getCurrentPosition();
  }

  void getConfig() {
    Configuration.getConfig().then((config) {
      setState(() {
        apiKey = config['apiKey'];
      });
    });
  }

  Future<void> checkPermission() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  void getCurrentPositionFromStart() {
    initPosition = CameraPosition(
        target: LatLng(double.parse(box.read('curLat').toString()),
            double.parse(box.read('curLng').toString())),
        zoom: 17);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: user.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  Container(
                    width: screenWidth,
                    height: screenHeight * 0.2,
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
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 30),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 2, 0, 10),
                          child: Center(
                            child: Text(
                              "แก้ไขโปรไฟล์",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Stack(
                    children: [
                      // Container สำหรับการแก้ไขโปรไฟล์
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Container(
                          width: screenWidth * 0.85,
                          height: screenHeight * 0.80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 115, 30, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ช่องกรอกข้อมูล
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                                  child: Text("ชื่อ-นามสกุล"),
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
                                            fontSize: 14, color: Colors.black),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 35),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                                  child: Text("เบอร์โทรศัพท์"),
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
                                      controller: phoneCtl,
                                      decoration: const InputDecoration(
                                        hintText: 'เบอร์โทรศัพท์',
                                        hintStyle: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 35),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                                  child: Text("ป้ายทะเบียน"),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.8,
                                  height: screenHeight * 0.2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Stack(children: [
                                      SizedBox(
                                        width: 275,
                                        child: TextField(
                                          maxLines: null,
                                          controller: addressCtl,
                                          decoration: const InputDecoration(
                                            hintText: 'ป้ายทะเบียน',
                                            hintStyle: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    97, 0, 0, 0)),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 35),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFbfbdbc)),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text(
                                          "ยกเลิก",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF3131),
                                          ),
                                        ),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFF7723)),
                                        onPressed: () {
                                          updateprofile(context);
                                        },
                                        child: const Text(
                                          "ยืนยัน",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // รูปโปรไฟล์
                      Positioned(
                        top: -screenHeight * 0.001,
                        left: (screenWidth * 0.85 - 155) / 2,
                        child: GestureDetector(
                          onTap: addProfileImage,
                          child: ClipOval(
                            child: (user.isNotEmpty &&
                                    user[0].picture.isNotEmpty &&
                                    !user[0].picture.contains(
                                        "ll")) // ตรวจสอบว่ามีรูปภาพที่ไม่เป็น "ll"
                                ? (user[0].picture.startsWith('http')
                                    ? Image.network(
                                        user[0]
                                            .picture, // ใช้ Image.network ถ้าเป็น URL ที่ถูกต้อง
                                        width: screenWidth * 0.38,
                                        height: screenWidth * 0.38,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        user[0]
                                            .picture, // ใช้ Image.asset ถ้าข้อมูลเป็น Asset
                                        width: screenWidth * 0.38,
                                        height: screenWidth * 0.38,
                                        fit: BoxFit.cover,
                                      ))
                                : image != null
                                    ? Image.file(
                                        File(image!.path),
                                        width: screenWidth * 0.38,
                                        height: screenWidth * 0.38,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/Logo_register.png',
                                        width: screenWidth * 0.38,
                                        height: screenWidth * 0.38,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50)
                ],
              ),
      ),
    );
  }

  Future<void> getTUser() async {
    log(box.read('uid'));
    String? phone = box.read('phone');
    String? uid = box.read('uid');
    var config = await Configuration.getConfig();
    url = config['apiEndPoint'];

    var res = await http.get(Uri.parse('$url/rider/$uid'));
    log(res.body);
    user = selectRiderRidFromJson(res.body);

    // log(singleUser[0].toString());

    // user = singleUser;
    log(user[0].phone.toString());
    nameCtl.text = user[0].name;
    phoneCtl.text = user[0].phone;
    addressCtl.text = user[0].plate;
    pictureUrl = user[0].picture;
    setState(() {});
  }

  void updateprofile(BuildContext context) async {
    String? phone = box.read('phone');
    String? uid = box.read('uid');

    // ตรวจสอบว่า user[0].picture มีค่า
    if (user.isNotEmpty && user[0].picture.isNotEmpty) {
      // ถ้ามีค่าให้กำหนดให้ image เป็น user[0].picture
      pictureUrl = user[0].picture; // ใช้ URL ตรงๆ แทนการแปลงเป็น XFile
    }

    // ตรวจสอบว่า pictureUrl มีค่า
    if (pictureUrl == null) {
      log('Image is null or does not exist. Please select a valid image before updating the profile.');
      return; // ออกจากฟังก์ชันถ้า pictureUrl เป็น null
    }
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

    log('User picture: $pictureUrl'); // แสดง URL ของภาพที่กำหนด

    // จากนี้ไปจะเป็นการอัปเดตข้อมูลโปรไฟล์ตามปกติ
    var json = {
      "phone": phoneCtl.text.isNotEmpty ? phoneCtl.text : '',
      "name": nameCtl.text.isNotEmpty ? nameCtl.text : '',
      "plate": addressCtl.text.isNotEmpty ? addressCtl.text : '',
      "picture": pictureUrl!, // ใช้ URL ของภาพ
    };

    bool confirmUpdate = await showDialog<bool>(
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
                      padding: EdgeInsets.fromLTRB(0, 30, 10, 0),
                      child: Center(
                        child: Text(
                          "ยืนยันการเปลี่ยนข้อมูล",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("คุณต้องการเปลี่ยนข้อมูลโปรไฟล์หรือไม่?"),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text(
                              "ยกเลิก",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text(
                              "ยืนยัน",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7723),
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
        ) ??
        false;

    if (confirmUpdate) {
      try {
        var response = await http.put(
          Uri.parse('$url/rider/update/$uid'),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode(json),
        );

        if (response.statusCode == 200) {
          log('Profile updated successfully!');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Profilepage()),
          );
        } else {
          log('Failed to update profile: ${response.body}');
        }
      } catch (error) {
        log('Error updating profile: $error');
      }
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

  Future<void> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    initPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 17);
    setState(() {});
  }
}
