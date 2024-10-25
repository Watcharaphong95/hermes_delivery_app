import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AppData with ChangeNotifier {
  late StreamSubscription listenerHome;
  late StreamSubscription<Position> locationSubscriptionHome;

  late StreamSubscription listenerStatus;
  late StreamSubscription<Position> locationSubscriptionStatus;
}
