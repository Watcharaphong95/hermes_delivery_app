import 'dart:convert';

// Function to parse JSON data
SelectUserAll selectUserAllFromJson(String str) {
  final List<dynamic> jsonData = json.decode(str);
  return SelectUserAll.fromJson(
      jsonData[0]); // Parse the first element of the list
}

// Function to convert SelectUserAll object back to JSON
String selectUserAllToJson(SelectUserAll data) => json.encode(data.toJson());

// The SelectUserAll class definition
class SelectUserAll {
  int? uid; // Make uid nullable
  dynamic rid; // Keep rid as dynamic
  String phone;
  String password; // Consider removing if not needed
  int type;

  SelectUserAll({
    this.uid, // Allow uid to be null
    this.rid, // Allow rid to be null
    required this.phone,
    required this.password,
    required this.type,
  });

  // Factory method to create an instance from JSON
  factory SelectUserAll.fromJson(Map<String, dynamic> json) => SelectUserAll(
        uid: json["uid"] == null ? null : json["uid"] as int, // Check for null
        rid: json["rid"], // Keep as dynamic, will handle null naturally
        phone: json["phone"],
        password: json["password"],
        type: json["type"],
      );

  // Convert the SelectUserAll instance back to JSON
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "rid": rid,
        "phone": phone,
        "password": password,
        "type": type,
      };
}
