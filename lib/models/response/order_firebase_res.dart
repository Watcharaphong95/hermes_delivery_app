import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderRes {
  final String receiverUid;
  final String senderUid;
  final DateTime createAt;
  final DateTime? endAt; // Nullable endAt field
  final String detail;
  final String picture;
  final String picture_2;
  final String picture_3;
  final String documentId;
  final String status;
  final String? riderRid; // Nullable rider UID
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
    required this.senderUid,
    required this.createAt,
    this.endAt, // Nullable endAt
    required this.detail,
    required this.picture,
    required this.picture_2,
    required this.picture_3,
    required this.documentId,
    required this.status,
    this.riderRid,
    required this.item,
    required this.senderName,
    required this.receiverName,
    this.latReceiver, // Nullable latitude for receiver
    this.lngReceiver, // Nullable longitude for receiver
    this.latSender, // Nullable latitude for sender
    this.lngSender, // Nullable longitude for sender
    this.latRider, // Nullable latitude for rider
    this.lngRider, // Nullable longitude for rider
  });

  // Factory method to create an OrderRes object from Firestore data
  factory OrderRes.fromFirestore(Map<String, dynamic> data, String documentId) {
    Timestamp timestamp = data['createAt'] as Timestamp;

    return OrderRes(
      receiverUid: data['receiverUid']?.toString() ?? '',
      senderUid: data['senderUid']?.toString() ?? '',
      createAt: timestamp.toDate(),
      endAt:
          data['endAt'] != null ? (data['endAt'] as Timestamp).toDate() : null,
      detail: data['detail'] ?? '',
      picture: data['picture'] ?? '',
      picture_2: data['picture_2'] ?? '',
      picture_3: data['picture_3'] ?? '',
      documentId: documentId,
      status: data['status']?.toString() ?? '', // Ensure status is a string
      riderRid: data['riderRid']?.toString(),
      item: data['item'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverName: data['receiverName'] ?? '',
      latReceiver:
          data['latReceiver']?.toDouble(), // Nullable latitude for receiver
      lngReceiver:
          data['lngReceiver']?.toDouble(), // Nullable longitude for receiver
      latSender: data['latSender']?.toDouble(), // Nullable latitude for sender
      lngSender: data['lngSender']?.toDouble(), // Nullable longitude for sender
      latRider: data['latRider']?.toDouble(), // Nullable latitude for rider
      lngRider: data['lngRider']?.toDouble(), // Nullable longitude for rider
    );
  }

  // Method to format the date according to the Buddhist calendar
  String get formattedDate {
    int buddhistYear = createAt.year + 543;
    return DateFormat('dd MMMM $buddhistYear HH:mm', 'th_TH').format(createAt);
  }
}
