import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/services/functions/date_time_conversion.dart';
import 'package:language_learning_app/app/models/chat_message_model.dart';
import 'package:language_learning_app/app/view/widget/custom_text_field_widget.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:language_learning_app/app/utils/components.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import '../../controllers/view_controller/chat_controller.dart';



class ChatDetailView extends GetView<ChatController> {
  final String conversationId;

  const ChatDetailView({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  _size(int i) {
    return SizedBox(
      height: defaultPadding / i,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.currentConversationId.value != conversationId) {
      controller.openConversation(conversationId);
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return _buildMessagesList();
            }),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final conversation = controller.conversations.firstWhereOrNull(
      (c) => c.id == conversationId,
    );

    String title = 'Chat';
    Widget avatar = const CircleAvatar(
      child: Icon(Icons.person),
    );

    if (conversation != null) {
      final otherUser = controller.getOtherParticipantInfo(conversation);
      title = otherUser['name'] ?? 'Chat';

      avatar = CircleAvatar(
        backgroundImage: otherUser['photo']!.isNotEmpty
            ? NetworkImage(otherUser['photo']!)
            : null,
        child: otherUser['photo']!.isEmpty
            ? TitleText(otherUser['name']!.substring(0, 1).toUpperCase())
            : null,
      );
    }

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Row(
        children: [
          avatar,
          SizedBox(width: 12.w),
          SubtitleText(
            string: title,
            color: Colors.white,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onPressed: () {
            _showOptionsMenu(context);
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    final groupedMessages = _groupMessagesByDay(controller.messages);

    return ListView.builder(
      padding: EdgeInsets.all(defaultPadding / 2),
      reverse: true,
      itemCount: groupedMessages.length,
      itemBuilder: (context, groupIndex) {
        final group = groupedMessages[groupIndex];
        
        return Column(
          children: [
            // Date separator
            if (group.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: defaultPadding / 2),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
                    ),
                    child: Text(
                      group.first.timestamp.customTodayTomorrowYesterday,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              
            ...group.map((message) => _buildMessageItem(context, message)).toList(),
          ],
        );
      },
    );
  }
  List<List<ChatMessage>> _groupMessagesByDay(List<ChatMessage> messages) {
    List<List<ChatMessage>> groups = [];
    List<ChatMessage> currentGroup = [];
    
    DateTime? currentDate;
    
    for (final message in messages) {
      final messageDate = message.timestamp.customConvertToDateTimeDate;
      
      if (currentDate == null || !messageDate.customIsSameDay(otherDate: currentDate)) {
        if (currentGroup.isNotEmpty) {
          groups.add(List.from(currentGroup));
          currentGroup.clear();
        }
        currentDate = messageDate;
      }
      
      currentGroup.add(message);
    }
    
    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }
    
    return groups;
  }
  Widget _buildMessageItem(BuildContext context, ChatMessage message) {
    final isCurrentUser = message.senderId == Get.find<ChatController>().chatService.currentUserId;

    return Padding(
      padding: EdgeInsets.only(bottom: defaultPadding / 2),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) _buildSenderAvatar(message),
          
          SizedBox(width: defaultPadding / 2),
          
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(defaultBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  _size(4),
                  Text(
                    message.timestamp.custom_hh_mm_a,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 8.w),
          
          if (isCurrentUser) _buildSenderAvatar(message),
        ],
      ),
    );
  }
  Widget _buildSenderAvatar(ChatMessage message) {
    return CircleAvatar(
      radius: defaultBorderRadius * 3,
      backgroundImage: message.senderPhotoUrl.isNotEmpty
          ? NetworkImage(message.senderPhotoUrl)
          : null,
      child: message.senderPhotoUrl.isEmpty
          ? Text(
              message.senderName.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 12),
            )
          : null,
    );
  }
  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextFormField(
              onChanged: (value) => controller.messageText.value = value,
              textEditingController: controller.messageTextController,
              hintText: 'Type a message...',
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          
          SizedBox(width: 8.w),
          
          OnProcessButtonWidget(
            onTap: () => controller.sendMessage(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(defaultPadding / 2),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete conversation'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),

            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Conversation'),
          content: const Text(
            'Are you sure you want to delete this conversation? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteConversation(conversationId);
                Get.back();
              },
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}