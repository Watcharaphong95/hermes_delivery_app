import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AllStatus extends StatefulWidget {
  bool isReceive;
  AllStatus({super.key, required this.isReceive});

  @override
  State<AllStatus> createState() => _AllStatusState();
}

class _AllStatusState extends State<AllStatus> {
  String apiKey = '';
  PolylinePoints polylinePoints = PolylinePoints();
  final box = GetStorage();
  var db = FirebaseFirestore.instance;
  late StreamSubscription listener;
  StreamSubscription<QuerySnapshot>? _subscription;

  late GoogleMapController mapController;

  CameraPosition initPosition = const CameraPosition(
    target: LatLng(16.246671218679253, 103.25207957788868),
    zoom: 15,
  );

  List<OrderRes> orders = [];
  final Set<Marker> _markers = {};
  late LatLng userLocation;
  List<Locations> riders = [];
  final List<LatLng> targets = [];

  final Set<Polyline> _polylines = {};
  List<Color> _markerColors = [];

  @override
  void initState() {
    startRealtimeGet();
    getApiKey();
    initPosition = CameraPosition(
        target: LatLng(box.read('curLat'), box.read('curLng')), zoom: 15);
    _prepareMark();
    super.initState();
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      onPopInvoked: (didPop) async {
        listener.cancel();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.35,
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
                      Center(
                        child: Image.asset(
                          'assets/images/Logo_status.png',
                          width: screenWidth * 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.045,
                screenHeight * 0.28,
                screenWidth * 0.045,
                0,
              ),
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.7,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            // if (isLoadingMap) const Center(child: CircularProgressIndicator()),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.1,
                screenHeight * 0.3,
                screenWidth * 0.1,
                0,
              ),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.25,
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
                    });
                  },
                  zoomGesturesEnabled: true,
                  // scrollGesturesEnabled: false,
                  // zoomControlsEnabled: false,
                  // myLocationButtonEnabled: false,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  screenWidth * 0.1, screenHeight * 0.57, 0, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "สถานะการจัดส่ง",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.35,
                      child: _markers.isNotEmpty // เช็คว่า _markers ไม่ว่าง
                          ? ListView.builder(
                              itemCount: _markers.length,
                              itemBuilder: (context, index) {
                                var markersList = _markers.toList();
                                var marker = markersList[index];

                                // แสดงค่าของ title เพื่อการดีบัก
                                print(
                                    'Marker title: ${marker.infoWindow.title}');

                                // กำหนดสีตามประเภทของ Marker
                                Color color;
                                if (marker.infoWindow.title!
                                    .startsWith('Rider')) {
                                  color = _getUniqueColor(
                                      index); // ใช้สีที่แตกต่างกันสำหรับ Rider
                                } else if (marker.infoWindow.title == 'You') {
                                  color =
                                      Colors.green; // ใช้สีเขียวสำหรับผู้ใช้
                                } else if (marker.infoWindow.title!
                                    .startsWith('Target')) {
                                  color =
                                      Colors.blue; // ใช้สีน้ำเงินสำหรับ Target
                                } else {
                                  color =
                                      Colors.grey; // ไอคอนสีเทาสำหรับกรณีอื่น ๆ
                                }

                                // สร้าง customMarker ด้วยสีที่กำหนด
                                Icon customMarker;
                                if (marker.infoWindow.title!
                                    .startsWith('Rider')) {
                                  customMarker = Icon(Icons.motorcycle,
                                      color: color, size: 24);
                                } else if (marker.infoWindow.title == 'You') {
                                  customMarker = Icon(Icons.person,
                                      color: color, size: 24);
                                } else if (marker.infoWindow.title!
                                    .startsWith('Target')) {
                                  customMarker = Icon(Icons.pin_drop,
                                      color: color, size: 24);
                                } else {
                                  customMarker =
                                      Icon(Icons.help, color: color, size: 24);
                                }

                                return Card(
                                  child: ListTile(
                                    leading: customMarker,
                                    title: Text(
                                        marker.infoWindow.title ?? 'Unknown'),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                  'ไม่พบข้อมูล')), // แสดงข้อความถ้าไม่มีข้อมูล
                    )
                  ],
                ),
              ),
            ),

            Positioned(
              top: screenHeight * 0.3,
              right: screenWidth * 0.1,
              child: FloatingActionButton.small(
                onPressed: () async {
                  // Move the map camera to the user's location
                  mapController.animateCamera(
                    CameraUpdate.newLatLng(
                        LatLng(userLocation.latitude, userLocation.longitude)),
                  );
                },
                child: const Icon(Icons.my_location),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> getApiKey() async {
    await Configuration.getConfig().then((config) {
      setState(() {
        apiKey = config['apiKey'];
      });
    });
  }

  _prepareMark() async {
    orders.clear();
    riders.clear();
    targets.clear();
    if (widget.isReceive) {
      await readDataReciever();
    } else {
      await readDataSender();
    }
    _markers.clear();
    Future.delayed(const Duration(milliseconds: 200), () {
      _getMarkersRider();
    });
  }

  Future<void> readDataReciever() async {
    orders.clear();
    riders.clear();
    targets.clear();
    await initializeDateFormatting('th', null);
    var result = await db
        .collection('order')
        .where('receiverUid', isEqualTo: box.read('uid'))
        .where('status', whereIn: [2, 3]).get();

    if (result.docs.isNotEmpty) {
      orders = result.docs.map((doc) {
        return OrderRes.fromFirestore(doc.data(), doc.id);
      }).toList();
    } else {
      log('length = 0');
      return;
    }
    riders.clear();
    targets.clear();
    for (var order in orders) {
      if (order.latRider != null && order.lngRider != null) {
        riders.add(Locations(
            location: LatLng(order.latRider!, order.lngRider!),
            status: order.status));
      }
      if (order.latSender != null && order.lngSender != null) {
        targets.add(LatLng(order.latSender!, order.lngSender!));
      }
    }

    userLocation = LatLng(orders[0].latReceiver!, orders[0].lngReceiver!);
  }

  Future<void> readDataSender() async {
    orders.clear();
    riders.clear();
    targets.clear();
    await initializeDateFormatting('th', null);
    var result = await db
        .collection('order')
        .where('senderUid', isEqualTo: box.read('uid'))
        .where('status', whereIn: [2, 3]).get();
    log("result ${result.docs.length}");
    if (result.docs.isNotEmpty) {
      orders = result.docs.map((doc) {
        return OrderRes.fromFirestore(doc.data(), doc.id);
      }).toList();
      // log(orders.length.toString());
    } else {
      return;
    }
    riders.clear();
    targets.clear();
    for (var order in orders) {
      if (order.latRider != null && order.lngRider != null) {
        riders.add(Locations(
            location: LatLng(order.latRider!, order.lngRider!),
            status: order.status));
      }
      if (order.latReceiver != null && order.lngReceiver != null) {
        targets.add(LatLng(order.latReceiver!, order.lngReceiver!));
      }
    }
    // log('rider length${riders.length}');
    userLocation = LatLng(orders[0].latSender!, orders[0].lngSender!);
  }

  Future<void> _getMarkersRider() async {
    log('this is marker ${_markers.toString()}');
    setState(() {
      _markers.clear();
      _polylines.clear();
    });

    for (int index = 0; index < riders.length; index++) {
      Color color = _getUniqueColor(index);
      Locations rider = riders[index];
      LatLng target = targets[index];
      LatLng user = userLocation;
      String url = '';
      // log(rider.status);
      if (rider.status == '2') {
        url =
            "https://maps.googleapis.com/maps/api/directions/json?origin=${rider.location.latitude},${rider.location.longitude}&destination=${user.latitude},${user.longitude}&mode=driving&key=$apiKey";
      } else if (rider.status == '3') {
        url =
            "https://maps.googleapis.com/maps/api/directions/json?origin=${rider.location.latitude},${rider.location.longitude}&destination=${target.latitude},${target.longitude}&mode=driving&key=$apiKey";
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['routes'].isEmpty) {
          log("No routes found in the API response for origin: $rider");
          continue;
        }

        var leg = jsonResponse['routes'][0]['legs'][0];
        var distance = leg['distance']['text'];
        var duration = leg['duration']['text'];

        log("Distance from $rider to destination: $distance");
        log("Duration from $rider to destination: $duration");

        await _addRiderMarker(
            rider.location, distance, duration, 'Rider ${index + 1}', color);

        await _addTargetMarker(
            target, distance, duration, 'Target ${index + 1}', color);
        // if (rider.status == '3') {}

        List<LatLng> polylineCoordinates = [];
        late PolylineRequest request;
        if (widget.isReceive) {
          if (rider.status == '2') {
            request = PolylineRequest(
              origin: PointLatLng(
                  rider.location.latitude, rider.location.longitude),
              destination: PointLatLng(target.latitude, target.longitude),
              mode: TravelMode.driving,
            );
          } else if (rider.status == '3') {
            request = PolylineRequest(
              origin: PointLatLng(
                  rider.location.latitude, rider.location.longitude),
              destination:
                  PointLatLng(userLocation.latitude, userLocation.longitude),
              mode: TravelMode.driving,
            );
          }
        } else {
          if (rider.status == '2') {
            request = PolylineRequest(
              origin: PointLatLng(
                  rider.location.latitude, rider.location.longitude),
              destination:
                  PointLatLng(userLocation.latitude, userLocation.longitude),
              mode: TravelMode.driving,
            );
          } else if (rider.status == '3') {
            request = PolylineRequest(
              origin: PointLatLng(
                  rider.location.latitude, rider.location.longitude),
              destination: PointLatLng(target.latitude, target.longitude),
              mode: TravelMode.driving,
            );
          }
        }

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: request,
          googleApiKey: apiKey,
        );

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }

          // if (rider.status == '2') {
          //   color = Colors.blue;
          // } else {
          //   color = Colors.green;
          // }

          _polylines.add(Polyline(
            polylineId: PolylineId('route_$index'),
            points: polylineCoordinates,
            color: color,
            width: 5,
          ));
        } else {
          log('Failed to generate polyline for the rider to user location.');
        }
      } else {
        log("Failed to load directions for origin: $rider - ${response.reasonPhrase}");
      }
      _addUserLocationMarker();
      _fitAllMarkers();
    }
  }

  Future<void> _addRiderMarker(LatLng rider, String distance, String duration,
      String riderLabel, Color color) async {
    double hueValue = HSVColor.fromColor(color).hue;

    BitmapDescriptor customMarker =
        BitmapDescriptor.defaultMarkerWithHue(hueValue);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('rider_${rider.latitude}_${rider.longitude}'),
        position: rider,
        infoWindow: InfoWindow(
            title: riderLabel, snippet: 'ระยะทาง $distance เวลา ~$duration'),
        icon: customMarker,
      ));
    });
  }

  Future<void> _addTargetMarker(LatLng target, String distance, String duration,
      String targetLabel, Color color) async {
    double hueValue = HSVColor.fromColor(color).hue;

    BitmapDescriptor customMarker =
        BitmapDescriptor.defaultMarkerWithHue(hueValue);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('target_${target.latitude}_${target.longitude}'),
        position: target,
        infoWindow: InfoWindow(title: targetLabel),
        icon: customMarker,
      ));
    });
  }

  void _addUserLocationMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('userLocation'),
        position: userLocation,
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }

  Future<void> _fitAllMarkers() async {
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
          minLat = math.min(minLat, marker.position.latitude);
          minLng = math.min(minLng, marker.position.longitude);
          maxLat = math.max(maxLat, marker.position.latitude);
          maxLng = math.max(maxLng, marker.position.longitude);
        }

        bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );
      }

      await mapController
          .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  void startRealtimeGet() {
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
    final docRef =
        db.collection('order').where('senderUid', isEqualTo: box.read('uid'));

    docRef.snapshots().listen((event) {
      if (!mounted) return;
      setState(() {});
      _prepareMark();
    }, onError: (error) => log("Listen failed"));
  }

  Color _getUniqueColor(int index) {
    // Create unique colors based on the index using HSV
    double hue = (index * 40) % 360; // Rotating hue around the color wheel
    return HSVColor.fromAHSV(1.0, hue, 0.9, 0.9)
        .toColor(); // Full saturation and brightness
  }
}

class Locations {
  final LatLng location;
  final String status;

  Locations({
    required this.location,
    required this.status,
  });
}
