import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/config/config.dart';
import 'package:http/http.dart' as http;

class Statuspage extends StatefulWidget {
  const Statuspage({super.key});

  @override
  State<Statuspage> createState() => _StatuspageState();
}

class _StatuspageState extends State<Statuspage> {
  String apiKey = "";
  bool isLoadingMap = true;
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  List<LatLng> origins = [
    const LatLng(16.242498055074165, 103.25660616873793),
    const LatLng(16.24736770978036, 103.24996235667359),
    const LatLng(16.238820702780373, 103.25189620970872),
  ];

  final LatLng destination =
      const LatLng(16.246671218679253, 103.25207957788868);

  CameraPosition initPosition = const CameraPosition(
    target: LatLng(16.246671218679253, 103.25207957788868),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    polylineSetup();
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
                height: screenHeight * 0.7,
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
                  polylines: _polylines,
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

  Future<void> polylineSetup() async {
    setState(() {
      isLoadingMap = true;
    });
    await getApiKey();
    _getPolylines();
    setState(() {
      isLoadingMap = false;
    });
  }

  Future<void> _getPolylines() async {
    // Clear previous markers and polylines
    setState(() {
      _polylines.clear();
      _markers.clear();
    });

    for (int index = 0; index < origins.length; index++) {
      LatLng origin = origins[index];
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['routes'].isEmpty) {
          log("No routes found in the API response for origin: $origin");
          continue; // Skip to the next origin if no route found
        }

        // Extract distance and duration
        var leg = jsonResponse['routes'][0]['legs'][0];
        var distance = leg['distance']['text']; // e.g., "5.0 km"
        var duration = leg['duration']['text']; // e.g., "15 mins"

        log("Distance from $origin to destination: $distance");
        log("Duration from $origin to destination: $duration");

        _addPolylineToMap(jsonResponse, origin);
        // Pass the index or a label for the rider
        await _addOriginMarker(origin, distance, duration,
            'Rider ${index + 1}'); // Using index for labeling
      } else {
        log("Failed to load directions for origin: $origin - ${response.reasonPhrase}");
      }
    }

    _addDestinationMarker();
    _fitAllMarkers(); // Call this after adding all markers
  }

  void _addPolylineToMap(Map<String, dynamic> jsonResponse, LatLng origin) {
    List<LatLng> polylinePoints = [];

    if (jsonResponse['routes'].isNotEmpty &&
        jsonResponse['routes'][0]['legs'].isNotEmpty) {
      for (var step in jsonResponse['routes'][0]['legs'][0]['steps']) {
        var startLocation = step['start_location'];
        var endLocation = step['end_location'];
        polylinePoints.add(LatLng(startLocation['lat'], startLocation['lng']));
        polylinePoints.add(LatLng(endLocation['lat'], endLocation['lng']));
      }

      log("Polyline points for origin $origin: $polylinePoints");

      setState(() {
        _polylines.add(Polyline(
          polylineId:
              PolylineId('route_${origin.latitude}_${origin.longitude}'),
          color: Colors.blue,
          points: polylinePoints,
          width: 5,
        ));
      });
    } else {
      log("No legs or steps found in the route data for origin: $origin");
    }
  }

  void _addDestinationMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
        infoWindow: InfoWindow(
          title: '$riderLabel Distance: $distance Duration: $duration',
        ),
        icon: riderIcon,
      ));
    });
  }

  Future<void> _fitAllMarkers() async {
    if (_markers.isNotEmpty) {
      LatLngBounds bounds;

      if (_markers.length == 1) {
        // If there's only one marker, set bounds to that marker's position
        bounds = LatLngBounds(
          southwest: _markers.first.position,
          northeast: _markers.first.position,
        );
      } else {
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

        bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );
      }

      // Animate the camera to fit all markers with adjusted padding
      await mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50)); // Use smaller padding
    }
  }

  Future<BitmapDescriptor> _loadRiderIcon() async {
    final ByteData data = await rootBundle.load('assets/images/rider.png');
    final Uint8List bytes = data.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }
}
