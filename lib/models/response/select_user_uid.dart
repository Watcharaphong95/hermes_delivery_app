import 'dart:convert';

// Function to parse a single SelectUserUid from JSON string
SelectUserUid selectUserUidFromJson(String str) {
  // Decode the JSON string and extract the first object from the list
  final List<dynamic> jsonList = json.decode(str);
  if (jsonList.isNotEmpty) {
    return SelectUserUid.fromJson(jsonList[0]);
  } else {
    throw Exception('No user found in the JSON string');
  }
}

// Function to convert a single SelectUserUid to JSON string
String selectUserUidToJson(SelectUserUid data) => json.encode(data.toJson());

// SelectUserUid class definition
class SelectUserUid {
  int uid;
  String phone;
  String name;
  String password;
  String address;
  double lat; // Change to double to match the provided JSON
  double lng; // Change to double to match the provided JSON
  String picture;
  int type;

  SelectUserUid({
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

  factory SelectUserUid.fromJson(Map<String, dynamic> json) => SelectUserUid(
        uid: json["uid"],
        phone: json["phone"],
        name: json["name"],
        password: json["password"],
        address: json["address"],
        lat: (json["lat"] ?? 0.0).toDouble(), // Use 0.0 if lat is null
        lng: (json["lng"] ?? 0.0).toDouble(), // Use 0.0 if lng is null
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

// Example usage
void main() {
  String jsonString =
      '[{"uid":9,"phone":"0894565468","name":"you","password":"1","address":"763Q+8G6 ตำบล ขามเรียง อำเภอกันทรวิชัย มหาสารคาม 44150","lat":16.2536,"lng":103.239,"picture":"https://firebasestorage.googleapis.com/v0/b/hermes-app-9e382.appspot.com/o/profile%2F1728315158080?alt=media&token=5292f05b-798e-4031-b9e6-07e66f4d4d22","type":1}]';

  // Parsing the JSON string into a SelectUserUid object
  SelectUserUid user = selectUserUidFromJson(jsonString);

  // Print the details of the user
  print(
      'User ID: ${user.uid}, Name: ${user.name}, Phone: ${user.phone}, Latitude: ${user.lat}, Longitude: ${user.lng}');
}
