import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderRes {
  final String receiverUid;
  final DateTime createAt;
  final String detail;
  final String picture;
  final String documentId;

  OrderRes({
    required this.receiverUid,
    required this.createAt,
    required this.detail,
    required this.picture,
    required this.documentId,
  });

  // Factory method to create an OrderRes object from Firestore data
  factory OrderRes.fromFirestore(Map<String, dynamic> data, String documentId) {
    Timestamp timestamp = data['createAt'] as Timestamp;
    DateTime dateTime = timestamp.toDate();

    return OrderRes(
      receiverUid: data['receiverUid'].toString(),
      createAt: dateTime,
      detail: data['detail'] ??
          '', // Handle case where 'detail' might be missing or empty
      picture: data['picture'] ??
          '', // Handle case where 'picture' might be missing or empty
      documentId: documentId,
    );
  }

  // Method to format the date according to the Buddhist calendar
  String get formattedDate {
    int buddhistYear = createAt.year + 543;
    return DateFormat('dd MMMM $buddhistYear HH:mm', 'th_TH').format(createAt);
  }
}
