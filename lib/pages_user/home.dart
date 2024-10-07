import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/user_search_res.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String url = "";

  List<PhoneSearchRes> phoneGetResponse = [];

  TextEditingController phoneSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    callApiEndPoint();
  }

  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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
            Column(
              children: [
                // Check if phoneGetResponse is not null and has items
                // if (phoneGetResponse != null && phoneGetResponse.isNotEmpty)
                // Expanded(
                //   child: ListView(
                //     children: phoneGetResponse
                //         .map((phone) => Card(
                //               child: Text(phone.name),
                //             ))
                //         .toList(),
                //   ),
                // )
                // else
                const SizedBox(
                  height: 20, // Adjust space as needed
                ),
                const Text(
                  "กรุณาค้นหาเบอร์",
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFFBFBDBC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "ผู้รับสินค้า",
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFFBFBDBC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
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
    phoneGetResponse = phoneSearchResFromJson(res.body);
    log(phoneGetResponse.length.toString());
    setState(() {});
  }
}
