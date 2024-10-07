// To parse this JSON data, do
//
//     final riderRegisterReq = riderRegisterReqFromJson(jsonString);

import 'dart:convert';

RiderRegisterReq riderRegisterReqFromJson(String str) =>
    RiderRegisterReq.fromJson(json.decode(str));

String riderRegisterReqToJson(RiderRegisterReq data) =>
    json.encode(data.toJson());

class RiderRegisterReq {
  String phone;
  String name;
  String password;
  String picture;
  String plate;
  String type;

  RiderRegisterReq({
    required this.phone,
    required this.name,
    required this.password,
    required this.picture,
    required this.plate,
    required this.type,
  });

  factory RiderRegisterReq.fromJson(Map<String, dynamic> json) =>
      RiderRegisterReq(
        phone: json["phone"],
        name: json["name"],
        password: json["password"],
        picture: json["picture"],
        plate: json["plate"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "name": name,
        "password": password,
        "picture": picture,
        "plate": plate,
        "type": type,
      };
}
