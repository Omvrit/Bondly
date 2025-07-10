import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/connection.dart';

class ConnectionService {
  final String baseUrl;
  final String authToken;

  ConnectionService({required this.baseUrl, required this.authToken});

  Future<List<Connection>> getConnections() async {
    final response = await http.get(
      Uri.parse('$baseUrl/connections'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Connection.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load connections');
    }
  }

  Future<void> addConnection(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/connections'),
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