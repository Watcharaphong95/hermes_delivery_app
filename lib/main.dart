import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_app/pages_user/login.dart';

main() async {
  CameraPosition initPosition;
  await GetStorage.init();
  final box = GetStorage();
  if (Platform.isAndroid) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
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
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginPage());
  }
}
