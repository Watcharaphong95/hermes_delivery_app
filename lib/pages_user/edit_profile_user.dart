import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/request/user_where_id.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:map_picker/map_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileUserpage extends StatefulWidget {
  const EditProfileUserpage({super.key});

  @override
  State<EditProfileUserpage> createState() => _EditProfileUserpageState();
}

class _EditProfileUserpageState extends State<EditProfileUserpage> {
  String url = "";
  final box = GetStorage();
  List<SelectUserWhereId> user = [];
  TextEditingController nameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  String pictureUrl = "";
  double screenWidth = 0, screenHeight = 0;
  final ImagePicker picker = ImagePicker();
  XFile? image;

  var db = FirebaseFirestore.instance;

  String apiKey = "", sameAddress = "";
  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();
  late CameraPosition initPosition;
  var place = const LatLng(0, 0);
  Set<Marker> markers = {};
  LatLng? currentLocation;
  late List<Placemark> placemarks;

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
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      // Container สำหรับการแก้ไขโปรไฟล์
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Container(
                          width: screenWidth * 0.85,
                          height: screenHeight * 0.78,
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
                                  child: Text("ที่อยู่"),
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
                                            hintText: 'ที่อยู่',
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
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Container(
                                          height:
                                              50, // Set this to match your desired height
                                          width:
                                              50, // Set a fixed width for the button
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFFF7723),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: IconButton(
                                            icon: const Icon(Icons.search),
                                            color: Colors.white,
                                            onPressed:
                                                addressCtl.text.isNotEmpty
                                                    ? () {
                                                        placeSearch();
                                                      }
                                                    : null,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 30),
                                    child: Text(
                                      'Latitude: ${user[0].lat} Longitude: ${user[0].lng}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                // ปุ่มการกระทำ
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: showMapPicker,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFbfbdbc),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text('เปลี่ยนปักหมุด',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        updateprofile();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFF7723),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text('ยืนยัน',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // รูปโปรไฟล์
                      Positioned(
                        top: -screenHeight * 0.001,
                        left: (screenWidth * 0.85 - 150) / 2,
                        child: GestureDetector(
                          onTap: addProfileImage,
                          child: ClipOval(
                            child: image != null
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
    String? phone = box.read('phone');
    String? uid = box.read('uid');
    var config = await Configuration.getConfig();
    url = config['apiEndPoint'];
    var res = await http.get(Uri.parse('$url/user/$uid'));
    log(res.body);
    user = selectUserWhereIdFromJson(res.body);
    log(user.length.toString());
    nameCtl.text = user[0].name;
    phoneCtl.text = user[0].phone;
    addressCtl.text = user[0].address;
    pictureUrl = user[0].picture;
    setState(() {});
  }

  void updateprofile() async {
    String? phone = box.read('phone');
    String? uid = box.read('uid');
    var json = {
      "phone": phoneCtl,
      "name": nameCtl,
      "address": addressCtl,
      // "lat": lat,
      // "lng": lng,
      "picture": pictureUrl,
    };
    // Not using the model, use jsonEncode() and jsonDecode()
    try {
      var res = await http.put(Uri.parse('$url/user/$uid'),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode(json));
      log(res.body);
      var result = jsonDecode(res.body);
      // Need to know json's property by reading from API Tester
      log(result['message']);
    } catch (err) {}
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

  // ฟังก์ชันสำหรับค้นหาสถานที่
  Future<void> placeSearch() async {
    log('Searching for place...');
    if (addressCtl.text.length > 1) {
      final String url =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${addressCtl.text}&language=th&key=${apiKey}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK') {
          double latitude = data['results'][0]['geometry']['location']['lat'];
          double longitude = data['results'][0]['geometry']['location']['lng'];

          initPosition =
              CameraPosition(target: LatLng(latitude, longitude), zoom: 17);
          log("Location found: Latitude: $latitude, Longitude: $longitude");
        } else {
          log('Place not found.');
        }
      } else {
        log('Error fetching data: ${response.statusCode}');
      }
      showMapPicker(); // เรียกฟังก์ชันเพื่อแสดงแผนที่
      setState(() {});
    } else {
      log('Address input is too short.');
    }
  }

  Future<void> showMapPicker() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // Removes any padding
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: MapPicker(
                  iconWidget: SvgPicture.asset(
                    'assets/images/location_icon.svg',
                    height: 60,
                  ),
                  mapPickerController: MapPickerController(),
                  child: GoogleMap(
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    key: UniqueKey(),
                    trafficEnabled: true,
                    mapType: MapType.hybrid,
                    initialCameraPosition: initPosition,
                    markers: markers, // Pass markers to the GoogleMap
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      // Optionally add a marker for the previous location, if desired
                      if (currentLocation != null) {
                        markers.add(
                          Marker(
                            markerId: const MarkerId('previous_location'),
                            position: currentLocation!,
                            infoWindow:
                                const InfoWindow(title: 'Previous Location'),
                          ),
                        );
                        setState(() {}); // Update the UI to show the marker
                      }
                    },
                    onCameraMove: (cameraPosition) {
                      setState(() {
                        this.initPosition = cameraPosition;
                      });
                    },
                    onCameraIdle: () async {
                      mapPickerController.mapFinishedMoving!();
                      // ignore: unused_local_variable
                      placemarks = await placemarkFromCoordinates(
                        initPosition.target.latitude,
                        initPosition.target.longitude,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 25,
                left: 100,
                right: 100,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7723)),
                  onPressed: () async {
                    if (placemarks.isNotEmpty) {
                      final String url =
                          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${initPosition.target.latitude},${initPosition.target.longitude}&radius=40&language=th&type=point_of_interest&key=${apiKey}';
                      final response = await http.get(Uri.parse(url));
                      if (response.statusCode == 200) {
                        final Map<String, dynamic> data =
                            jsonDecode(response.body);
                        if (data['status'] == 'OK' &&
                            data['results'].isNotEmpty) {
                          final place = data['results'][0];
                          final String name = place['name'];
                          final String url =
                              'https://maps.googleapis.com/maps/api/geocode/json?latlng=${initPosition.target.latitude},${initPosition.target.longitude}&key=$apiKey&language=th';
                          final response = await http.get(Uri.parse(url));
                          if (response.statusCode == 200) {
                            final Map<String, dynamic> data =
                                jsonDecode(response.body);
                            if (data['status'] == 'OK' &&
                                data['results'].isNotEmpty) {
                              final place = data['results'][0];
                              final String formattedAddress =
                                  place['formatted_address'];
                              log('Name: $name, Formatted Address: $formattedAddress');
                              List<String> components =
                                  formattedAddress.trim().split(' ');
                              List<String> fixComponents =
                                  components.sublist(0, components.length - 1);
                              addressCtl.text = name + fixComponents.join(' ');
                              log(addressCtl.text);
                            }
                          }
                        } else {
                          final String url =
                              'https://maps.googleapis.com/maps/api/geocode/json?latlng=${initPosition.target.latitude},${initPosition.target.longitude}&key=$apiKey&language=th';
                          final response = await http.get(Uri.parse(url));
                          if (response.statusCode == 200) {
                            final Map<String, dynamic> data =
                                jsonDecode(response.body);
                            if (data['status'] == 'OK' &&
                                data['results'].isNotEmpty) {
                              final place = data['results'][0];
                              final String formattedAddress =
                                  place['formatted_address'];
                              log('Formatted Address: $formattedAddress');
                              List<String> components =
                                  formattedAddress.trim().split(' ');
                              List<String> fixComponents =
                                  components.sublist(0, components.length - 1);
                              addressCtl.text = fixComponents.join(' ');
                              log(addressCtl.text);
                            }
                          }
                          log('No point of interest found!');
                        }
                      }
                    }
                    log('lat: ${initPosition.target.latitude} lng: ${initPosition.target.longitude}');
                    currentLocation = LatLng(initPosition.target.latitude,
                        initPosition.target.longitude);
                    // Clear existing markers and add the new one
                    markers.clear(); // Clear the markers set
                    markers.add(
                      // Add the new marker to the set
                      Marker(
                        markerId: const MarkerId('current_location'),
                        position: currentLocation!,
                        infoWindow: const InfoWindow(title: 'Current Location'),
                      ),
                    );

                    setState(() {}); // Update the UI with the new state
                    Navigator.pop(
                        context); // Close dialog after selecting location
                  },
                  child: const Text(
                    'ยืนยัน',
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
