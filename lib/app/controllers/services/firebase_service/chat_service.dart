import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/auth_service.dart';
import 'package:language_learning_app/app/models/chat_conversation_model.dart';
import 'package:language_learning_app/app/models/chat_message_model.dart';


class ChatService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late final CollectionReference _conversationsRef;
    final AuthService _authService = Get.put(
    AuthService(),
  );

  RxBool isLoading = false.obs;
  
  Future<ChatService> init() async {
    _conversationsRef = _firestore.collection('conversations');
    return this;
  }
  
  String get currentUserId => _authService.currentUser.value?.id ?? '';
  
  Future<String> createOrGetConversation(String otherUserId, String otherUserName, String otherUserPhoto) async {
    if (currentUserId.isEmpty) throw Exception('User not authenticated');
    
    final currentUser = _authService.currentUser;
    final currentUserName = currentUser.value?.name ?? 'User';
    final currentUserPhoto = currentUser.value?.photoUrl ?? '';
    
    final querySnap = await _conversationsRef
        .where('participants', arrayContainsAny: [currentUserId, otherUserId])
        .get();
    
    for (var doc in querySnap.docs) {
      final conversation = ChatConversation.fromFirestore(doc);
      if (conversation.participants.contains(currentUserId) && 
          conversation.participants.contains(otherUserId) &&
          conversation.participants.length == 2) {
        return conversation.id;
      }
    }
    
    final newConversation = ChatConversation(
      id: '', 
      participants: [currentUserId, otherUserId],
      participantNames: {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      },
      participantPhotos: {
        currentUserId: currentUserPhoto,
        otherUserId: otherUserPhoto,
      },
      unreadCount: {
        currentUserId: 0,
        otherUserId: 0,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final docRef = await _conversationsRef.add(newConversation.toFirestore());
    return docRef.id;
  }
  
  Future<void> sendMessage(String conversationId, String text, {List<String> attachments = const []}) async {
    if (currentUserId.isEmpty) throw Exception('User not authenticated');
    
    final conversationRef = _conversationsRef.doc(conversationId);
    final messagesRef = conversationRef.collection('messages');
    

    final currentUser = _authService.currentUser.value;
    final currentUserName = currentUser?.name ?? 'User';
    final currentUserPhoto = currentUser?.photoUrl ?? '';
    
 
    final message = ChatMessage(
      id: '', 
      senderId: currentUserId,
      senderName: currentUserName,
      senderPhotoUrl: currentUserPhoto,
      text: text,
      timestamp: DateTime.now(),
      attachments: attachments,
    );
    
    final conversationDoc = await conversationRef.get();
    final conversation = ChatConversation.fromFirestore(conversationDoc);
    
    final unreadCount = Map<String, int>.from(conversation.unreadCount);
    for (var participant in conversation.participants) {
      if (participant != currentUserId) {
        unreadCount[participant] = (unreadCount[participant] ?? 0) + 1;
      }
    }
    
    await _firestore.runTransaction((transaction) async {
      final messageRef = messagesRef.doc();
      transaction.set(messageRef, message.toFirestore());
      
      transaction.update(conversationRef, {
        'lastMessage': message.toFirestore(),
        'unreadCount': unreadCount,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }
  
  Future<void> markConversationAsRead(String conversationId) async {
    if (currentUserId.isEmpty) throw Exception('User not authenticated');
    
    final conversationRef = _conversationsRef.doc(conversationId);
    
    await conversationRef.update({
      'unreadCount.$currentUserId': 0,
    });
    
    final messagesRef = conversationRef.collection('messages');
    final unreadMessages = await messagesRef
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUserId)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
  
  Stream<List<ChatConversation>> getUserConversations() {
    if (currentUserId.isEmpty) return Stream.value([]);
    
    return _conversationsRef
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => ChatConversation.fromFirestore(doc)).toList());
  }
  
  Stream<List<ChatMessage>> getConversationMessages(String conversationId) {
    return _conversationsRef
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }
  
  Future<void> deleteConversation(String conversationId) async {
    final messagesRef = _conversationsRef.doc(conversationId).collection('messages');
    final messagesSnapshot = await messagesRef.get();
    
    final batch = _firestore.batch();
    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    batch.delete(_conversationsRef.doc(conversationId));
    
    await batch.commit();
  }


}