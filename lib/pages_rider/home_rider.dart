import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:hermes_app/pages_user/edit_profile_user.dart';
import 'package:hermes_app/pages_user/status.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeRiderpage extends StatefulWidget {
  const HomeRiderpage({super.key});

  @override
  State<HomeRiderpage> createState() => _HomeRiderpageState();
}

class _HomeRiderpageState extends State<HomeRiderpage> {
  double screenWidth = 0;
  double screenHeight = 0;

  final box = GetStorage();

  var db = FirebaseFirestore.instance;
  late StreamSubscription listener;

  List<OrderRes> ordersReceive = [];

  bool isLoadingMap = true;
  late CameraPosition initPosition;

  Set<Marker> _markers = {};
  late GoogleMapController mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startRealtimeGet();

    initPosition = CameraPosition(
      target: LatLng(box.read('curLat'), box.read('curLng')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      onPopInvoked: (didpop) async {
        listener.cancel();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
              child: SizedBox(
                width: screenWidth,
                height: screenHeight * 0.73,
                child: ListView.builder(
                  itemCount: ordersReceive.length,
                  itemBuilder: (context, index) {
                    final item = ordersReceive[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: () => tapOnOrderCard(item),
                        child: Card(
                          color: const Color(0xFFE8E8E8),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'รับได้',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightGreen),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'สินค้า : ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        item.item ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'ผู้ส่ง : ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        item.senderName ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 50),
                                      const Text(
                                        'ผู้รับ : ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        item.receiverName ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text(
                                    item.createAt.toString() ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFBFBDBC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void tapOnOrderCard(OrderRes item) {
    // Get.to(() => const Statuspage());
    double distance = Geolocator.distanceBetween(item.latSender!,
            item.lngSender!, item.latReceiver!, item.lngReceiver!) /
        1000;

    _markers.clear();

    _markers.add(Marker(
      markerId: MarkerId(item.senderName ?? 'Sender'),
      position: LatLng(item.latSender!, item.lngSender!),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue), // Change color here
      infoWindow:
          InfoWindow(title: item.senderName, snippet: 'Sender Location'),
    ));

    _markers.add(Marker(
      markerId: MarkerId(item.receiverName ?? 'Receiver'),
      position: LatLng(item.latReceiver!, item.lngReceiver!),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen), // Change color here
      infoWindow:
          InfoWindow(title: item.receiverName, snippet: 'Receiver Location'),
    ));

    showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          height: screenHeight * 0.1,
          child: AlertDialog(
            title: const Center(child: Text('Order Details')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: screenWidth,
                  height: screenHeight * 0.3,
                  child: SizedBox(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: initPosition,
                      myLocationEnabled: false,
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        _fitAllMarkers(); // Fit all markers when the map is created
                      },
                      zoomGesturesEnabled: true, // Disable zoom gestures
                      scrollGesturesEnabled: true,
                      zoomControlsEnabled: false, // Disable zoom controls
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Distance: ${distance.toStringAsFixed(2)} KM',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ผู้ส่ง: ${item.senderName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text('ผู้รับ: ${item.receiverName}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Closes the dialog
                    },
                    child: const Text('กลับ'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Closes the dialog
                    },
                    child: const Text('รับงาน'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void readData() async {
    await initializeDateFormatting('th', null);
    var result =
        await db.collection('order').where('status', isEqualTo: 1).get();
    // log(result.docs.length.toString());

    ordersReceive = result.docs.map((doc) {
      return OrderRes.fromFirestore(doc.data(), doc.id);
    }).toList();

    // Sort by time latest first
    ordersReceive.sort((a, b) => b.createAt.compareTo(a.createAt));

    // for (OrderRes order in ordersReceive) {
    //   log('Item: ${order.item}');
    //   log('Sender UID: ${order.senderId}');
    //   log('Receiver UID: ${order.receiverUid}');
    //   log('Detail: ${order.detail}');
    //   log('Picture URL: ${order.picture}');
    //   log('Status: ${order.status}');
    //   log('Rider: ${order.riderUid}');
    //   log('Formatted Date: ${order.formattedDate}');
    //   log('Document ID: ${order.documentId}');
    // }

    setState(() {});
  }

  void startRealtimeGet() {
    final docRef = db.collection("order");
    docRef.snapshots().listen((event) {
      setState(() {
        readData();
      });
    }, onError: (error) => log("Listen failed"));
  }

  Future<void> _fitAllMarkers() async {
    if (_markers.isNotEmpty) {
      // Initialize min and max lat/lng for the bounds calculation
      double minLat = _markers.first.position.latitude;
      double minLng = _markers.first.position.longitude;
      double maxLat = _markers.first.position.latitude;
      double maxLng = _markers.first.position.longitude;

      // Loop through all markers to find the bounds
      for (var marker in _markers) {
        minLat = min(minLat, marker.position.latitude);
        minLng = min(minLng, marker.position.longitude);
        maxLat = max(maxLat, marker.position.latitude);
        maxLng = max(maxLng, marker.position.longitude);
      }

      // Create the bounds based on the calculated min/max latitude and longitude
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      // Animate the camera to fit all markers with adjusted padding
      await mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // Use padding as needed
      );
    }
  }
}
