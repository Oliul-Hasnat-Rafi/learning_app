import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/chat_service.dart';
import 'package:language_learning_app/app/models/chat_conversation_model.dart';
import 'package:language_learning_app/app/models/chat_message_model.dart';

class ChatController
    extends
        GetxController {
  final ChatService chatService =
      Get.find<
        ChatService
      >();

  final RxList<
    ChatConversation
  >
  conversations =
      <
            ChatConversation
          >[]
          .obs;
  final RxList<
    ChatMessage
  >
  messages =
      <
            ChatMessage
          >[]
          .obs;
  final RxBool isLoading =
      false.obs;
  final RxString currentConversationId =
      ''.obs;
  final RxString errorMessage =
      ''.obs;

  final RxString messageText =
      ''.obs;
  final TextEditingController messageTextController =
      TextEditingController();

  var _conversationsSubscription;
  var _messagesSubscription;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  @override
  void onClose() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.onClose();
  }

  Future<
    void
  >
  loadConversations() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      _conversationsSubscription?.cancel();

      final completer =
          Completer<
            void
          >();

      _conversationsSubscription = chatService.getUserConversations().listen(
        (
          conversationsList,
        ) {
          conversations.value = conversationsList;
          isLoading.value = false;
          if (!completer.isCompleted) completer.complete();
        },
        onError: (
          error,
        ) {
          errorMessage.value = 'Failed to load conversations: $error';
          isLoading.value = false;
          if (!completer.isCompleted)
            completer.completeError(
              error,
            );
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete();
        },
      );

      return completer.future;
    } catch (
      e
    ) {
      errorMessage.value = 'Error loading conversations: $e';
      isLoading.value = false;
      rethrow;
    }
  }

  void openConversation(
    String conversationId,
  ) {
    if (currentConversationId.value ==
        conversationId)
      return;

    currentConversationId.value = conversationId;
    isLoading.value = true;
    messages.clear();

    _messagesSubscription?.cancel();

    try {
      _messagesSubscription = chatService
          .getConversationMessages(
            conversationId,
          )
          .listen(
            (
              messagesList,
            ) {
              messages.value = messagesList;
              isLoading.value = false;

              chatService.markConversationAsRead(
                conversationId,
              );
            },
            onError: (
              error,
            ) {
              errorMessage.value = 'Failed to load messages: $error';
              isLoading.value = false;
            },
          );
    } catch (
      e
    ) {
      errorMessage.value = 'Error loading messages: $e';
      isLoading.value = false;
    }
  }

  Future<
    bool
  >
  createConversationWithTeacher(
    String teacherId,
    String teacherName,
    String teacherPhoto,
  ) async {
    try {
      isLoading.value = true;
      final conversationId = await chatService.createOrGetConversation(
        teacherId,
        teacherName,
        teacherPhoto,
      );

      openConversation(
        conversationId,
      );
      return true;
    } catch (
      e
    ) {
      errorMessage.value = 'Failed to create conversation: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<
    bool
  >
  sendMessage() async {
    if (messageText.value.trim().isEmpty ||
        currentConversationId.value.isEmpty) {
      return false;
    }
    try {
      isLoading.value = true;
      await chatService.sendMessage(
        currentConversationId.value,
        messageTextController.value.text.trim(),
      );
      messageTextController.clear();
      messageText.value = '';
      return true;
    } catch (
      e
    ) {
      errorMessage.value = 'Failed to send message: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<
    void
  >
  deleteConversation(
    String conversationId,
  ) async {
    try {
      isLoading.value = true;
      await chatService.deleteConversation(
        conversationId,
      );

      if (currentConversationId.value ==
          conversationId) {
        currentConversationId.value = '';
        messages.clear();
      }
    } catch (
      e
    ) {
      errorMessage.value = 'Failed to delete conversation: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Map<
    String,
    String
  >
  getOtherParticipantInfo(
    ChatConversation conversation,
  ) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ??
        '';
    String otherUserId =
        '';

    for (var participant in conversation.participants) {
      if (participant !=
          currentUserId) {
        otherUserId =
            participant;
        break;
      }
    }

    return {
      'id':
          otherUserId,
      'name':
          conversation.participantNames[otherUserId] ??
          'Unknown',
      'photo':
          conversation.participantPhotos[otherUserId] ??
          '',
    };
  }
}
