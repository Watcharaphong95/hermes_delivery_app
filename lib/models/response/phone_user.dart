// To parse this JSON data, do
//
//     final selectPhoneUser = selectPhoneUserFromJson(jsonString);

import 'dart:convert';

SelectPhoneUser selectPhoneUserFromJson(String str) =>
    SelectPhoneUser.fromJson(json.decode(str));

String selectPhoneUserToJson(SelectPhoneUser data) =>
    json.encode(data.toJson());

class SelectPhoneUser {
  int uid;
  String phone;
  String name;
  String password;
  String address;
  double lat;
  double lng;
  String picture;
  int type;

  SelectPhoneUser({
    required this.uid,
    required this.phone,
    required this.name,
    required this.password,
    required this.address,
    required this.lat,
    required this.lng,
    required this.picture,
    required this.type,
  });

  factory SelectPhoneUser.fromJson(Map<String, dynamic> json) =>
      SelectPhoneUser(
        uid: json["uid"],
        phone: json["phone"],
        name: json["name"],
        password: json["password"],
        address: json["address"],
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
        picture: json["picture"],
        type: json["type"],
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
        "type": type,
      };
}
