import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/conversation.dart';

class ConnectionService {
  final String baseUrl;
  final String authToken;

  ConnectionService({required this.baseUrl, required this.authToken});

  Future<List<User>> getConnections() async {
  String uri = '$baseUrl/connections';
  print('URI: $uri');

  final response = await http.get(
    Uri.parse(uri),
    headers: {'Authorization': 'Bearer $authToken'},
  );

  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    final data = body['connectedUsers'];
    
    

    final finalData= (data as List<dynamic>)
        .map((json) => User.fromJson(json))
        .toList();
   
    return finalData;
  } else {
    throw Exception('Failed to load connections: ${response.body}');
  }
}




  Future<void> addConnection(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/connections'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'userId': userId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add connection');
    }
  }
}