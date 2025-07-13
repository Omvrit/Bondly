import 'dart:convert';
import 'package:chat_app/models/auth.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  final String baseUrl;
  final String authToken;

  UserService({required this.baseUrl, required this.authToken});
  
  Future<List<User>> searchUsersByUsername(String username ) async {
    if (username.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$username'),
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
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }
  Future<User> searchMe() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('Raw user data: $data');

       // store raw user data
      return User.fromJson(data); // convert to Connection model
    } else {
      throw Exception('Failed to fetch current user: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch current user: ${e.toString()}');
  }
}

  }
  // Future<User> GetMe() async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/me'),
  //     headers: {
  //       'Authorization': 'Bearer $authToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     return User.fromJson(json.decode(response.body)['user']);
  //   } else {
  //     throw Exception('Failed to get user data');
  //   }
  // }

