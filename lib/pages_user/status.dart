import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

class Statuspage extends StatefulWidget {
  String docId = "";
  Statuspage({super.key, required this.docId});

  @override
  State<Statuspage> createState() => _StatuspageState();
}

class _StatuspageState extends State<Statuspage> {
  final box = GetStorage();
  PolylinePoints polylinePoints = PolylinePoints();
  String apiKey = "";
  bool isLoadingMap = true;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  var db = FirebaseFirestore.instance;
  late StreamSubscription listener;

  List<OrderRes> orders = [];

  List<Locations> origins = [];

  late LatLng destination;
  late LatLng userLocation;

  CameraPosition initPosition = const CameraPosition(
    target: LatLng(16.246671218679253, 103.25207957788868),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    readData();
    log(widget.docId);

    initPosition =
        CameraPosition(target: LatLng(box.read('curLat'), box.read('curLng')));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
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
                height: screenHeight * 1,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            if (isLoadingMap) const Center(child: CircularProgressIndicator()),
            Positioned(
              top: screenHeight * 0.3,
              left: (screenWidth * 0.5) - (screenWidth * 0.8 / 2),
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
                    }); // Fit all markers when the map is created
                  },
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.07,
                screenHeight * 0.58,
                screenWidth * 0.1,
                screenWidth * 0.1,
              ),
              child: const Text("สถานะการจัดส่ง",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.64, 0, 0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the buttons
                children: [
                  Container(
                    width: screenWidth * 0.12 + 10, // ขนาดของภาพ
                    height: screenWidth * 0.12 + 10,
                    decoration: const BoxDecoration(
                      color: Color(0xffbfbdbc), // สีพื้นหลังเป็นสีเทา
                      shape: BoxShape.circle, // รูปทรงเป็นวงกลม
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/Waiting_For_Parcel.png",
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // เส้นตรงเชื่อม
                  Container(
                    width: screenWidth * 0.09, // ความกว้างของเส้น
                    height: 4, // ความสูงของเส้น
                    color: const Color(0xffbfbdbc), // สีของเส้น
                  ),
                  Container(
                    width: screenWidth * 0.12 + 10,
                    height: screenWidth * 0.12 + 10,
                    decoration: const BoxDecoration(
                      color: Color(0xffbfbdbc),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/Rider_Picks_Up_Parcel.png",
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // เส้นตรงเชื่อม
                  Container(
                    width: screenWidth * 0.09, // ความกว้างของเส้น
                    height: 4, // ความสูงของเส้น
                    color: const Color(0xffbfbdbc), // สีของเส้น
                  ),
                  Container(
                    width: screenWidth * 0.12 + 10,
                    height: screenWidth * 0.12 + 10,
                    decoration: const BoxDecoration(
                      color: Color(0xffbfbdbc),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/Shipping_Goods.png",
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // เส้นตรงเชื่อม
                  Container(
                    width: screenWidth * 0.09, // ความกว้างของเส้น
                    height: 4, // ความสูงของเส้น
                    color: const Color(0xffbfbdbc), // สีของเส้น
                  ),
                  Container(
                    width: screenWidth * 0.12 + 10,
                    height: screenWidth * 0.12 + 10,
                    decoration: const BoxDecoration(
                      color: Color(0xffbfbdbc),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/Received_The_Product.png",
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.72, 0, 0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.08),
                    child: SizedBox(
                        width: screenWidth * 0.13,
                        child: const Text(
                          "รอไรเดอร์มารับสินค้า",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.1),
                    child: SizedBox(
                        width: screenWidth * 0.15,
                        child: const Text(
                          "ไรเดอร์รับสินค้า",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.09),
                    child: SizedBox(
                        width: screenWidth * 0.15,
                        child: const Text(
                          "กำลังจัดส่งสินค้า",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.09),
                    child: SizedBox(
                        width: screenWidth * 0.13,
                        child: const Text(
                          "ส่งสินค้าเสร็จสิ้น",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.79, 0, 0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the buttons
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                    child: SizedBox(
                      width: screenWidth * 0.25,
                      height: screenHeight * 0.06,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text(
                          "รอไรเดอร์มารับสินค้า",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                    child: SizedBox(
                      width: screenWidth * 0.25,
                      height: screenHeight * 0.06,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text(
                          "ไรเดอร์รับสินค้า",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                    child: SizedBox(
                      width: screenWidth * 0.25,
                      height: screenHeight * 0.06,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text(
                          "ส่งสินค้าเสร็จสิ้น",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, screenHeight * 0.9, 0, 0),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: Radius.circular(8), // มุมโค้ง
                    color: Colors.black,
                    strokeWidth: 5, // ปรับความหนาของเส้นประ
                    dashPattern: [20, 1], // ปรับความยาวและระยะห่างของเส้นประ
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(
                            10), // ปรับขนาด padding ตามต้องการ
                        child: Image.asset(
                          "assets/images/Logo_camera.png",
                          width: 30, // ปรับลดขนาดรูปภาพ
                          height: 30, // ปรับลดขนาดรูปภาพ
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  void readData() async {
    origins.clear();
    await initializeDateFormatting('th', null);
    var result = await db.collection('order').doc(widget.docId).get();

    orders = [OrderRes.fromFirestore(result.data()!, result.id)];

    orders.sort((a, b) => b.createAt.compareTo(a.createAt));

    destination = LatLng(orders[0].latReceiver!, orders[0].lngReceiver!);
    userLocation = LatLng(orders[0].latSender!, orders[0].lngSender!);
    for (var order in orders) {
      origins.add(Locations(
          location: LatLng(order.latRider!, order.lngRider!),
          status: order.status));
    }

    setupMarkers();
    setState(() {});
  }

  Future<void> setupMarkers() async {
    setState(() {
      isLoadingMap = true;
    });
    await getApiKey();
    _getMarkers();
    setState(() {
      isLoadingMap = false;
    });
  }

  Future<void> _getMarkers() async {
    setState(() {
      _markers.clear();
    });

    for (int index = 0; index < origins.length; index++) {
      Locations origin = origins[index];
      String url = '';
      log(origin.status);
      if (origin.status == '2') {
        url =
            "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.location.latitude},${origin.location.longitude}&destination=${userLocation.latitude},${userLocation.longitude}&mode=driving&key=$apiKey";
      } else if (origin.status == '3') {
        url =
            "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.location.latitude},${origin.location.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['routes'].isEmpty) {
          log("No routes found in the API response for origin: $origin");
          continue;
        }

        var leg = jsonResponse['routes'][0]['legs'][0];
        var distance = leg['distance']['text'];
        var duration = leg['duration']['text'];

        log("Distance from $origin to destination: $distance");
        log("Duration from $origin to destination: $duration");

        await _addOriginMarker(
            origin.location, distance, duration, 'Rider ${index + 1}');

        List<LatLng> polylineCoordinates = [];
        late PolylineRequest request;

        if (origin.status == '2') {
          request = PolylineRequest(
            origin: PointLatLng(
                origin.location.latitude, origin.location.longitude),
            destination:
                PointLatLng(userLocation.latitude, userLocation.longitude),
            mode: TravelMode.driving,
          );
        } else if (origin.status == '3') {
          request = PolylineRequest(
            origin: PointLatLng(
                origin.location.latitude, origin.location.longitude),
            destination:
                PointLatLng(destination.latitude, destination.longitude),
            mode: TravelMode.driving,
          );
        }

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: request,
          googleApiKey: apiKey,
        );

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }

          _polylines.add(Polyline(
            polylineId: PolylineId('route_$index'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ));
        } else {
          log('Failed to generate polyline for the rider to user location.');
        }
      } else {
        log("Failed to load directions for origin: $origin - ${response.reasonPhrase}");
      }
    }

    _addDestinationMarker();
    _addUserMarker();
    _fitAllMarkers();
  }

  void _addDestinationMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });
  }

  void _addUserMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('user'),
        position: userLocation,
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }

  Future<void> _addOriginMarker(LatLng origin, String distance, String duration,
      String riderLabel) async {
    BitmapDescriptor riderIcon = await _loadRiderIcon();

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('origin_${origin.latitude}_${origin.longitude}'),
        position: origin,
        icon: riderIcon,
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

      await mapController
          .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  Future<BitmapDescriptor> _loadRiderIcon() async {
    final ByteData data = await rootBundle.load('assets/images/rider.png');
    final Uint8List bytes = data.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
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
