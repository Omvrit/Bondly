import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;   // The userId of the person you're chatting with
  final String receiverName;
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Connect to socket and register current user
    ChatService().initSocket(widget.currentUserName);
    
    // Listen for incoming private messages
    ChatService().onMessageReceived = (data) {
      if (data['senderId'] == widget.receiverId) {
        setState(() {
          _messages.add({
            'text': data['message'],
            'isMe': false,
            'timestamp': DateTime.now(),
          });
        });
        _scrollToBottom();
      }
    };
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'timestamp': DateTime.now(),
      });
    });

    // Send via socket
    ChatService().sendMessage(
      senderId: widget.currentUserName,
      recipientId: widget.receiverId,
      message: text,
    );

    _controller.clear();
    _scrollToBottom();
  }
  String _formatTimestamp(dynamic rawTimestamp) {
  DateTime dateTime;

  if (rawTimestamp is DateTime) {
    dateTime = rawTimestamp;
  } else if (rawTimestamp is String) {
    dateTime = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
  } else if (rawTimestamp is int) {
    dateTime = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
  } else {
    return 'just now'; // fallback
  }

  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}


  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: msg['text'] + '\n',
        style: TextStyle(
          fontSize: 16,
          color: isMe ? Colors.black : Colors.black,
        ),
      ),
      TextSpan(
        text: _formatTimestamp(msg['timestamp']),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    ],
  ),
  textAlign: TextAlign.start,
  textScaleFactor: 1.2,
),

          
          
          
        )
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverId),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (_, index) => _buildMessage(_messages[index]),
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueGrey[800],
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
