class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastUpdated;

  final String otherUserId;
  final String otherUserName;
  final String? otherUserProfilePic;

  final int unreadCount;

  final bool isGroup;
  final String? groupName;             // Shown on group UI
  final String? groupProfilePic;       // Optional group icon

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdated,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePic,
    this.unreadCount = 0,
    this.isGroup = false,
    this.groupName,
    this.groupProfilePic,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String currentUserId) {
    final List<String> participantList = List<String>.from(json['participants']);
    final String otherId = participantList.firstWhere((id) => id != currentUserId, orElse: () => '');

    return Conversation(
      id: json['_id'],
      participants: participantList,
      lastMessage: json['lastMessage'] ?? '',
      lastUpdated: DateTime.parse(json['lastUpdated']),

      otherUserId: otherId,
      otherUserName: json['otherUserName'] ?? (json['groupName'] ?? 'Unknown'),
      otherUserProfilePic: json['otherUserProfilePic'] ?? json['groupProfilePic'],

      unreadCount: json['unreadCount'] ?? 0,

      isGroup: json['isGroup'] ?? false,
      groupName: json['groupName'],
      groupProfilePic: json['groupProfilePic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdated': lastUpdated.toIso8601String(),
      'otherUserName': otherUserName,
      'otherUserProfilePic': otherUserProfilePic,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupProfilePic': groupProfilePic,
    };
  }
}
