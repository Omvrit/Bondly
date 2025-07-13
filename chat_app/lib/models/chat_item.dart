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