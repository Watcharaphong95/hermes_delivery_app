import 'dart:convert';

SelectUserAll selectUserAllFromJson(String str) =>
    SelectUserAll.fromJson(json.decode(str));

String selectUserAllToJson(SelectUserAll data) => json.encode(data.toJson());

class SelectUserAll {
  int uid;
  String phone;
  String name;
  String password;
  String? address;
  String? plate;
  double? lat;
  double? lng;
  String picture;
  int type;

  SelectUserAll({
    required this.uid,
    required this.phone,
    required this.name,
    required this.password,
    this.address,
    this.plate,
    this.lat,
    this.lng,
    required this.picture,
    required this.type,
  });

  factory SelectUserAll.fromJson(Map<String, dynamic> json) => SelectUserAll(
        uid: json["uid"],
        phone: json["phone"],
        name: json["name"],
        password: json["password"],
        address: json["address"],
        plate: json["plate"],
        lat: json["lat"] == null ? null : json["lat"].toDouble(),
        lng: json["lng"] == null ? null : json["lng"].toDouble(),
        picture: json["picture"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "phone": phone,
        "name": name,
        "password": password,
        "address": address,
        "plate": plate,
        "lat": lat,
        "lng": lng,
        "picture": picture,
        "type": type,
      };
}
