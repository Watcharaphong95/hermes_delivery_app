import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:hermes_app/pages_rider/status_rider.dart';
import 'package:hermes_app/pages_user/edit_profile_user.dart';
import 'package:hermes_app/pages_user/status.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

class HomeRiderpage extends StatefulWidget {
  const HomeRiderpage({super.key});

  @override
  State<HomeRiderpage> createState() => _HomeRiderpageState();
}

class _HomeRiderpageState extends State<HomeRiderpage> {
  String apiKey = '';
  double screenWidth = 0;
  double screenHeight = 0;

  final box = GetStorage();
  PolylinePoints polylinePoints = PolylinePoints();

  var db = FirebaseFirestore.instance;
  late StreamSubscription listener;

  List<OrderRes> ordersReceive = [];

  late CameraPosition initPosition;

  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Marker> _marker = {};
  late GoogleMapController mapController;

  late Stream<Position> currentPosition;
  late LatLng currentLatLng;

  @override
  void initState() {
    super.initState();
    getApiKey();
    startRealtimeGet();
    startLocationUpdates();
    currentLatLng = LatLng(box.read('curLat'), box.read('curLng'));
    initPosition = CameraPosition(
      target: LatLng(box.read('curLat'), box.read('curLng')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: ordersReceive.isNotEmpty
                  ? SizedBox(
                      width: screenWidth,
                      height: screenHeight * 0.72,
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
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 0, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          "กรุณาค้นหาเบอร์\nผู้รับสินค้า",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            color: Color(0xFFBFBDBC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> tapOnOrderCard(OrderRes item) async {
    _marker.clear;
    _polylines.clear;
    _addMarkerReceiver(item);
    _addMarkerRider();
    _addMarkerSender(item);

    double distanceToSender = Geolocator.distanceBetween(currentLatLng.latitude,
            currentLatLng.longitude, item.latSender!, item.lngSender!) /
        1000;

    double distanceToReceiver = Geolocator.distanceBetween(item.latSender!,
            item.lngSender!, item.latReceiver!, item.lngReceiver!) /
        1000;

    log(distanceToReceiver.toString());
    log(distanceToSender.toString());
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
                      polylines: _polylines,
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _fitAllMarkers();
                        }); // Fit all markers when the map is created
                      },
                      zoomGesturesEnabled: true, // Disable zoom gestures
                      scrollGesturesEnabled: true,
                      zoomControlsEnabled: true, // Disable zoom controls
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'ระยะทางถึงผู้ส่ง: ${distanceToSender.toStringAsFixed(2)} กม',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'ระยะทางถึงผู้รับ: ${distanceToReceiver.toStringAsFixed(2)} กม',
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
                      Get.back(); // Closes the dialog
                    },
                    child: const Text('กลับ'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await db.collection('order').doc(item.documentId).update({
                        'riderRid': box.read('uid'),
                        'latRider': box.read('curLat'),
                        'lngRider': box.read('curLng'),
                        'status': 2
                      });

                      Get.to(() => StatusRider(docId: item.documentId));
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

  Future<void> getApiKey() async {
    await Configuration.getConfig().then((config) {
      setState(() {
        apiKey = config['apiKey'];
      });
    });
  }

  void readData() async {
    await initializeDateFormatting('th', null);

    var check = await db
        .collection("order")
        .where('riderRid', isEqualTo: box.read('uid'))
        .get();
    if (check.docs.isNotEmpty) {
      ordersReceive = check.docs.map((doc) {
        return OrderRes.fromFirestore(doc.data(), doc.id);
      }).toList();
      Get.to(() => StatusRider(docId: ordersReceive[0].documentId));
    }

    var result =
        await db.collection('order').where('status', isEqualTo: 1).get();
    // log(result.docs.length.toString());

    ordersReceive = result.docs.map((doc) {
      return OrderRes.fromFirestore(doc.data(), doc.id);
    }).toList();

    // Sort by time latest first
    ordersReceive.sort((a, b) => b.createAt.compareTo(a.createAt));

    setState(() {});
  }

  void _addMarkerRider() {
    _markers.add(Marker(
      markerId: const MarkerId('You'),
      position: LatLng(currentLatLng.latitude, currentLatLng.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed), // Change color here
      infoWindow: const InfoWindow(title: 'You', snippet: 'ตำแหน่งของคุณ'),
    ));
  }

  void _addMarkerSender(OrderRes item) {
    _markers.add(Marker(
      markerId: MarkerId(item.senderName ?? 'Sender'),
      position: LatLng(item.latSender!, item.lngSender!),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue), // Change color here
      infoWindow: InfoWindow(title: item.senderName, snippet: 'ตำแหน่งผู้ส่ง'),
    ));
  }

  void _addMarkerReceiver(OrderRes item) {
    _markers.add(Marker(
      markerId: MarkerId(item.receiverName ?? 'Receiver'),
      position: LatLng(item.latReceiver!, item.lngReceiver!),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen), // Change color here
      infoWindow:
          InfoWindow(title: item.receiverName, snippet: 'ตำแหน่งผู้รับ'),
    ));
  }

  void startCheckOrder() {
    final docRef =
        db.collection("order").where('riderRid', isEqualTo: box.read('uid'));
    docRef.snapshots().listen((event) {
      setState(() {
        readData();
      });
    }, onError: (error) => log("Listen failed"));
  }

  Future<void> startRealtimeGet() async {
    final docRef = db.collection("order");
    docRef.snapshots().listen((event) {
      setState(() {
        readData();
      });
    }, onError: (error) => log("Listen failed"));
  }

  void startLocationUpdates() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    currentPosition =
        Geolocator.getPositionStream(locationSettings: locationSettings);
    currentPosition.listen((Position position) async {
      currentLatLng = LatLng(position.latitude, position.longitude);
      log('Current Location: $currentLatLng');
    });
    setState(() {});
  }

  Future<void> _fitAllMarkers() async {
    // Check if the map controller is initialized
    if (mapController == null) {
      print("Map controller is not initialized.");
      return;
    }

    if (_markers.isNotEmpty) {
      LatLngBounds bounds;

      if (_markers.length == 1) {
        bounds = LatLngBounds(
          southwest: _markers.first.position,
          northeast: _markers.first.position,
        );
      } else {
        double minLat = _markers.first.position.latitude;
        double minLng = _markers.first.position.longitude;
        double maxLat = _markers.first.position.latitude;
        double maxLng = _markers.first.position.longitude;

        for (var marker in _markers) {
          minLat = min(minLat, marker.position.latitude);
          minLng = min(minLng, marker.position.longitude);
          maxLat = max(maxLat, marker.position.latitude);
          maxLng = max(maxLng, marker.position.longitude);
        }

        bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );
      }

      try {
        await mapController.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 50)); // Increase padding
      } catch (e) {
        print('Error animating camera: $e');
      }
    } else {
      print('No markers to fit.');
    }
  }
}
