import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:hermes_app/models/response/user_search_res.dart';
import 'package:hermes_app/navbar/navbottomRider.dart';
import 'package:hermes_app/pages_rider/home_rider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';

class StatusRider extends StatefulWidget {
  String docId = "";
  StatusRider({super.key, required this.docId});

  @override
  State<StatusRider> createState() => _StatuspageState();
}

class _StatuspageState extends State<StatusRider> {
  final box = GetStorage();
  PolylinePoints polylinePoints = PolylinePoints();
  String apiKey = "";
  String url = "";
  List<PhoneSearchRes> senderData = [];
  List<PhoneSearchRes> receiverData = [];
  bool isLoadingMap = true;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  var db = FirebaseFirestore.instance;
  late StreamSubscription? listener;
  StreamSubscription<Position>? locationSubscription;

  List<OrderRes> orders = [];

  List<LatLng> riders = [];

  late LatLng destination;
  late LatLng pickup;

  String pictureUrl = '';
  final ImagePicker picker = ImagePicker();
  XFile? image;

  double minDistance = 0;
  String distance = '';
  String duration = '';
  bool distanceAccpet = false;

  CameraPosition initPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 15,
  );

  int _activeButtonIndex = 2;

  double screenWidth = 0;
  double screenHeight = 0;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2));
    super.initState();
    readData();
    startLocationUpdates();
    startRealtimeGet();
    log(widget.docId);
  }

  @override
  void dispose() {
    listener?.cancel(); // Cancel Firestore listener
    locationSubscription?.cancel(); // Cancel location updates
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
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
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                        child: Center(
                          child: Image.asset(
                            'assets/images/Logo_status.png',
                            width: screenWidth * 0.7,
                          ),
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
                height: screenHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
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
                  scrollGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, screenHeight * 0.56, 0, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.1,
                        0,
                        screenWidth * 0.1,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('สถานะการจัดส่ง',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                          Row(
                            children: [
                              distance != null
                                  ? Text(distance.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ))
                                  : const CircularProgressIndicator(),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              duration != null
                                  ? Text(duration.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ))
                                  : const CircularProgressIndicator(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.1,
                        0,
                        screenWidth * 0.1,
                        0,
                      ),
                      child: orders.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatusStep('ไรเดอร์\nรับงาน', Icons.inbox,
                                    int.parse(orders[0].status) >= 1),
                                _buildConnectorLine(
                                    int.parse(orders[0].status) >= 2),
                                _buildStatusStep(
                                    'รอไรเดอร์\nมารับสินค้า',
                                    Icons.directions_bike,
                                    int.parse(orders[0].status) >= 2),
                                _buildConnectorLine(
                                    int.parse(orders[0].status) >= 3),
                                _buildStatusStep(
                                    'รับสินค้าแล้ว\nกำลังเดินทาง',
                                    Icons.local_shipping,
                                    int.parse(orders[0].status) >= 3),
                                _buildConnectorLine(
                                    int.parse(orders[0].status) >= 4),
                                _buildStatusStep(
                                    'ส่งสินค้า\nเสร็จสิ้น',
                                    Icons.done_all,
                                    int.parse(orders[0].status) >= 4),
                              ],
                            )
                          : Container(),
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(
                            0, screenHeight * 0.01, 0, screenHeight * 0.01),
                        child: orders.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStatusButton(
                                      2,
                                      'รอไรเดอร์\nมารับสินค้า',
                                      int.parse(orders[0].status) >= 1),
                                  const SizedBox(width: 8),
                                  _buildStatusButton(
                                      3,
                                      'ไรเดอร์รับ\nสินค้า',
                                      int.parse(orders[0].status) >= 2 &&
                                              minDistance < 20 ||
                                          orders[0].picture_2 != ''),
                                  const SizedBox(width: 8),
                                  _buildStatusButton(
                                      4,
                                      'ส่งสินค้า\nเสร็จสิ้น',
                                      int.parse(orders[0].status) >= 3 &&
                                              minDistance < 20 ||
                                          orders[0].picture_3 != ''),
                                ],
                              )
                            : Container()),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.1,
                        0,
                        screenWidth * 0.1,
                        0,
                      ),
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.3,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: InkWell(
                          onTap: orders.isNotEmpty &&
                                  ((_activeButtonIndex == 2 &&
                                          orders[0].picture.isEmpty) ||
                                      (_activeButtonIndex == 3 &&
                                          orders[0].picture_2.isEmpty) ||
                                      (_activeButtonIndex == 4 &&
                                          orders[0].picture_3.isEmpty))
                              ? imagePicker
                              : null,
                          child: Center(
                            // Center the image within the container
                            child: (_activeButtonIndex == 2)
                                ? showImagePerStaus(screenWidth, screenHeight,
                                    _activeButtonIndex)
                                : (_activeButtonIndex == 3)
                                    ? showImagePerStaus(screenWidth,
                                        screenHeight, _activeButtonIndex)
                                    : (_activeButtonIndex == 4)
                                        ? showImagePerStaus(screenWidth,
                                            screenHeight, _activeButtonIndex)
                                        : noImagePerStatus(
                                            screenWidth, screenHeight),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      child: SizedBox(
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.06,
                        child: FilledButton(
                          onPressed: image != null ? addPicturePerStatus : null,
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: const Text('ยืนยันรูป'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          0, screenHeight * 0.005, 0, screenHeight * 0.03),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(screenWidth * 0.1, 0, 0, 0),
                            child: const Row(
                              children: [
                                Text(
                                  'รายละเอียดออเดอร์',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Colors.lightBlue[100], // Background color
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26, // Shadow color
                                    offset: Offset(0, 4), // Shadow offset
                                    blurRadius: 8, // Shadow blur
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(
                                  16.0), // Internal padding
                              child: senderData.isNotEmpty
                                  ? Text(
                                      'ผู้ส่ง\n'
                                      'ชื่อ: ${senderData[0].name}\n'
                                      'ที่อยู่: ${senderData[0].address}\n'
                                      'เบอร์โทร: ${senderData[0].phone}',
                                      style: const TextStyle(fontSize: 18),
                                    )
                                  : const Text(''),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.005,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Colors.lightGreen[100], // Background color
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26, // Shadow color
                                    offset: Offset(0, 4), // Shadow offset
                                    blurRadius: 8, // Shadow blur
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(
                                  16.0), // Internal padding
                              child: receiverData.isNotEmpty
                                  ? Text(
                                      'ผู้รับ\n'
                                      'ชื่อ: ${receiverData[0].name}\n'
                                      'ที่อยู่: ${receiverData[0].address}\n'
                                      'เบอร์โทร: ${receiverData[0].phone}',
                                      style: const TextStyle(fontSize: 18),
                                    )
                                  : const Text(''),
                            ),
                          )
                        ],
                      ),
                    ),
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
                        LatLng(riders[0].latitude, riders[0].longitude)),
                  );
                },
                child: const Icon(Icons.my_location),
              ),
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
    await Configuration.getConfig().then((config) {
      url = config['apiEndPoint'];
    });
  }

  Future<void> getUserSender() async {
    var res = await http.get(Uri.parse('$url/user/${orders[0].senderUid}'));
    senderData = phoneSearchResFromJson(res.body);
    log(senderData[0].name);
    setState(() {});
  }

  Future<void> getUserReceiver() async {
    var res = await http.get(Uri.parse('$url/user/${orders[0].receiverUid}'));
    receiverData = phoneSearchResFromJson(res.body);
    log(receiverData[0].name);
    setState(() {});
  }

  void readData() async {
    riders.clear();
    await initializeDateFormatting('th', null);
    var result = await db.collection('order').doc(widget.docId).get();

    orders = [OrderRes.fromFirestore(result.data()!, result.id)];

    log('orders ${orders[0].status}');
    if (int.parse(orders[0].status) > 3) {
      Get.to(() =>
          NavbottompageRider(selectedPages: 0, phoneNumber: box.read('phone')));
    }

    orders.sort((a, b) => b.createAt.compareTo(a.createAt));

    pickup = LatLng(orders[0].latSender!, orders[0].lngSender!);
    destination = LatLng(orders[0].latReceiver!, orders[0].lngReceiver!);

    _activeButtonIndex = int.parse(orders[0].status);

    for (var order in orders) {
      riders.add(LatLng(order.latRider!, order.lngRider!));
    }
    setupMarkers();
    if (senderData.isEmpty) {
      await getUserSender();
    }
    if (receiverData.isEmpty) {
      await getUserReceiver();
    }
    setState(() {});
  }

  Future<void> setupMarkers() async {
    setState(() {
      isLoadingMap = true;
    });
    await getApiKey();
    await _getMarkers();
    setState(() {
      isLoadingMap = false;
    });
  }

  Future<void> _getMarkers() async {
    // log(riders.length.toString());
    setState(() {
      _markers.clear();
      _polylines.clear();
    });

    for (int index = 0; index < riders.length; index++) {
      LatLng rider = riders[index];
      String url = '';
      if (orders[0].status == '2') {
        url =
            "https://maps.googleapis.com/maps/api/directions/json?origin=${rider.latitude},${rider.longitude}&destination=${pickup.latitude},${pickup.longitude}&mode=driving&key=$apiKey";
      } else if (orders[0].status == '3') {
        url =
            "https://maps.googleapis.com/maps/api/directions/json?origin=${rider.latitude},${rider.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['routes'].isEmpty) {
          log("No routes found in the API response for origin: $rider");
          continue;
        }

        var leg = jsonResponse['routes'][0]['legs'][0];
        distance = leg['distance']['text'];
        duration = leg['duration']['text'];

        log("Distance from $rider to destination: $distance");
        log("Duration from $rider to destination: $duration");

        if (orders[0].status == '2') {
          _addDestinationMarker('ยังไม่รับของจากผู้ส่ง', '');
        } else {
          _addDestinationMarker(distance, duration);
        }

        _addPickUpMarker(distance, duration);

        await _addRiderMarker(rider);

        List<LatLng> polylineCoordinates = [];
        late PolylineRequest request;
        if (orders[0].status == '2') {
          request = PolylineRequest(
            origin: PointLatLng(rider.latitude, rider.longitude),
            destination: PointLatLng(pickup.latitude, pickup.longitude),
            mode: TravelMode.driving,
          );
        } else if (orders[0].status == '3') {
          request = PolylineRequest(
            origin: PointLatLng(rider.latitude, rider.longitude),
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

          Color color;
          if (orders[0].status == '2') {
            color = Colors.blue;
          } else {
            color = Colors.green;
          }

          _polylines.add(Polyline(
            polylineId: PolylineId('route_$index'),
            points: polylineCoordinates,
            color: color,
            width: 5,
          ));
        }
      } else {
        log("Failed to load directions for origin: $rider - ${response.reasonPhrase}");
      }
    }
    List<String> distanceParts = distance.split(' ');
    if (distance.toLowerCase().contains('km')) {
      minDistance = (double.parse(distanceParts[0]) * 1000);
    } else {
      minDistance = double.parse(distanceParts[0]); // Already in meters
    }
    log(minDistance.toString());
    _fitAllMarkers();
  }

  void _addDestinationMarker(String distance, String duration) {
    _markers.clear;
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow:
            InfoWindow(title: 'Destination', snippet: '$distance $duration'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });
  }

  void _addPickUpMarker(String distance, String duration) {
    _markers.clear;
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        infoWindow: InfoWindow(title: 'Pickup', snippet: '$distance $duration'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }

  Future<void> _addRiderMarker(LatLng rider) async {
    _markers.clear;
    BitmapDescriptor riderIcon = await _loadRiderIcon();

    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('you'),
        position: rider,
        infoWindow: const InfoWindow(
          title: 'You',
        ),
        icon: riderIcon,
      ));
    });
  }

  Future<void> _fitAllMarkers() async {
    // Check if the map controller is initialized
    if (mapController == null) {
      log("Map controller is not initialized.");
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
        log('Error animating camera: $e');
      }
    } else {
      log('No markers to fit.');
    }
  }

  Future<BitmapDescriptor> _loadRiderIcon() async {
    final ByteData data = await rootBundle.load('assets/images/rider.png');
    final Uint8List bytes = data.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }

  void startLocationUpdates() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    locationSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) async {
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      await db.collection('order').doc(widget.docId).update({
        'latRider': position.latitude,
        'lngRider': position.longitude,
      });
      log('Current Location: $currentLocation');
    });
    if (mounted) {
      setState(() {});
    }
  }

  void startRealtimeGet() {
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
    final docRef = db.collection("order").doc(widget.docId);
    docRef.snapshots().listen((event) {
      setState(() {
        readData();
      });
    }, onError: (error) => log("Listen failed"));
  }

  Widget _buildStatusStep(String label, IconData icon, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: isActive ? Colors.orange : Colors.grey,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine(bool isActive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 35),
        child: Container(
          height: 2,
          color: isActive ? Colors.orange : Colors.black,
        ),
      ),
    );
  }

  Widget _buildStatusButton(int index, String text, bool disable) {
    bool isActive = _activeButtonIndex == index;
    return ElevatedButton(
      onPressed: !disable
          ? null
          : () {
              setState(() {
                _activeButtonIndex = index; // Update the active button index
              });
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: !disable
            ? Colors.orange[200]
            : isActive
                ? Colors.orange
                : Colors.grey, // Change color based on active state
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        // padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: !disable
              ? Colors.black38
              : isActive
                  ? Colors.white
                  : Colors.black54, // Text color based on active state
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Image showImagePerStaus(double screenWidth, double screenHeight, int status) {
    if (orders.isNotEmpty) {
      if (orders[0].picture != '' && status == 2) {
        setState(() {});
        return Image.network(
          orders[0].picture, fit: BoxFit.contain,
          width: screenWidth *
              0.85, // Ensure the image doesn't overflow horizontally
          height: screenHeight * 0.3,
        );
      } else if (orders[0].picture_2 != '' && status == 3) {
        setState(() {});
        return Image.network(
          orders[0].picture_2, fit: BoxFit.contain,
          width: screenWidth *
              0.85, // Ensure the image doesn't overflow horizontally
          height: screenHeight * 0.3,
        );
      } else if (orders[0].picture_3 != '' && status == 4) {
        setState(() {});
        return Image.network(
          orders[0].picture_3, fit: BoxFit.contain,
          width: screenWidth *
              0.85, // Ensure the image doesn't overflow horizontally
          height: screenHeight * 0.3,
        );
      } else if (image != null) {
        return Image.file(
          File(image!.path),
          fit: BoxFit.contain,
          width: screenWidth *
              0.85, // Ensure the image doesn't overflow horizontally
          height: screenHeight *
              0.3, // Ensure the image doesn't overflow vertically
        );
      } else {
        return Image.asset(
          'assets/images/Logo_camera.png',
          fit: BoxFit.contain, // Make sure the SVG fits properly
          width: screenWidth * 0.85, // Same size for the SVG
          height: screenHeight * 0.2, // Adjust the height for SVG
        );
      }
    } else {
      return Image.asset(
        'assets/images/Logo_camera.png',
        fit: BoxFit.contain, // Make sure the SVG fits properly
        width: screenWidth * 0.85, // Same size for the SVG
        height: screenHeight * 0.2, // Adjust the height for SVG
      );
    }
  }

  Image noImagePerStatus(double screenWidth, double screenHeight) {
    return Image.asset(
      'assets/images/Logo_camera.png',
      fit: BoxFit.contain, // Make sure the SVG fits properly
      width: screenWidth * 0.85, // Same size for the SVG
      height: screenHeight * 0.2, // Adjust the height for SVG
    );
  }

  Future<void> imagePicker() async {
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

  Future<void> addPicturePerStatus() async {
    if (image == null) return;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('ยืนยันรูปนี้?')),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: const Text('ยกเลิก')),
                  FilledButton(
                      onPressed: () async {
                        await confirmImageStatus();
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: const Text('ตกลง')),
                ],
              )
            ],
          );
        });
  }

  Future<void> confirmImageStatus() async {
    setState(() {
      showLoadingDialog(context, true);
    });
    await imageUpload();
    var data;
    if (_activeButtonIndex == 3) {
      data = {'picture_2': pictureUrl, 'status': 3};
    } else if (_activeButtonIndex == 4) {
      data = {'picture_3': pictureUrl, 'status': 4};
    }

    await db.collection('order').doc(widget.docId).update(data);

    image = null;

    if (_activeButtonIndex == 3) {
      _activeButtonIndex == 4;
    }

    await Future.delayed(const Duration(seconds: 4));
  }

  void showLoadingDialog(BuildContext context, bool isLoading) {
    if (!isLoading) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 10,
                    ),
                  ),
                  SizedBox(height: 20), // Space between the indicator and text
                  Text(
                    "กำลังโหลด...",
                    style: TextStyle(color: Colors.white),
                  ), // Optional loading text
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> imageUpload() async {
    log(image!.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref();
    Reference refUserProfile = ref.child('order');
    Reference imageToUpload = refUserProfile.child(fileName);

    try {
      await imageToUpload.putFile(File(image!.path));
      log('test');
      pictureUrl = await imageToUpload.getDownloadURL();
      log(pictureUrl);
    } catch (e) {
      log('Error!');
    }
  }
}
