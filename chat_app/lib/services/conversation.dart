import 'package:chat_app/models/conversation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversationService {
  final String baseUrl;
  final String authToken;

  ConversationService({required this.baseUrl, required this.authToken});
  Future<List<Conversation>> getConversations(String currentUserId) async {
    print("Calling get conversations");
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/get-conversation/$currentUserId'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((conversation) => 
        
      );
      
          
    } else {
      throw Exception('Failed to get conversation');
    }
  }
  Future<String> createConversation(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'userId': userId}),
    );

    if (response.statusCode == 201) {
      return 'Conversation created successfully';
    } else {
      throw Exception('Failed to create conversation');
    }
  }
}
