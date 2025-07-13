import 'package:http/http.dart' as http;
import 'package:chat_app/models/user.dart';
import 'dart:convert';
import '../services/conversation.dart';
class FriendRequest {
  final String baseUrl;
  final String authToken;

  FriendRequest({required this.baseUrl, required this.authToken});
  Future<List<User>> fetchPendingRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fetch-pending-requests'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );
   
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to fetch friend requests');
    }
  }
  Future<String> sendRequest(String username) async {

    final response = await http.post(
      Uri.parse('$baseUrl/users/send-request/$username'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'username': username}),
    );
    print(response.body);

    if (response.statusCode == 200) {
      return 'Request sent successfully';
    } else {
      throw Exception('Failed to send friend request');
    }
  }
  Future<String> acceptRequest(String username) async {
    print("username: $username");
    final response = await http.post(
      Uri.parse('$baseUrl/users/accept-request/$username'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      
      return 'Request accepted successfully';
    } else {
      throw Exception('Failed to accept friend request');
    }
  }
  Future<String> rejectRequest(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reject-request/$username'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'username': username}),
    );

    if (response.statusCode == 201) {
      return 'Request rejected successfully';
    } else {
      throw Exception('Failed to reject friend request');
    }
  }

}