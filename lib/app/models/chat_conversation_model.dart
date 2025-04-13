import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_message_model.dart';

class ChatConversation {
  final String id;
  final List<String> participants; 
  final Map<String, String> participantNames; 
  final Map<String, String> participantPhotos; 
  final ChatMessage? lastMessage;
  final Map<String, int> unreadCount; 
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantPhotos,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    ChatMessage? lastMsg;
    if (data['lastMessage'] != null) {
      lastMsg = ChatMessage(
        id: '',
        senderId: data['lastMessage']['senderId'] ?? '',
        senderName: data['lastMessage']['senderName'] ?? '',
        senderPhotoUrl: data['lastMessage']['senderPhotoUrl'] ?? '',
        text: data['lastMessage']['text'] ?? '',
        timestamp: (data['lastMessage']['timestamp'] as Timestamp).toDate(),
        isRead: data['lastMessage']['isRead'] ?? false,
      );
    }

    return ChatConversation(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantPhotos: Map<String, String>.from(data['participantPhotos'] ?? {}),
      lastMessage: lastMsg,
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessage': lastMessage?.toFirestore(),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}