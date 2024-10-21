import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermes_app/pages_rider/home_rider.dart';
import 'package:hermes_app/pages_rider/profile_rider.dart';

class NavbottompageRider extends StatefulWidget {
  int selectedPages = 0;
  NavbottompageRider({
    super.key,
    required this.selectedPages,
    required String phoneNumber,
  });

  @override
  State<NavbottompageRider> createState() => _NavbottomState();
}

class _NavbottomState extends State<NavbottompageRider> {
  late final List<Widget> pageOptions;

  @override
  void initState() {
    pageOptions = [const HomeRiderpage(), const ProfileRider()];
    // loadData = _initializeStorage();
    super.initState();
  }

  void onItemTapped(int index) {
    setState(() {
      widget.selectedPages = index;
    });
  }

  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: null,
      // ตรวจสอบว่าเป็นหน้าโปรไฟล์หรือหน้าตรวจผลรางวัลหรือไม่
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M19.903 8.586a.997.997 0 0 0-.196-.293l-6-6a.997.997 0 0 0-.293-.196c-.03-.014-.062-.022-.094-.033a.991.991 0 0 0-.259-.051C13.04 2.011 13.021 2 13 2H6c-1.103 0-2 .897-2 2v16c0 1.103.897 2 2 2h12c1.103 0 2-.897 2-2V9c0-.021-.011-.04-.013-.062a.952.952 0 0 0-.051-.259c-.01-.032-.019-.063-.033-.093zM16.586 8H14V5.414L16.586 8zM6 20V4h6v5a1 1 0 0 0 1 1h5l.002 10H6z"></path><path d="M8 12h8v2H8zm0 4h8v2H8zm0-8h2v2H8z"></path></svg>',
              width: screenWidth * 0.08,
              height: screenWidth * 0.08,
              fit: BoxFit.cover,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            activeIcon: SvgPicture.string(
              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M19.903 8.586a.997.997 0 0 0-.196-.293l-6-6a.997.997 0 0 0-.293-.196c-.03-.014-.062-.022-.094-.033a.991.991 0 0 0-.259-.051C13.04 2.011 13.021 2 13 2H6c-1.103 0-2 .897-2 2v16c0 1.103.897 2 2 2h12c1.103 0 2-.897 2-2V9c0-.021-.011-.04-.013-.062a.952.952 0 0 0-.051-.259c-.01-.032-.019-.063-.033-.093zM16.586 8H14V5.414L16.586 8zM6 20V4h6v5a1 1 0 0 0 1 1h5l.002 10H6z"></path><path d="M8 12h8v2H8zm0 4h8v2H8zm0-8h2v2H8z"></path></svg>',
              width: screenWidth * 0.08,
              height: screenWidth * 0.08,
              fit: BoxFit.cover,
              color: const Color(0xFFFF7723),
            ),
            label: 'รายการ',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2A10.13 10.13 0 0 0 2 12a10 10 0 0 0 4 7.92V20h.1a9.7 9.7 0 0 0 11.8 0h.1v-.08A10 10 0 0 0 22 12 10.13 10.13 0 0 0 12 2zM8.07 18.93A3 3 0 0 1 11 16.57h2a3 3 0 0 1 2.93 2.36 7.75 7.75 0 0 1-7.86 0zm9.54-1.29A5 5 0 0 0 13 14.57h-2a5 5 0 0 0-4.61 3.07A8 8 0 0 1 4 12a8.1 8.1 0 0 1 8-8 8.1 8.1 0 0 1 8 8 8 8 0 0 1-2.39 5.64z"></path><path d="M12 6a3.91 3.91 0 0 0-4 4 3.91 3.91 0 0 0 4 4 3.91 3.91 0 0 0 4-4 3.91 3.91 0 0 0-4-4zm0 6a1.91 1.91 0 0 1-2-2 1.91 1.91 0 0 1 2-2 1.91 1.91 0 0 1 2 2 1.91 1.91 0 0 1-2 2z"></path></svg>',
              width: screenWidth * 0.08,
              height: screenWidth * 0.08,
              fit: BoxFit.cover,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            activeIcon: SvgPicture.string(
              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.579 2 2 6.579 2 12s4.579 10 10 10 10-4.579 10-10S17.421 2 12 2zm0 5c1.727 0 3 1.272 3 3s-1.273 3-3 3c-1.726 0-3-1.272-3-3s1.274-3 3-3zm-5.106 9.772c.897-1.32 2.393-2.2 4.106-2.2h2c1.714 0 3.209.88 4.106 2.2C15.828 18.14 14.015 19 12 19s-3.828-.86-5.106-2.228z"></path></svg>',
              width: screenWidth * 0.08,
              height: screenWidth * 0.08,
              fit: BoxFit.cover,
              color: const Color(0xFFFF7723),
            ),
            label: 'โปรไฟล์',
          ),
        ],
        currentIndex: widget.selectedPages,
        onTap: onItemTapped,
        selectedLabelStyle: TextStyle(
          fontFamily: 'prompt',
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'prompt',
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF7723),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        type: BottomNavigationBarType.fixed,
      ),

      body: pageOptions[widget.selectedPages],
    );
  }
}
