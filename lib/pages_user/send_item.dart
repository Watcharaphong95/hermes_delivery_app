import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:hermes_app/models/response/select_user_uid.dart';
import 'package:hermes_app/models/response/user_search_res.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class SendItem extends StatefulWidget {
  int uid;
  SendItem({super.key, required this.uid});

  @override
  State<SendItem> createState() => _SendItemState();
}

class _SendItemState extends State<SendItem> {
  final box = GetStorage();

  String url = "";
  String pictureUrl = "";

  var db = FirebaseFirestore.instance;

  List<PhoneSearchRes> receiverData = [];

  double screenWidth = 0, screenHeight = 0;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? savedFile;

  int uidReceiver = 0;

  @override
  void initState() {
    super.initState();
    callApiEndPoint();
    uidReceiver = widget.uid;
  }

  TextEditingController itemDetails = TextEditingController();
  TextEditingController itemName = TextEditingController();

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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            receiverData.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'ชื่อผู้รับ: ${receiverData[0].name}',
                                          style: const TextStyle(fontSize: 16)),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 12, 0, 0),
                                        child: Text(
                                            'เบอร์ผู้รับ: ${receiverData[0].phone}',
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 12, 0, 0),
                                        child: Text(
                                            'ที่อยู่: ${receiverData[0].address}',
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      )
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                        'ชื่อพัสดุ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Container(
                        width: screenWidth * 0.9,
                        // height: screenHeight * 0.05,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6E1E1),
                            borderRadius: BorderRadius.circular(11)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: SizedBox(
                            child: TextField(
                              controller: itemName,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'ชื่อพัสดุ',
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
                        'รายละเอียดพัสดุ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
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
                            fontWeight: FontWeight.bold, fontSize: 20),
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
                          onTap: addProfileImage,
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
                                : Image.asset(
                                    'assets/images/Logo_camera.png',
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
                      child: SizedBox(
                        width: screenWidth * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FilledButton(
                              onPressed: () {
                                Get.back();
                              },
                              style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFBFBDBC)),
                              child: const Text(
                                'ยกเลิก',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            FilledButton(
                              onPressed: confirmSendItem,
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

  //////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////

  Future<void> callApiEndPoint() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    log(url);
    var res = await http.get(Uri.parse('$url/user/$uidReceiver'));
    receiverData = phoneSearchResFromJson(res.body);
    log(receiverData[0].address);
    setState(() {});
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

  Future<void> confirmSendItem() async {
    if (image == null) return;
    await imageUpload();

    var res = await http.get(Uri.parse('$url/user/${receiverData[0].uid}'));
    var receiver = selectUserUidFromJson(res.body);

    res = await http.get(Uri.parse('$url/user/${box.read('uid')}'));
    var sender = selectUserUidFromJson(res.body);

    var data = {
      'item': itemName.text,
      'createAt': DateTime.now(),
      'receiverUid': receiverData[0].uid,
      'receiverName': receiver.name,
      'latReceiver': receiver.lat,
      'lngReceiver': receiver.lng,
      'senderUid': box.read('uid'),
      'senderName': sender.name,
      'latSender': sender.lat,
      'lngSender': sender.lng,
      'detail': itemDetails.text,
      'picture': pictureUrl,
      'status': 1,
      'riderRid': null,
      'latRider': null,
      'lngRider': null,
    };

    db
        .collection('order')
        .doc(DateTime.timestamp().millisecondsSinceEpoch.toString())
        .set(data);
  }

  Future<void> imageUpload() async {
    log(image!.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref();
    Reference refUserProfile = ref.child('order');
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
}
