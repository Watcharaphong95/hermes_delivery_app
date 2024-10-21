// To parse this JSON data, do
//
//     final selectRiderRid = selectRiderRidFromJson(jsonString);

import 'dart:convert';

List<SelectRiderRid> selectRiderRidFromJson(String str) =>
    List<SelectRiderRid>.from(
        json.decode(str).map((x) => SelectRiderRid.fromJson(x)));

String selectRiderRidToJson(List<SelectRiderRid> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SelectRiderRid {
  int rid;
  String phone;
  String name;
  String password;
  String picture;
  String plate;
  int type;

  SelectRiderRid({
    required this.rid,
    required this.phone,
    required this.name,
    required this.password,
    required this.picture,
    required this.plate,
    required this.type,
  });

  factory SelectRiderRid.fromJson(Map<String, dynamic> json) => SelectRiderRid(
        rid: json["rid"],
        phone: json["phone"],
        name: json["name"],
        password: json["password"],
        picture: json["picture"],
        plate: json["plate"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "rid": rid,
        "phone": phone,
        "name": name,
        "password": password,
        "picture": picture,
        "plate": plate,
        "type": type,
      };
}
