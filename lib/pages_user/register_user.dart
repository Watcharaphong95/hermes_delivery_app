import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/pages_user/gg_map_test.dart';
import 'package:map_picker/map_picker.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class RegisterUserpage extends StatefulWidget {
  const RegisterUserpage({super.key});

  @override
  State<RegisterUserpage> createState() => _RegisterUserpageState();
}

class _RegisterUserpageState extends State<RegisterUserpage> {
  final box = GetStorage();

  String apiKey = "", sameAddress = "";
  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();
  late CameraPosition initPosition;
  var place = const LatLng(0, 0);
  Set<Marker> markers = {};
  LatLng? currentLocation;
  late List<Placemark> placemarks;

  double screenWidth = 0, screenHeight = 0;

  TextEditingController phoneCtl = TextEditingController();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController confirmpasswordCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();

  @override
  initState() {
    getCurrentPositionFromStart();
    getCurrentPosition();
    super.initState();
    getConfig();
  }

  void getConfig() {
    Configuration.getConfig().then((config) {
      setState(() {
        apiKey = config['apiKey'];
      });
    });
  }

  void getCurrentPositionFromStart() {
    initPosition = CameraPosition(
        target: LatLng(double.parse(box.read('curLat').toString()),
            double.parse(box.read('curLng').toString())),
        zoom: 17);
  }

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
                                  color: Color.fromARGB(97, 0, 0, 0)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 35),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            height: 50, // Set this to match your desired height
                            width: 50, // Set a fixed width for the button
                            decoration: BoxDecoration(
                                color: const Color(0xFFFF7723),
                                borderRadius: BorderRadius.circular(20)),
                            child: IconButton(
                              icon: const Icon(Icons.search),
                              color: Colors.white,
                              onPressed: addressCtl.text.isNotEmpty
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.06,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0), // ระยะห่างจาก TextField
                      child: ElevatedButton(
                        onPressed: showMapPicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7723),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'ปักหมุดที่อยู่ของคุณ',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                      'Latitude: ${currentLocation?.latitude.toStringAsFixed(5) ?? 0} Longitude: ${currentLocation?.longitude.toStringAsFixed(5) ?? 0}'),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.06,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0), // ระยะห่างจาก TextField
                  child: ElevatedButton(
                    onPressed: () {},
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
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

  void addProfileImage() {} // Store the previous selected location

  Future<void> placeSearch() async {
    log('test');
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
        }
      }
      showMapPicker();
      setState(() {});
    } else {
      log('no addressCtl');
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
                  mapPickerController: mapPickerController,
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

  // void showLocationPicker() {
  //   addressCtl.clear();
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PlacePicker(
  //         apiKey: Platform.isAndroid ? apiKey : "YOUR IOS API KEY",
  //         onPlacePicked: (result) {
  //           for (var p in result.addressComponents!) {
  //             addressCtl.text += '${p.longName}\n';
  //           }
  //           addressCtl.text =
  //               addressCtl.text.replaceAll(RegExp(r'\n\s*\n'), '\n').trim();
  //           log(addressCtl.text);

  //           currentLocation = LatLng(
  //               result.geometry!.location.lat, result.geometry!.location.lng);
  //           Navigator.of(context).pop();
  //         },
  //         initialPosition: latlng,
  //         useCurrentLocation: true,
  //         resizeToAvoidBottomInset:
  //             false, // only works in page mode, less flickery, remove if wrong offsets
  //       ),
  //     ),
  //   );
  // }
}
