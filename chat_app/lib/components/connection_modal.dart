import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/connection_service.dart';
import '../../models/connection.dart';

class ConnectionModal extends StatefulWidget {
  final Function(Connection) onConnectionAdded;

  const ConnectionModal({super.key, required this.onConnectionAdded});

  @override
  State<ConnectionModal> createState() => _ConnectionModalState();
}

class _ConnectionModalState extends State<ConnectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Connection> _suggestedConnections = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestedConnections = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      // In a real app, you would call an API endpoint to search for users
      // This is just a mock implementation
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _suggestedConnections = [
          Connection(
            id: 'new-1',
            name: 'User ${query.trim()}',
            avatar: 'https://randomuser.me/api/portraits/men/${query.length}.jpg',
            email: '${query.trim()}@example.com',
            isOnline: true,
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addConnection(Connection connection) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final connectionService = ConnectionService(
        baseUrl: 'https://your-api-url.com', // Replace with your API URL
        authToken: authProvider.tokens!.accessToken,
      );

      await connectionService.addConnection(connection.id);
      widget.onConnectionAdded(connection);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add connection: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search users',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            )
          else if (_suggestedConnections.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No users found'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestedConnections.length,
              itemBuilder: (context, index) {
                final connection = _suggestedConnections[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(connection.avatar),
                  ),
                  title: Text(connection.name),
                  subtitle: Text(connection.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addConnection(connection),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}