// To parse this JSON data, do
//
//     final userRegisterReq = userRegisterReqFromJson(jsonString);

import 'dart:convert';

UserRegisterReq userRegisterReqFromJson(String str) =>
    UserRegisterReq.fromJson(json.decode(str));

String userRegisterReqToJson(UserRegisterReq data) =>
    json.encode(data.toJson());

class UserRegisterReq {
  String phone;
  String name;
  String password;
  String address;
  double lat;
  double lng;
  String picture;

  UserRegisterReq({
    required this.phone,
    required this.name,
    required this.password,
    required this.address,
    required this.lat,
    required this.lng,
    required this.picture,
  });

  factory UserRegisterReq.fromJson(Map<String, dynamic> json) =>
      UserRegisterReq(
        phone: json["phone"],
        name: json["name"],
        password: json["password"],
        address: json["address"],
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
        picture: json["picture"],
      );

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "name": name,
        "password": password,
        "address": address,
        "lat": lat,
        "lng": lng,
        "picture": picture,
      };
}
