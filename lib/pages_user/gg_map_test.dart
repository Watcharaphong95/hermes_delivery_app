import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

import 'package:hermes_app/config/config.dart';
import 'package:map_picker/map_picker.dart';

class GgMapTest extends StatefulWidget {
  const GgMapTest({super.key});

  @override
  State<GgMapTest> createState() => _GgMapTestState();
}

class _GgMapTestState extends State<GgMapTest> {
  String apiKey = "";
  CameraPosition initPosition = const CameraPosition(
    target: LatLng(16.246671218679253, 103.25207957788868),
    zoom: 17,
  );
  final place = const LatLng(16.2457153, 103.2521884);
  var place2 = const LatLng(16.2424788, 103.2566304);

  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      setState(() {
        apiKey = config['apiKey'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            FilledButton(onPressed: showMapPicker, child: const Text('PICK')),
            Expanded(
                child: GoogleMapsWidget(
              apiKey: apiKey,
              key: UniqueKey(),
              sourceLatLng: place,
              destinationLatLng: place2,
              routeWidth: 4,
              routeColor: Colors.greenAccent,
            ))
          ],
        ));
  }

  void showMapPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // Removes any padding
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: MapPicker(
                  iconWidget: SvgPicture.asset(
                    'assets/images/location_icon.svg',
                    height: 60,
                  ),
                  mapPickerController: mapPickerController,
                  child: GoogleMap(
                    initialCameraPosition: initPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    onCameraMove: (cameraPosition) {
                      this.initPosition = cameraPosition;
                    },
                    onCameraIdle: () async {
                      mapPickerController.mapFinishedMoving!();
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                        initPosition.target.latitude,
                        initPosition.target.longitude,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.lightGreen),
                  onPressed: () {
                    log('lat: ${initPosition.target.latitude} lng: ${initPosition.target.longitude}');
                    place2 = LatLng(initPosition.target.latitude,
                        initPosition.target.longitude);
                    setState(() {});
                    Navigator.pop(
                        context); // Close dialog after selecting location
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
