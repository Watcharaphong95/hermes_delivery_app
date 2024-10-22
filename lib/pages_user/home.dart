import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/phone_user.dart';
import 'package:hermes_app/models/response/user_search_res.dart';
import 'package:hermes_app/pages_user/send_item.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({
    super.key,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String url = "";

  List<PhoneSearchRes> phoneGetResponse = [];

  TextEditingController phoneSearch = TextEditingController();

  List<SelectPhoneUser> selectPhoneUserFromJson(String str) {
    final jsonData = json.decode(str);

    if (jsonData is List) {
      return List<SelectPhoneUser>.from(
          jsonData.map((item) => SelectPhoneUser.fromJson(item)));
    } else {
      throw Exception('Expected a list of users, got: ${jsonData.runtimeType}');
    }
  }

  List<SelectPhoneUser> singleUser = [];

  @override
  void initState() {
    super.initState();
    callApiEndPoint();
    getTUser();
  }

  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
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
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E1E1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: phoneSearch,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'ค้นหาเบอร์ผู้รับสินค้า',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(97, 0, 0, 0),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.052,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        onPressed: buttonSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7723),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'ค้นหา',
                          style: TextStyle(
                            fontSize: 12,
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
            SizedBox(
              height: screenHeight,
              width: screenWidth * 0.9,
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight,
                    width: screenWidth * 0.9,
                    child: Column(
                      children: [
                        // Check if phoneGetResponse is not null and has items
                        if (phoneGetResponse.isNotEmpty)
                          Expanded(
                            child: ListView(
                              children: phoneGetResponse
                                  .map((searchResult) => InkWell(
                                        onTap: () {
                                          Get.to(() =>
                                              SendItem(uid: searchResult.uid));
                                        },
                                        child: Card(
                                          color: const Color(0xFFE8E8E8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(width: 20),
                                              Container(
                                                width: screenWidth * 0.15,
                                                height: screenHeight * 0.1,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            searchResult
                                                                .picture),
                                                        fit: BoxFit.cover)),
                                              ),
                                              const SizedBox(width: 15),
                                              SizedBox(
                                                height: screenHeight * 0.09,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      searchResult.phone,
                                                      style: const TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      searchResult.name,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )
                        else if (singleUser
                            .isNotEmpty) // Check if singleUser is not empty
                          Expanded(
                            child: ListView(
                              children: singleUser
                                  .map((user) => InkWell(
                                        onTap: () {
                                          Get.to(() => SendItem(uid: user.uid));
                                        },
                                        child: Card(
                                          color: const Color(0xFFE8E8E8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(width: 20),
                                              Container(
                                                width: screenWidth * 0.15,
                                                height: screenHeight * 0.1,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            user.picture),
                                                        fit: BoxFit.cover)),
                                              ),
                                              const SizedBox(width: 15),
                                              SizedBox(
                                                height: screenHeight * 0.09,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user.phone,
                                                      style: const TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      user.name,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )
                        else
                          const Center(
                              child: Text(
                                  'ไม่พบข้อมูลผู้ใช้')) // Message when no users found
                      ],
                    ),
                  )
                ],
              ),
            ),
          ]),
        ));
  }

  Future<void> getTUser() async {
    var config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    var res = await http.get(Uri.parse('$url/user/'));

    if (res.statusCode == 200) {
      try {
        // Ensure that we are parsing the correct response
        singleUser = selectPhoneUserFromJson(res.body);
        for (var user in singleUser) {
          log('User Phone: ${user.phone}');
        }
        setState(() {}); // Update the UI
      } catch (e) {
        log('Error parsing user data: $e');
      }
    } else {
      log('Failed to load users: ${res.statusCode}');
    }
  }

  Future<void> callApiEndPoint() async {
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
    // log(url);
  }

  void buttonSearch() async {
    var phoneSearchText = phoneSearch.text;
    var res = await http.get(Uri.parse('$url/user/search/$phoneSearchText'));
    log(res.body);
    phoneGetResponse = phoneSearchResFromJson(res.body);
    log(phoneGetResponse.length.toString());
    setState(() {});
  }
}
