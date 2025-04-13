import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:language_learning_app/app/view/chat/chat_detail_view.dart';
import 'package:language_learning_app/app/view/widget/card.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';

import '../../utils/components.dart';
import '../../controllers/view_controller/chat_controller.dart';
import '../../models/chat_conversation_model.dart';

class ChatListView extends StatelessWidget {
  ChatListView({super.key});

  final ChatController controller = Get.put(ChatController());
  
  _size(int i) {
    return SizedBox(height: defaultPadding / i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SubtitleText(
          string: 'Messages',
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Obx(
        () {
          if (controller.isLoading.value && controller.conversations.isEmpty) {
            return const LinearProgressIndicator();
          }

          if (controller.conversations.isEmpty) {
            return _buildEmptyState();
          }

          return _buildConversationsList();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => controller.loadConversations(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: Get.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
                _size(2),
                const TitleText('No conversations yet'),
                _size(2),
                const SubtitleText(
                  string: 'Start chatting with a teacher to get help with your learning',
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return RefreshIndicator(
      onRefresh: () => controller.loadConversations(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(defaultPadding / 2),
        itemCount: controller.conversations.length,
        itemBuilder: (context, index) {
          final conversation = controller.conversations[index];
          return _buildConversationItem(conversation);
        },
      ),
    );
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    final otherUser = controller.getOtherParticipantInfo(conversation);
    final unreadCount = conversation.unreadCount[controller.chatService.currentUserId] ?? 0;

    String timeAgo = '';
    if (conversation.lastMessage != null) {
      final now = DateTime.now();
      final difference = now.difference(conversation.lastMessage!.timestamp);

      if (difference.inDays == 0) {
        timeAgo = DateFormat.jm().format(conversation.lastMessage!.timestamp);
      } else if (difference.inDays < 7) {
        timeAgo = DateFormat.E().format(conversation.lastMessage!.timestamp);
      } else {
        timeAgo = DateFormat.MMMd().format(conversation.lastMessage!.timestamp);
      }
    }

    return CustomCard(
      onTap: () {
        controller.openConversation(conversation.id);
        if(controller.currentConversationId.isNotEmpty){
                  Get.to(() => ChatDetailView(conversationId: conversation.id));

        }
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: defaultBorderRadius * 3,
            backgroundImage: otherUser['photo']!.isNotEmpty ? NetworkImage(otherUser['photo']!) : null,
            child: otherUser['photo']!.isEmpty
                ? Text(
                    otherUser['name']!.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 24),
                  )
                : null,
          ),
          SizedBox(width: defaultPadding / 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      otherUser['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                _size(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      conversation.lastMessage?.text ?? 'Start a conversation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unreadCount > 0 ? Colors.black : Colors.grey[600],
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(Get.context!).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}