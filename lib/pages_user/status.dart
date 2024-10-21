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
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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

  List<LatLng> riders = [];

  late LatLng destination;
  late LatLng userLocation;

  bool _isLoading = false;
  String pictureUrl = '';
  final ImagePicker picker = ImagePicker();
  XFile? image;

  CameraPosition initPosition = const CameraPosition(
    target: LatLng(16.246671218679253, 103.25207957788868),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    readData();
    log(widget.docId);
    startLocationUpdates();
    startRealtimeGet();
    initPosition =
        CameraPosition(target: LatLng(box.read('curLat'), box.read('curLng')));
  }

  String distance = '';
  String duration = '';
  bool distanceAccpet = false;
  int _activeButtonIndex = 2;
  double screenWidth = 0;
  double screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
              height: screenHeight * 1,
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
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _fitAllMarkers();
                  }); // Fit all markers when the map is created
                },
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                zoomControlsEnabled: true,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, screenHeight * 0.58, 0, 0),
            child: SingleChildScrollView(
              child: orders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
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
                                      : const Center(
                                          child: CircularProgressIndicator()),
                                  SizedBox(
                                    width: screenWidth * 0.02,
                                  ),
                                  duration != null
                                      ? Text(duration.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ))
                                      : const Center(
                                          child: CircularProgressIndicator()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.1,
                            screenHeight * 0.02,
                            screenWidth * 0.1,
                            0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatusStep('ไรเดอร์\nรับงาน', Icons.inbox,
                                  int.parse(orders[0].status) > 1),
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
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, screenHeight * 0.03, 0, screenHeight * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatusButton(2, 'รอไรเดอร์\nมารับสินค้า',
                                  int.parse(orders[0].status) >= 1),
                              const SizedBox(width: 8),
                              _buildStatusButton(3, 'ไรเดอร์รับ\nสินค้า',
                                  int.parse(orders[0].status) >= 2),
                              const SizedBox(width: 8),
                              _buildStatusButton(4, 'ส่งสินค้า\nเสร็จสิ้น',
                                  int.parse(orders[0].status) >= 3),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.1,
                            screenHeight * 0.04,
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
                              // onTap: imagePicker,
                              child: Center(
                                // Center the image within the container
                                child: (_activeButtonIndex == 2)
                                    ? showImagePerStaus(screenWidth,
                                        screenHeight, _activeButtonIndex)
                                    : (_activeButtonIndex == 3)
                                        ? showImagePerStaus(screenWidth,
                                            screenHeight, _activeButtonIndex)
                                        : (_activeButtonIndex == 4)
                                            ? showImagePerStaus(
                                                screenWidth,
                                                screenHeight,
                                                _activeButtonIndex)
                                            : noImagePerStatus(
                                                screenWidth, screenHeight),
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
    );
  }

  Future<void> addPicturePerStatus() async {
    if (image == null) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('ยืนยันรูปนี้?')),
            content: Image.file(
              File(image!.path), fit: BoxFit.contain,
              width: screenWidth *
                  0.85, // Ensure the image doesn't overflow horizontally
              height: screenHeight * 0.3,
            ),
            actions: [FilledButton(onPressed: () {}, child: const Text('OK'))],
          );
        });
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

  Image showImagePerStaus(double screenWidth, double screenHeight, int status) {
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
        height:
            screenHeight * 0.3, // Ensure the image doesn't overflow vertically
      );
    } else {
      return Image.asset(
        'assets/images/Logo_camera.png',
        fit: BoxFit.contain, // Make sure the SVG fits properly
        width: screenWidth * 0.85, // Same size for the SVG
        height: screenHeight * 0.2, // Adjust the height for SVG
      );
    }
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
    log(destination.toString());
    log(userLocation.toString());
    if (int.parse(orders[0].status) > 1) {
      for (var order in orders) {
        origins.add(Locations(
            location: LatLng(order.latRider!, order.lngRider!),
            status: order.status));
      }
    }
    setupMarkers();
    setState(() {});
  }

  Widget _buildStatusButton(int index, String text, bool disable) {
    log(disable.toString());
    bool isActive = _activeButtonIndex == index;
    log(_activeButtonIndex.toString());
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

  Future<void> _getMarkers() async {
    setState(() {
      _markers.clear();
    });

    if (origins.isNotEmpty) {
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

          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
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

  Image noImagePerStatus(double screenWidth, double screenHeight) {
    return Image.asset(
      'assets/images/Logo_camera.png',
      fit: BoxFit.contain, // Make sure the SVG fits properly
      width: screenWidth * 0.85, // Same size for the SVG
      height: screenHeight * 0.2, // Adjust the height for SVG
    );
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

  void startLocationUpdates() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
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
}

class Locations {
  final LatLng location;
  final String status;

  Locations({
    required this.location,
    required this.status,
  });
}
