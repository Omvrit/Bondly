import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../services/conversation.dart';
import '../providers/auth_provider.dart';

class ConversationScreen extends StatefulWidget {
  final String currentUserId;

  const ConversationScreen({super.key, required this.currentUserId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      

      final connectionService = ConversationService(
        baseUrl: 'http://192.168.200.102:5000', // Replace with your actual IP
        authToken: authProvider.tokens!.accessToken,
      );

      final data = await connectionService.getConversations(widget.currentUserId);

      setState(() {
        _conversations = data;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print("Error loading conversations: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays > 0) {
      return "${time.day}/${time.month}";
    }
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text("Failed to load conversations"))
              : _conversations.isEmpty
                  ? const Center(child: Text("No conversations yet"))
                  : ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final convo = _conversations[index];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blueGrey,
                            backgroundImage: convo.otherUserProfilePic != null
                                ? NetworkImage(convo.otherUserProfilePic!)
                                : null,
                            child: convo.otherUserProfilePic == null
                                ? Text(
                                    convo.otherUserName[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 20, color: Colors.white),
                                  )
                                : null,
                          ),
                          title: Text(
                            convo.otherUserName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            convo.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(convo.lastUpdated),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (convo.unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${convo.unreadCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/chat/${convo.otherUserId}/${convo.otherUserName}',
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
