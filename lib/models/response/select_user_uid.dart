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
        uid: json["uid"] ?? 0, // Default to 0 if uid is null
        phone: json["phone"] ?? '', // Default to empty string if phone is null
        name: json["name"] ?? '', // Default to empty string if name is null
        password: json["password"] ??
            '', // Default to empty string if password is null
        address:
            json["address"] ?? '', // Default to empty string if address is null
        lat: (json["lat"] ?? 0.0).toDouble(), // Default to 0.0 if lat is null
        lng: (json["lng"] ?? 0.0).toDouble(), // Default to 0.0 if lng is null
        picture:
            json["picture"] ?? '', // Default to empty string if picture is null
        type: json["type"] ?? 0, // Default to 0 if type is null
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
  print('User ID: ${user.uid}, Name: ${user.name}, Phone: ${user.phone}');
}
