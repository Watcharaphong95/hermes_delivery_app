import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderRes {
  final String receiverUid;
  final String senderId;
  final DateTime createAt;
  final String detail;
  final String picture;
  final String documentId;
  final String status;
  final String? riderUid; // Nullable rider UID
  final String item;
  final String senderName;
  final String receiverName;

  // New fields for latitude and longitude
  final double? latReceiver; // Nullable latitude for receiver
  final double? lngReceiver; // Nullable longitude for receiver
  final double? latSender; // Nullable latitude for sender
  final double? lngSender; // Nullable longitude for sender
  final double? latRider; // Nullable latitude for rider
  final double? lngRider; // Nullable longitude for rider

  OrderRes({
    required this.receiverUid,
    required this.senderId,
    required this.createAt,
    required this.detail,
    required this.picture,
    required this.documentId,
    required this.status,
    this.riderUid,
    required this.item,
    required this.senderName,
    required this.receiverName,
    this.latReceiver, // New parameter for latitude of receiver
    this.lngReceiver, // New parameter for longitude of receiver
    this.latSender, // New parameter for latitude of sender
    this.lngSender, // New parameter for longitude of sender
    this.latRider, // New parameter for latitude of rider
    this.lngRider, // New parameter for longitude of rider
  });

  // Factory method to create an OrderRes object from Firestore data
  factory OrderRes.fromFirestore(Map<String, dynamic> data, String documentId) {
    Timestamp timestamp = data['createAt'] as Timestamp;
    DateTime dateTime = timestamp.toDate();

    return OrderRes(
      receiverUid: data['receiverUid'].toString(),
      senderId: data['senderId'].toString(),
      createAt: dateTime,
      detail: data['detail'] ?? '',
      picture: data['picture'] ?? '',
      documentId: documentId,
      status: data['status'].toString(), // Ensure status is a string
      riderUid: data['riderUid']?.toString(),
      item: data['item'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverName: data['receiverName'] ?? '',
      latReceiver: data['latReceiver']
          ?.toDouble(), // Handle nullable latitude for receiver
      lngReceiver: data['lngReceiver']
          ?.toDouble(), // Handle nullable longitude for receiver
      latSender:
          data['latSender']?.toDouble(), // Handle nullable latitude for sender
      lngSender:
          data['lngSender']?.toDouble(), // Handle nullable longitude for sender
      latRider:
          data['latRider']?.toDouble(), // Handle nullable latitude for rider
      lngRider:
          data['lngRider']?.toDouble(), // Handle nullable longitude for rider
    );
  }

  // Method to format the date according to the Buddhist calendar
  String get formattedDate {
    int buddhistYear = createAt.year + 543;
    return DateFormat('dd MMMM $buddhistYear HH:mm', 'th_TH').format(createAt);
  }
}
