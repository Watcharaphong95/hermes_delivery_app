import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
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
  bool isLoadingMap = true;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  var db = FirebaseFirestore.instance;
  late StreamSubscription listener;
  late Stream<Position> currentPosition;

  List<OrderRes> orders = [];

  List<LatLng> riders = [];

  late LatLng destination;
  late LatLng pickup;

  final ImagePicker picker = ImagePicker();
  XFile? image;

  String distance = '';
  String duration = '';
  bool distanceAccpet = false;

  CameraPosition initPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    readData();
    startLocationUpdates();
    startRealtimeGet();
    log(widget.docId);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatusStep(
                              'ไรเดอร์\nรับงาน', Icons.inbox, true),
                          _buildConnectorLine(true),
                          _buildStatusStep('รอไรเดอร์\nมารับสินค้า',
                              Icons.directions_bike, true),
                          _buildConnectorLine(false),
                          _buildStatusStep('รับสินค้าแล้ว\nกำลังเดินทาง',
                              Icons.local_shipping, false),
                          _buildConnectorLine(false),
                          _buildStatusStep(
                              'ส่งสินค้า\nเสร็จสิ้น', Icons.done_all, false),
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
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.05),
                        child: Container(
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.3,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: InkWell(
                            onTap: imagePicker,
                            child: Center(
                              // Center the image within the container
                              child: (image != null)
                                  ? Image.file(
                                      File(image!.path),
                                      fit: BoxFit.contain,
                                      width: screenWidth *
                                          0.85, // Ensure the image doesn't overflow horizontally
                                      height: screenHeight *
                                          0.3, // Ensure the image doesn't overflow vertically
                                    )
                                  : Image.asset(
                                      'assets/images/Logo_camera.png',
                                      fit: BoxFit
                                          .contain, // Make sure the SVG fits properly
                                      width: screenWidth *
                                          0.85, // Same size for the SVG
                                      height: screenHeight *
                                          0.2, // Adjust the height for SVG
                                    ),
                            ),
                          ),
                        ),
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

  void readData() async {
    riders.clear();
    await initializeDateFormatting('th', null);
    var result = await db.collection('order').doc(widget.docId).get();

    orders = [OrderRes.fromFirestore(result.data()!, result.id)];

    orders.sort((a, b) => b.createAt.compareTo(a.createAt));

    pickup = LatLng(orders[0].latSender!, orders[0].lngSender!);
    destination = LatLng(orders[0].latReceiver!, orders[0].lngReceiver!);

    for (var order in orders) {
      riders.add(LatLng(order.latRider!, order.lngRider!));
    }
    setupMarkers();
    setState(() {});
  }

  Future<void> checkRiderUid() async {
    var check = await db
        .collection("order")
        .where('riderRid', isEqualTo: box.read('uid'))
        .get();
    if (check.docs.isEmpty) {
      orders = check.docs.map((doc) {
        return OrderRes.fromFirestore(doc.data(), doc.id);
      }).toList();

      Get.to(() => const HomeRiderpage());
    } else {
      await db.collection('order').doc(widget.docId).update({
        'latRider': box.read('curLat'),
        'lngRider': box.read('curLng'),
      });
    }
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

    currentPosition =
        Geolocator.getPositionStream(locationSettings: locationSettings);
    currentPosition.listen((Position position) async {
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      await db.collection('order').doc(widget.docId).update({
        'latRider': position.latitude,
        'lngRider': position.longitude,
      });
      log('Current Location: $currentLocation');
    });
    setState(() {});
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
            color: isActive ? Colors.black : Colors.grey,
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
}
