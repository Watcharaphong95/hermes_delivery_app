import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:hermes_app/models/response/order_firebase_res.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

class StatusRider extends StatefulWidget {
  String docId = "";
  StatusRider({super.key, required this.docId});

  @override
  State<StatusRider> createState() => _StatuspageState();
}

class _StatuspageState extends State<StatusRider> {
  final box = GetStorage();
  String apiKey = "";
  bool isLoadingMap = true;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};

  var db = FirebaseFirestore.instance;
  late StreamSubscription listener;
  late Stream<Position> currentPosition;

  List<OrderRes> orders = [];

  List<LatLng> riders = [];

  late LatLng destination;
  late LatLng pickup;

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
      onPopInvoked: (didPop) async {
        listener.cancel();
      },
      child: Scaffold(
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
              if (isLoadingMap)
                const Center(child: CircularProgressIndicator()),
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
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.1,
                  screenHeight * 0.31,
                  screenWidth * 0.1,
                  0,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.07,
                  screenHeight * 0.54,
                  screenWidth * 0.1,
                  0,
                ),
                child: const Text("สถานะการจัดส่ง",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
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
    setState(() {
      initPosition = CameraPosition(target: destination);
    });
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

    for (int index = 0; index < riders.length; index++) {
      LatLng rider = riders[index];
      String url = '';
      if (orders[0].status == 2.toString()) {
        url =
            "https://maps.googleapis.com/maps/api/directions/json?origin=${destination.latitude},${destination.longitude}&destination=${rider.latitude},${rider.longitude}&mode=driving&key=$apiKey";
      } else if (orders[0].status == 3.toString()) {
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
        var distance = leg['distance']['text'];
        var duration = leg['duration']['text'];

        log("Distance from $rider to destination: $distance");
        log("Duration from $rider to destination: $duration");

        if (orders[0].status == 2.toString()) {
          _addDestinationMarker(distance, duration);
        } else if (orders[0].status == 3.toString()) {
          _addPickUpMarker(distance, duration);
        }

        await _addRiderMarker(rider);
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
    final docRef = db.collection("order");
    docRef.snapshots().listen((event) {
      setState(() {
        readData();
      });
    }, onError: (error) => log("Listen failed"));
  }
}
