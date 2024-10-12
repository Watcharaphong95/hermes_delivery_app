import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/firebase_options.dart';
import 'package:hermes_app/pages_user/login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:intl/intl.dart' as intl; // Use this to initialize locale

main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures proper initialization for async code
  await firebase();

  await GetStorage.init();
  final box = GetStorage();

  if (Platform.isAndroid) {
    // ignore: deprecated_member_use
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  await permissionReq(box);

  runApp(const MyApp());
}

Future<void> permissionReq(GetStorage box) async {
  CameraPosition initPosition;
  // Request location permission from the user
  var status = await Permission.location.request();

  if (status.isGranted) {
    // If permission is granted, proceed to get the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    initPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 17);

    log(initPosition.target.latitude.toString());
    box.write('curLat', initPosition.target.latitude);
    box.write('curLng', initPosition.target.longitude);

    double curLat = double.parse(box.read('curLat').toString());
    double curLng = double.parse(box.read('curLng').toString());
    log("Stored Latitude: $curLat");
    log("Stored Longitude: $curLng");
  } else if (status.isDenied || status.isPermanentlyDenied) {
    // Handle the case where permission is denied
    openAppSettings();
  }
}

Future<void> firebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansThaiTextTheme(),
      ),
      home: const LoginPage(),
    );
  }
}
