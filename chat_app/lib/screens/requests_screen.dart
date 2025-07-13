import 'package:flutter/material.dart';
import '../services/friend_request.dart';
import '../models/user.dart';
import '../services/friend_request.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';


class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<User> _pendingRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    setState(() {
      _isLoading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final friendRequest = FriendRequest(
      baseUrl: 'http://192.168.200.102:5000',
      authToken: authProvider.tokens!.accessToken,
    );
    

    try {
      final requests = await friendRequest.fetchPendingRequests();
      _pendingRequests = requests;
      
      
      
      setState(() {
        _pendingRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch requests: $e')),
      );
    }
  }

  Future<void> _respondToRequest(String username, bool accept) async {
    try {
      print("Calling respond to request"+accept.toString());
      setState(() {
        _isLoading = true;
      });
      

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final friendRequest = FriendRequest(
        baseUrl: 'http://192.168.200.102:5000',
        authToken: authProvider.tokens!.accessToken,
      );
      

     

      
      
      if (accept) {
        await friendRequest.acceptRequest(username);
      } else {
        await friendRequest.rejectRequest(username);
      }

      
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _pendingRequests.removeWhere((user) => user.username == username);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Request accepted' : 'Request declined'),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to respond: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? const Center(child: Text('No pending requests'))
              : ListView.builder(
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(request.avatar),
                        ),
                        title: Text(request.username),
                        subtitle: Text(request.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  _respondToRequest(request.username, true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  _respondToRequest(request.username, false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}