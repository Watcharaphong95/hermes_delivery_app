// To parse this JSON data, do
//
//     final selectUserWhereId = selectUserWhereIdFromJson(jsonString);

import 'dart:convert';

List<SelectUserWhereId> selectUserWhereIdFromJson(String str) =>
    List<SelectUserWhereId>.from(
        json.decode(str).map((x) => SelectUserWhereId.fromJson(x)));

String selectUserWhereIdToJson(List<SelectUserWhereId> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SelectUserWhereId {
  int uid;
  String phone;
  String name;
  String password;
  String address;
  int lat;
  int lng;
  String picture;
  int type;

  SelectUserWhereId({
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

  factory SelectUserWhereId.fromJson(Map<String, dynamic> json) =>
      SelectUserWhereId(
        uid: json["uid"],
        phone: json["phone"],
        name: json["name"],
        password: json["password"],
        address: json["address"],
        lat: json["lat"],
        lng: json["lng"],
        picture: json["picture"],
        type: json["type"],
      );

  get longitude => null;

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
