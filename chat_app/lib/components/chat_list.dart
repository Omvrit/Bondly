import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final List<ChatItem> chats;
  final Function(String, String) onChatSelected;
  
  const ChatList({
    super.key,
    required this.chats,
    required this.onChatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chat.avatar),
            ),
            title: Text(chat.name),
            subtitle: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              chat.time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () => onChatSelected(chat.id, chat.name),
          );
        },
      ),
    );
  }
}

class ChatItem {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final bool? isOnline;

  ChatItem({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    this.isOnline,
  });
}