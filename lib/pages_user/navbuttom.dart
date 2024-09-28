import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermes_app/pages_user/home.dart';
import 'package:hermes_app/pages_user/items_received.dart';
import 'package:hermes_app/pages_user/profile.dart';

class Navbuttompage extends StatefulWidget {
  int selectedPage = 0;
  Navbuttompage({
    super.key,
    required this.selectedPage,
  });

  @override
  State<Navbuttompage> createState() => _NavbuttompageState();
}

class _NavbuttompageState extends State<Navbuttompage> {
  late final List<Widget> pageOptions;
  @override
  void initState() {
    pageOptions = [
      const Homepage(),
      const ItemsReceivedpage(),
      const Homepage(),
      const Profilepage(),
    ];
    // loadData = _initializeStorage();
    super.initState();
  }

  void onItemTapped(int index) {
    setState(() {
      widget.selectedPage = index;
    });
  }

  @override
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
            label: 'หน้าหลัก',
          ),
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
              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M22 8a.76.76 0 0 0 0-.21v-.08a.77.77 0 0 0-.07-.16.35.35 0 0 0-.05-.08l-.1-.13-.08-.06-.12-.09-9-5a1 1 0 0 0-1 0l-9 5-.09.07-.11.08a.41.41 0 0 0-.07.11.39.39 0 0 0-.08.1.59.59 0 0 0-.06.14.3.3 0 0 0 0 .1A.76.76 0 0 0 2 8v8a1 1 0 0 0 .52.87l9 5a.75.75 0 0 0 .13.06h.1a1.06 1.06 0 0 0 .5 0h.1l.14-.06 9-5A1 1 0 0 0 22 16V8zm-10 3.87L5.06 8l2.76-1.52 6.83 3.9zm0-7.72L18.94 8 16.7 9.25 9.87 5.34zM4 9.7l7 3.92v5.68l-7-3.89zm9 9.6v-5.68l3-1.68V15l2-1v-3.18l2-1.11v5.7z"></path></svg>',
              width: screenWidth * 0.08,
              height: screenWidth * 0.08,
              fit: BoxFit.cover,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            activeIcon: SvgPicture.string(
              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M21.993 7.95a.96.96 0 0 0-.029-.214c-.007-.025-.021-.049-.03-.074-.021-.057-.04-.113-.07-.165-.016-.027-.038-.049-.057-.075-.032-.045-.063-.091-.102-.13-.023-.022-.053-.04-.078-.061-.039-.032-.075-.067-.12-.094-.004-.003-.009-.003-.014-.006l-.008-.006-8.979-4.99a1.002 1.002 0 0 0-.97-.001l-9.021 4.99c-.003.003-.006.007-.011.01l-.01.004c-.035.02-.061.049-.094.073-.036.027-.074.051-.106.082-.03.031-.053.067-.079.102-.027.035-.057.066-.079.104-.026.043-.04.092-.059.139-.014.033-.032.064-.041.1a.975.975 0 0 0-.029.21c-.001.017-.007.032-.007.05V16c0 .363.197.698.515.874l8.978 4.987.001.001.002.001.02.011c.043.024.09.037.135.054.032.013.063.03.097.039a1.013 1.013 0 0 0 .506 0c.033-.009.064-.026.097-.039.045-.017.092-.029.135-.054l.02-.011.002-.001.001-.001 8.978-4.987c.316-.176.513-.511.513-.874V7.998c0-.017-.006-.031-.007-.048zm-10.021 3.922L5.058 8.005 7.82 6.477l6.834 3.905-2.682 1.49zm.048-7.719L18.941 8l-2.244 1.247-6.83-3.903 2.153-1.191zM13 19.301l.002-5.679L16 11.944V15l2-1v-3.175l2-1.119v5.705l-7 3.89z"></path></svg>',
              width: screenWidth * 0.08,
              height: screenWidth * 0.08,
              fit: BoxFit.cover,
              color: const Color(0xFFFF7723),
            ),
            label: 'สั่งของ',
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
        currentIndex: widget.selectedPage,
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

      body: pageOptions[widget.selectedPage],
    );
  }
}
