// To parse this JSON data, do
//
//     final phoneSearchRes = phoneSearchResFromJson(jsonString);

import 'dart:convert';

List<PhoneSearchRes> phoneSearchResFromJson(String str) =>
    List<PhoneSearchRes>.from(
        json.decode(str).map((x) => PhoneSearchRes.fromJson(x)));

String phoneSearchResToJson(List<PhoneSearchRes> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PhoneSearchRes {
  int uid;
  String phone;
  String name;
  String password;
  String address;
  double lat;
  double lng;
  String picture;

  PhoneSearchRes({
    required this.uid,
    required this.phone,
    required this.name,
    required this.password,
    required this.address,
    required this.lat,
    required this.lng,
    required this.picture,
  });

  factory PhoneSearchRes.fromJson(Map<String, dynamic> json) => PhoneSearchRes(
        uid: json["uid"],
        phone: json["phone"],
        name: json["name"],
        password: json["password"],
        address: json["address"],
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
        picture: json["picture"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "phone": phone,
        "name": name,
        "password": password,
        "address": address,
        "lat": lat,
        "lng": lng,
        "picture": picture,
      };
}
