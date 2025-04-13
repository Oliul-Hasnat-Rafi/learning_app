import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final List<String> attachments; 

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderPhotoUrl,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.attachments = const [],
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      attachments: List<String>.from(data['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'attachments': attachments,
    };
  }
}